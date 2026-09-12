import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traductor/core/constants/app_constants.dart';
import 'package:traductor/core/constants/supported_languages.dart';
import 'package:traductor/core/permissions/permission_service.dart';
import 'package:traductor/domain/entities/conversation_session.dart';
import 'package:traductor/domain/entities/language.dart';
import 'package:traductor/domain/entities/translation_message.dart';
import 'package:traductor/domain/repositories/history_repository.dart';
import 'package:traductor/domain/repositories/translation_repository.dart';
import 'package:traductor/features/history/presentation/controllers/history_controller.dart';
import 'package:traductor/features/settings/presentation/controllers/settings_controller.dart';
import 'package:traductor/features/translator/presentation/controllers/translator_controller.dart';
import 'package:traductor/features/translator/presentation/controllers/translator_state.dart';
import 'package:traductor/services/speech/speech_recognition_service.dart';
import 'package:traductor/services/translation/translation_provider.dart';
import 'package:traductor/services/tts/text_to_speech_service.dart';

class MockSpeechService implements SpeechRecognitionService {
  @override
  bool get isAvailable => true;
  @override
  bool get isListening => false;
  @override
  Future<bool> initialize() async => true;
  @override
  Stream<SpeechRecognitionResult> listen({
    required String localeId,
    Duration? listenFor,
    Duration? pauseFor,
  }) => const Stream.empty();
  @override
  Future<void> stop() async {}
  @override
  Future<void> cancel() async {}
}

class MockTtsService implements TextToSpeechService {
  String? lastSpokenText;
  String? lastSpokenLocale;

  @override
  bool get isSpeaking => false;
  @override
  Future<void> initialize() async {}
  @override
  void setOnCompletionHandler(VoidCallback callback) {}
  @override
  void setOnErrorHandler(Function(dynamic p1) callback) {}
  @override
  void setOnStartHandler(VoidCallback callback) {}
  @override
  Future<void> speak(
    String text,
    String languageCode, {
    double? speechRate,
    double? volume,
  }) async {
    lastSpokenText = text;
    lastSpokenLocale = languageCode;
  }
  @override
  Future<void> stop() async {}
}

class MockPermissionService implements PermissionService {
  bool granted = true;
  @override
  Future<bool> hasMicrophonePermission() async => granted;
  @override
  Future<PermissionStatus> requestMicrophonePermission() async =>
      granted ? PermissionStatus.granted : PermissionStatus.denied;
  @override
  Future<bool> openAppSettings() async => true;
}

class MockHistoryRepo implements HistoryRepository {
  final List<ConversationSession> savedSessions = [];
  final List<TranslationMessage> savedMessages = [];

  @override
  Future<void> addMessage(TranslationMessage message) async {
    savedMessages.add(message);
  }
  @override
  Future<void> clearAllHistory() async {
    savedSessions.clear();
    savedMessages.clear();
  }
  @override
  Future<void> deleteSession(String id) async {
    savedSessions.removeWhere((s) => s.id == id);
  }
  @override
  Future<List<ConversationSession>> getAllSessions() async => savedSessions;
  @override
  Future<ConversationSession?> getSessionById(String id) async {
    final matches = savedSessions.where((s) => s.id == id);
    return matches.isEmpty ? null : matches.first;
  }
  @override
  Future<void> saveSession(ConversationSession session) async {
    savedSessions.add(session);
  }
}

class MockTranslationRepo implements TranslationRepository {
  @override
  Future<String> translate({
    required String text,
    required Language sourceLanguage,
    required Language targetLanguage,
    String? preferredProvider,
    String? apiUrl,
    String? apiKey,
  }) async {
    return 'Translated: $text';
  }

  @override
  Future<TranslationResult> translateDetailed({
    required String text,
    required Language sourceLanguage,
    required Language targetLanguage,
    String? preferredProvider,
    String? apiUrl,
    String? apiKey,
  }) async {
    return TranslationResult(
      translatedText: 'Translated: $text',
      providerName: 'Mock',
      cleanedSourceText: text,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TranslatorController Tests', () {
    late ProviderContainer container;
    late MockTtsService mockTts;
    late MockSpeechService mockSpeech;
    late MockPermissionService mockPermission;
    late MockHistoryRepo mockHistory;
    late MockTranslationRepo mockTranslation;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      mockTts = MockTtsService();
      mockSpeech = MockSpeechService();
      mockPermission = MockPermissionService();
      mockHistory = MockHistoryRepo();
      mockTranslation = MockTranslationRepo();

      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          speechRecognitionServiceProvider.overrideWithValue(mockSpeech),
          ttsServiceProvider.overrideWithValue(mockTts),
          permissionServiceProvider.overrideWithValue(mockPermission),
          historyRepositoryProvider.overrideWithValue(mockHistory),
          translationRepositoryProvider.overrideWithValue(mockTranslation),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initializes with default Arabic ⇄ Turkish and idle state', () {
      final state = container.read(translatorControllerProvider);

      expect(state.status, TranslatorStatus.idle);
      expect(state.language1.isoCode, 'ar');
      expect(state.language2.isoCode, 'tr');
      expect(state.messages, isEmpty);
      expect(state.activeMode, AppConstants.modePushToTalk);
      expect(state.currentSession, isNotNull);
    });

    test('swaps languages properly', () {
      final notifier = container.read(translatorControllerProvider.notifier);

      notifier.swapLanguages();

      final state = container.read(translatorControllerProvider);
      expect(state.language1.isoCode, 'tr');
      expect(state.language2.isoCode, 'ar');
    });

    test('setting language1 to same as language2 triggers swap', () {
      final notifier = container.read(translatorControllerProvider.notifier);

      notifier.setLanguage1(SupportedLanguages.turkish);

      final state = container.read(translatorControllerProvider);
      expect(state.language1.isoCode, 'tr');
      expect(state.language2.isoCode, 'ar');
    });

    test('changing activeMode updates state', () {
      final notifier = container.read(translatorControllerProvider.notifier);

      notifier.setActiveMode(AppConstants.modeManualL1ToL2);

      final state = container.read(translatorControllerProvider);
      expect(state.activeMode, AppConstants.modeManualL1ToL2);
    });

    test('permission denial sets error state', () async {
      mockPermission.granted = false;
      final notifier = container.read(translatorControllerProvider.notifier);

      await notifier.startListening();

      final state = container.read(translatorControllerProvider);
      expect(state.status, TranslatorStatus.error);
      expect(state.errorMessage, contains('Microphone permission is required'));
    });

    test('replayMessageAudio calls TTS speak with target locale', () async {
      final notifier = container.read(translatorControllerProvider.notifier);
      final message = TranslationMessage(
        id: '123',
        conversationId: 'c1',
        sourceLanguage: SupportedLanguages.english,
        sourceText: 'Hello',
        targetLanguage: SupportedLanguages.turkish,
        translatedText: 'Merhaba',
        timestamp: DateTime.now(),
      );

      await notifier.replayMessageAudio(message);

      expect(mockTts.lastSpokenText, 'Merhaba');
      expect(mockTts.lastSpokenLocale, 'tr-TR');
    });
  });
}
