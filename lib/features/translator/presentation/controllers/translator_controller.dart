// ignore_for_file: prefer_initializing_formals
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/permissions/permission_service.dart';
import '../../../../core/utils/debouncer.dart';
import '../../../../core/utils/speech_disfluency_filter.dart';
import '../../../../data/repositories/translation_repository_impl.dart';
import '../../../../domain/entities/conversation_session.dart';
import '../../../../domain/entities/language.dart';
import '../../../../domain/entities/translation_message.dart';
import '../../../../domain/repositories/history_repository.dart';
import '../../../../domain/repositories/translation_repository.dart';
import '../../../../services/language_detection/two_way_language_detector.dart';
import '../../../../services/speech/speech_recognition_service.dart';
import '../../../../services/tts/text_to_speech_service.dart';
import '../../../history/presentation/controllers/history_controller.dart';
import '../../../settings/presentation/controllers/settings_controller.dart';
import '../../../subscription/presentation/controllers/subscription_controller.dart';
import 'translator_state.dart';

final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionServiceImpl();
});

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl();
});

final speechRecognitionServiceProvider = Provider<SpeechRecognitionService>((ref) {
  return SpeechRecognitionServiceImpl();
});

final ttsServiceProvider = Provider<TextToSpeechService>((ref) {
  return TextToSpeechServiceImpl();
});

final twoWayLanguageDetectorProvider = Provider<TwoWayLanguageDetector>((ref) {
  return TwoWayLanguageDetector();
});

final translationRepositoryProvider = Provider<TranslationRepository>((ref) {
  final network = ref.watch(networkInfoProvider);
  return TranslationRepositoryImpl(networkInfo: network);
});

final translatorControllerProvider =
    StateNotifierProvider<TranslatorController, TranslatorState>((ref) {
  final speech = ref.watch(speechRecognitionServiceProvider);
  final tts = ref.watch(ttsServiceProvider);
  final detector = ref.watch(twoWayLanguageDetectorProvider);
  final translation = ref.watch(translationRepositoryProvider);
  final permission = ref.watch(permissionServiceProvider);
  final historyRepo = ref.watch(historyRepositoryProvider);

  return TranslatorController(
    speechService: speech,
    ttsService: tts,
    detector: detector,
    translationRepo: translation,
    permissionService: permission,
    historyRepo: historyRepo,
    ref: ref,
  );
});

class TranslatorController extends StateNotifier<TranslatorState> {
  final SpeechRecognitionService _speechService;
  final TextToSpeechService _ttsService;
  final TwoWayLanguageDetector _detector;
  final TranslationRepository _translationRepo;
  final PermissionService _permissionService;
  final HistoryRepository _historyRepo;
  final Ref _ref;

  StreamSubscription<SpeechRecognitionResult>? _speechSubscription;
  Debouncer _silenceDebouncer;
  bool _isDisposed = false;
  static const _uuid = Uuid();

  TranslatorController({
    required SpeechRecognitionService speechService,
    required TextToSpeechService ttsService,
    required TwoWayLanguageDetector detector,
    required TranslationRepository translationRepo,
    required PermissionService permissionService,
    required HistoryRepository historyRepo,
    required Ref ref,
  })  : _speechService = speechService,
        _ttsService = ttsService,
        _detector = detector,
        _translationRepo = translationRepo,
        _permissionService = permissionService,
        _historyRepo = historyRepo,
        _ref = ref,
        _silenceDebouncer = Debouncer(milliseconds: AppConstants.defaultSilenceTimeoutMs),
        super(const TranslatorState()) {
    _createNewSession();
    _initServices();
  }

  Future<void> _initServices() async {
    await _speechService.initialize();
    await _ttsService.initialize();
    _ttsService.setOnCompletionHandler(_onTtsCompleted);
    _ttsService.setOnErrorHandler((err) {
      if (!_isDisposed) {
        state = state.copyWith(
          status: TranslatorStatus.idle,
          errorMessage: 'Audio playback failed.',
        );
      }
    });
  }

  void _createNewSession() {
    final session = ConversationSession(
      id: _uuid.v4(),
      createdAt: DateTime.now(),
      language1: state.language1,
      language2: state.language2,
      title: '${state.language1.name} ⇄ ${state.language2.name}',
      messages: const [],
    );
    state = state.copyWith(currentSession: session, messages: []);
  }

  void setLanguage1(Language lang) {
    if (lang == state.language2) {
      swapLanguages();
      return;
    }
    state = state.copyWith(language1: lang);
    _createNewSession();
  }

  void setLanguage2(Language lang) {
    if (lang == state.language1) {
      swapLanguages();
      return;
    }
    state = state.copyWith(language2: lang);
    _createNewSession();
  }

  void swapLanguages() {
    state = state.copyWith(
      language1: state.language2,
      language2: state.language1,
      isSwappingLanguages: true,
    );
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!_isDisposed) {
        state = state.copyWith(isSwappingLanguages: false);
      }
    });
  }

  void setActiveMode(String mode) {
    if (state.status == TranslatorStatus.listening) {
      stopListening();
    }
    state = state.copyWith(activeMode: mode);
  }

  // --- Speech & Translation Lifecycle ---

  Future<void> toggleListening() async {
    if (state.status == TranslatorStatus.listening) {
      await stopListening();
    } else if (state.status == TranslatorStatus.speaking) {
      await _ttsService.stop();
      state = state.copyWith(status: TranslatorStatus.idle);
    } else {
      await startListening();
    }
  }

  Language? _forcedSourceLanguage;
  Language? _forcedTargetLanguage;
  bool _isPushToTalkHolding = false;
  String _accumulatedSpeech = '';
  String _currentChunkWords = '';
  String _activeSttLocale = '';

  Future<void> startListeningLanguage1() async {
    _isPushToTalkHolding = true;
    _accumulatedSpeech = '';
    _currentChunkWords = '';
    _forcedSourceLanguage = state.language1;
    _forcedTargetLanguage = state.language2;
    await startListening(
      forcedSourceLanguage: state.language1,
      forcedTargetLanguage: state.language2,
    );
  }

  Future<void> startListeningLanguage2() async {
    _isPushToTalkHolding = true;
    _accumulatedSpeech = '';
    _currentChunkWords = '';
    _forcedSourceLanguage = state.language2;
    _forcedTargetLanguage = state.language1;
    await startListening(
      forcedSourceLanguage: state.language2,
      forcedTargetLanguage: state.language1,
    );
  }

  Future<void> startListening({
    Language? forcedSourceLanguage,
    Language? forcedTargetLanguage,
  }) async {
    state = state.copyWith(errorMessage: null);
    _forcedSourceLanguage = forcedSourceLanguage;
    _forcedTargetLanguage = forcedTargetLanguage;

    // 0. Subscription Quota & Language Check
    final subState = _ref.read(subscriptionControllerProvider);
    if (!subState.canTranslate) {
      state = state.copyWith(
        status: TranslatorStatus.idle,
        errorMessage: 'Daily free translation limit reached (${subState.maxFreeTranslations}/${subState.maxFreeTranslations}). Upgrade to Pro for unlimited translations.',
      );
      return;
    }
    if (!subState.isPro) {
      if (!subState.isLanguageAllowed(state.language1) || !subState.isLanguageAllowed(state.language2)) {
        state = state.copyWith(
          status: TranslatorStatus.idle,
          errorMessage: 'Selected language is exclusive to Traductor Pro. Please select from Arabic, English, French, Turkish or upgrade.',
        );
        return;
      }
    }

    // 1. Permission check
    final hasPerm = await _permissionService.hasMicrophonePermission();
    if (!hasPerm) {
      final status = await _permissionService.requestMicrophonePermission();
      if (!status.isGranted) {
        state = state.copyWith(
          status: TranslatorStatus.error,
          errorMessage: 'Microphone permission is required to capture speech.',
        );
        return;
      }
    }

    // 2. Determine initial STT locale
    String localeId = state.language1.sttLocale;
    if (_forcedSourceLanguage != null) {
      localeId = _forcedSourceLanguage!.sttLocale;
    } else if (state.activeMode == AppConstants.modeManualL2ToL1) {
      localeId = state.language2.sttLocale;
    } else if (state.lastSpokenLanguage != null) {
      // In two-way auto mode, listen for next speaker's expected language
      final nextLang = state.lastSpokenLanguage == state.language1
          ? state.language2
          : state.language1;
      localeId = nextLang.sttLocale;
    }

    _activeSttLocale = localeId;
    state = state.copyWith(
      status: TranslatorStatus.listening,
      liveTranscript: '',
      detectedLiveLanguage: _forcedSourceLanguage,
    );

    _silenceDebouncer.cancel();
    await _speechSubscription?.cancel();

    final silenceMs = _ref.read(settingsControllerProvider).silenceTimeoutMs;
    _silenceDebouncer = Debouncer(milliseconds: silenceMs);

    _speechSubscription = _speechService
        .listen(
          localeId: localeId,
          listenFor: const Duration(minutes: 5),
          pauseFor: const Duration(seconds: 30),
        )
        .listen(
          _onSpeechResult,
          onError: (error) {
            debugPrint('STT Error in Controller: $error');
            if (!_isDisposed && _isPushToTalkHolding) {
              Future.delayed(const Duration(milliseconds: 80), () {
                if (_isPushToTalkHolding && !_isDisposed && state.status == TranslatorStatus.listening) {
                  _reconnectStt();
                }
              });
            } else if (!_isDisposed) {
              if (state.liveTranscript.trim().isNotEmpty) {
                _processFinalTranscript(state.liveTranscript);
              } else {
                state = state.copyWith(
                  status: TranslatorStatus.idle,
                  errorMessage: 'Speech recognition error: $error',
                );
              }
            }
          },
          onDone: () {
            if (!_isDisposed && _isPushToTalkHolding) {
              if (_currentChunkWords.trim().isNotEmpty) {
                _accumulatedSpeech = _mergeTranscripts(_accumulatedSpeech, _currentChunkWords);
                _currentChunkWords = '';
              }
              Future.delayed(const Duration(milliseconds: 100), () {
                if (_isPushToTalkHolding && !_isDisposed && state.status == TranslatorStatus.listening) {
                  _reconnectStt();
                }
              });
            } else if (!_isDisposed &&
                state.status == TranslatorStatus.listening &&
                state.liveTranscript.trim().isNotEmpty) {
              _processFinalTranscript(state.liveTranscript);
            }
          },
        );
  }

  bool _isReconnecting = false;

  Future<void> _reconnectStt() async {
    if (_isDisposed || !_isPushToTalkHolding || _isReconnecting) return;
    _isReconnecting = true;
    try {
      if (_currentChunkWords.trim().isNotEmpty) {
        _accumulatedSpeech = _mergeTranscripts(_accumulatedSpeech, _currentChunkWords);
        _currentChunkWords = '';
      }
      await _speechService.stop();
      await Future.delayed(const Duration(milliseconds: 200));

      if (!_isDisposed && _isPushToTalkHolding) {
        await _speechSubscription?.cancel();
        _speechSubscription = _speechService
            .listen(
              localeId: _activeSttLocale,
              listenFor: const Duration(minutes: 5),
              pauseFor: const Duration(seconds: 30),
            )
            .listen(
              _onSpeechResult,
              onError: (error) {
                debugPrint('Reconnected STT Error: $error');
                if (_isPushToTalkHolding && !_isDisposed) {
                  Future.delayed(const Duration(milliseconds: 250), () {
                    if (_isPushToTalkHolding && !_isDisposed) {
                      _reconnectStt();
                    }
                  });
                }
              },
              onDone: () {
                if (_isPushToTalkHolding && !_isDisposed) {
                  if (_currentChunkWords.trim().isNotEmpty) {
                    _accumulatedSpeech = _mergeTranscripts(_accumulatedSpeech, _currentChunkWords);
                    _currentChunkWords = '';
                  }
                  Future.delayed(const Duration(milliseconds: 150), () {
                    if (_isPushToTalkHolding && !_isDisposed) {
                      _reconnectStt();
                    }
                  });
                }
              },
            );
      }
    } finally {
      _isReconnecting = false;
    }
  }

  String _mergeTranscripts(String accumulated, String current) {
    final acc = accumulated.trim();
    final cur = current.trim();
    if (acc.isEmpty) return cur;
    if (cur.isEmpty) return acc;
    if (cur.startsWith(acc)) return cur;
    if (acc.endsWith(cur)) return acc;
    
    // Check if cur contains the tail of acc (overlap)
    final accWords = acc.split(' ');
    for (int i = 1; i <= accWords.length; i++) {
      final tail = accWords.sublist(accWords.length - i).join(' ');
      if (cur.startsWith(tail)) {
        final rest = cur.substring(tail.length).trim();
        return rest.isEmpty ? acc : '$acc $rest';
      }
    }
    return '$acc $cur';
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    final words = result.recognizedWords.trim();
    if (words.isEmpty) return;

    if (result.isFinal) {
      _accumulatedSpeech = _mergeTranscripts(_accumulatedSpeech, words);
      _currentChunkWords = '';
    } else {
      _currentChunkWords = words;
    }

    final fullText = _mergeTranscripts(_accumulatedSpeech, _currentChunkWords);

    state = state.copyWith(
      liveTranscript: fullText,
      detectedLiveLanguage: _forcedSourceLanguage,
    );

    // CRITICAL: In Push-to-Talk mode, NEVER trigger translation on silence debouncer!
    // The speaker can pause and speak as long as they hold the button.
    if (state.activeMode == AppConstants.modeAutoConversation && !_isPushToTalkHolding) {
      _silenceDebouncer.cancel();
      _silenceDebouncer.run(() {
        if (!_isDisposed && state.status == TranslatorStatus.listening) {
          _processFinalTranscript(state.liveTranscript);
        }
      });
    }
  }

  Future<void> _processFinalTranscript(String rawText) async {
    final filteredImmediate = SpeechDisfluencyFilter.cleanImmediateDisfluencies(rawText);
    final text = filteredImmediate.isNotEmpty ? filteredImmediate : rawText.trim();
    if (text.isEmpty) return;

    final subState = _ref.read(subscriptionControllerProvider);
    if (!subState.canTranslate) {
      state = state.copyWith(
        status: TranslatorStatus.idle,
        errorMessage: 'Daily free translation limit reached (${subState.maxFreeTranslations}/${subState.maxFreeTranslations}). Upgrade to Pro for unlimited translations.',
      );
      return;
    }

    _silenceDebouncer.cancel();
    await _speechService.stop();

    state = state.copyWith(
      status: TranslatorStatus.processing,
      liveTranscript: text,
    );

    // 1. Language Disambiguation
    late Language sourceLang;
    late Language targetLang;

    if (_forcedSourceLanguage != null && _forcedTargetLanguage != null) {
      sourceLang = _forcedSourceLanguage!;
      targetLang = _forcedTargetLanguage!;
    } else if (state.activeMode == AppConstants.modeManualL1ToL2) {
      sourceLang = state.language1;
      targetLang = state.language2;
    } else if (state.activeMode == AppConstants.modeManualL2ToL1) {
      sourceLang = state.language2;
      targetLang = state.language1;
    } else {
      // Automatic Two-Way Language Detection
      final detection = _detector.detectBetween(
        text: text,
        languageA: state.language1,
        languageB: state.language2,
        lastSpokenLanguage: state.lastSpokenLanguage,
      );

      final threshold = _ref.read(settingsControllerProvider).confidenceThreshold;
      if (detection.confidence >= threshold) {
        sourceLang = detection.detectedLanguage;
      } else if (state.lastSpokenLanguage != null) {
        // Fall back to alternating speaker
        sourceLang = state.lastSpokenLanguage == state.language1
            ? state.language2
            : state.language1;
      } else {
        sourceLang = state.language1;
      }

      targetLang = (sourceLang == state.language1) ? state.language2 : state.language1;
    }

    state = state.copyWith(
      status: TranslatorStatus.translating,
      detectedLiveLanguage: sourceLang,
      lastSpokenLanguage: sourceLang,
    );

    // 2. Perform Intelligent AI Translation & Speech Sifting
    try {
      final settings = _ref.read(settingsControllerProvider);
      final preferred = (subState.canUseGemini || settings.translationProvider == AppConstants.providerFree)
          ? settings.translationProvider
          : AppConstants.providerFree;
      final translationResult = await _translationRepo.translateDetailed(
        text: text,
        sourceLanguage: sourceLang,
        targetLanguage: targetLang,
        preferredProvider: preferred,
        apiUrl: settings.apiUrl,
        apiKey: settings.apiKey,
      );

      final translatedText = translationResult.translatedText;
      final cleanSource = (translationResult.cleanedSourceText != null &&
              translationResult.cleanedSourceText!.trim().isNotEmpty)
          ? translationResult.cleanedSourceText!.trim()
          : text;

      final message = TranslationMessage(
        id: _uuid.v4(),
        conversationId: state.currentSession?.id ?? _uuid.v4(),
        sourceLanguage: sourceLang,
        sourceText: cleanSource,
        targetLanguage: targetLang,
        translatedText: translatedText,
        timestamp: DateTime.now(),
      );

      final updatedMessages = List<TranslationMessage>.from(state.messages)..add(message);
      state = state.copyWith(
        messages: updatedMessages,
        liveTranscript: '',
      );

      // Increment daily usage count for Free tier
      await _ref.read(subscriptionControllerProvider.notifier).incrementTranslationUsage();

      // Save to database if enabled
      if (settings.saveHistory && state.currentSession != null) {
        await _historyRepo.saveSession(state.currentSession!);
        await _historyRepo.addMessage(message);
      }

      // 3. Play Text-to-Speech with feedback loop prevention
      if (settings.autoPlayTts && translatedText.isNotEmpty) {
        state = state.copyWith(status: TranslatorStatus.speaking);

        // Safety fallback timer so it never stays stuck in speaking state
        final safetySeconds = (translatedText.length / 8).ceil() + 3;
        Timer(Duration(seconds: safetySeconds), () {
          if (!_isDisposed && state.status == TranslatorStatus.speaking) {
            _onTtsCompleted();
          }
        });

        await _ttsService.speak(
          translatedText,
          targetLang.ttsLocale,
          speechRate: settings.speechRate,
          volume: settings.speechVolume,
        );
      } else {
        _finishTurn();
      }
    } catch (e) {
      debugPrint('Translation error: $e');
      state = state.copyWith(
        status: TranslatorStatus.error,
        errorMessage: e.toString(),
      );
      _finishTurn();
    }
  }

  void _onTtsCompleted() {
    if (_isDisposed || state.status != TranslatorStatus.speaking) return;

    final settings = _ref.read(settingsControllerProvider);
    // Mandatory Section 17 Cooldown Delay to guarantee no speaker audio enters mic
    final delayMs = settings.pauseListeningDuringTts ? AppConstants.ttsCooldownDelayMs : 150;

    state = state.copyWith(status: TranslatorStatus.idle);

    Future.delayed(Duration(milliseconds: delayMs), () {
      if (!_isDisposed) {
        _finishTurn();
      }
    });
  }

  void _finishTurn() {
    if (_isDisposed) return;

    if (state.activeMode == AppConstants.modeAutoConversation) {
      // In auto conversation mode, continue listening for the other person smoothly!
      Future.delayed(const Duration(milliseconds: 250), () {
        if (!_isDisposed && state.status == TranslatorStatus.idle) {
          startListening();
        }
      });
    } else {
      state = state.copyWith(
        status: TranslatorStatus.idle,
        liveTranscript: '',
      );
    }
  }

  /// Walkie-talkie Push-to-Talk: releases mic and starts translating captured speech immediately!
  Future<void> stopListeningAndTranslate() async {
    if (_isDisposed) return;
    _isPushToTalkHolding = false;
    _silenceDebouncer.cancel();

    // Give a brief buffer delay (350ms) for the microphone audio queue to flush
    // so the final spoken syllables are transcribed by the speech recognition engine!
    await Future.delayed(const Duration(milliseconds: 350));

    // Stop mic input
    await _speechService.stop();
    // Allow pending recognition buffer to finish emitting
    await Future.delayed(const Duration(milliseconds: 150));
    await _speechSubscription?.cancel();

    // Reconstruct full transcript from accumulated speech and current chunk
    var fullTranscript = _mergeTranscripts(_accumulatedSpeech, _currentChunkWords).trim();
    if (fullTranscript.isEmpty) {
      fullTranscript = state.liveTranscript.trim();
    }

    _accumulatedSpeech = '';
    _currentChunkWords = '';

    if (fullTranscript.isNotEmpty) {
      await _processFinalTranscript(fullTranscript);
    } else {
      state = state.copyWith(
        status: TranslatorStatus.idle,
        liveTranscript: '',
      );
    }
  }

  Future<void> stopListening() async {
    _isPushToTalkHolding = false;
    _silenceDebouncer.cancel();
    await _speechService.stop();
    await _speechSubscription?.cancel();
    _accumulatedSpeech = '';
    _currentChunkWords = '';
    state = state.copyWith(
      status: TranslatorStatus.idle,
      liveTranscript: '',
    );
  }

  Future<void> translateCustomText({
    required String text,
    required Language source,
    required Language target,
  }) async {
    _forcedSourceLanguage = source;
    _forcedTargetLanguage = target;
    await _processFinalTranscript(text);
    _forcedSourceLanguage = null;
    _forcedTargetLanguage = null;
  }

  void clearConversation() {
    _createNewSession();
  }

  Future<void> replayMessageAudio(TranslationMessage message) async {
    final settings = _ref.read(settingsControllerProvider);
    await _ttsService.speak(
      message.translatedText,
      message.targetLanguage.ttsLocale,
      speechRate: settings.speechRate,
      volume: settings.speechVolume,
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _silenceDebouncer.cancel();
    _speechSubscription?.cancel();
    _speechService.cancel();
    _ttsService.stop();
    super.dispose();
  }
}
