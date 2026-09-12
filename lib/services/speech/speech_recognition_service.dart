import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart' as stt_res;
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechRecognitionResult {
  final String recognizedWords;
  final bool isFinal;
  final double confidence;

  const SpeechRecognitionResult({
    required this.recognizedWords,
    required this.isFinal,
    this.confidence = 0.0,
  });
}

abstract class SpeechRecognitionService {
  Future<bool> initialize();
  Stream<SpeechRecognitionResult> listen({
    required String localeId,
    Duration? listenFor,
    Duration? pauseFor,
  });
  Future<void> stop();
  Future<void> cancel();
  bool get isListening;
  bool get isAvailable;
}

class SpeechRecognitionServiceImpl implements SpeechRecognitionService {
  final stt.SpeechToText _speechToText;
  StreamController<SpeechRecognitionResult>? _resultController;
  bool _isInitialized = false;

  SpeechRecognitionServiceImpl([stt.SpeechToText? speechToText])
      : _speechToText = speechToText ?? stt.SpeechToText();

  @override
  bool get isListening => _speechToText.isListening;

  @override
  bool get isAvailable => _speechToText.isAvailable;

  @override
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    try {
      _isInitialized = await _speechToText.initialize(
        onError: _handleError,
        onStatus: _handleStatus,
        debugLogging: kDebugMode,
      );
      return _isInitialized;
    } catch (e) {
      debugPrint('SpeechRecognitionService: Initialization failed: $e');
      _isInitialized = false;
      return false;
    }
  }

  List<stt.LocaleName>? _cachedLocales;

  void _handleError(SpeechRecognitionError error) {
    debugPrint('SpeechRecognitionService Error: ${error.errorMsg} (permanent: ${error.permanent})');
    final msg = error.errorMsg.toLowerCase();
    // Only forward critical or configuration errors to the controller
    if (error.permanent ||
        msg.contains('not_supported') ||
        msg.contains('language') ||
        msg.contains('insufficient_permissions')) {
      if (_resultController != null && !_resultController!.isClosed) {
        _resultController!.addError(error.errorMsg);
      }
    }
  }

  void _handleStatus(String status) {
    debugPrint('SpeechRecognitionService Status: $status');
  }

  Future<List<stt.LocaleName>> _getAvailableLocales() async {
    if (_cachedLocales != null && _cachedLocales!.isNotEmpty) {
      return _cachedLocales!;
    }
    try {
      final isInit = await initialize();
      if (isInit) {
        _cachedLocales = await _speechToText.locales();
      }
    } catch (e) {
      debugPrint('SpeechRecognitionService: Error fetching locales: $e');
    }
    return _cachedLocales ?? [];
  }

  Future<String> _resolveBestLocale(String requestedLocale) async {
    final available = await _getAvailableLocales();
    if (available.isEmpty) return requestedLocale;

    // 1. Exact match
    for (final loc in available) {
      if (loc.localeId.toLowerCase() == requestedLocale.toLowerCase()) {
        return loc.localeId;
      }
    }

    // 2. Normalize hyphens and underscores (e.g. tr-TR vs tr_TR)
    final normalizedReq = requestedLocale.toLowerCase().replaceAll('-', '_');
    for (final loc in available) {
      if (loc.localeId.toLowerCase().replaceAll('-', '_') == normalizedReq) {
        return loc.localeId;
      }
    }

    // 3. Language code prefix match (e.g. 'tr' matches 'tr_TR' or 'tr-TR')
    final langCode = requestedLocale.split(RegExp(r'[-_]')).first.toLowerCase();
    for (final loc in available) {
      final locCode = loc.localeId.split(RegExp(r'[-_]')).first.toLowerCase();
      if (locCode == langCode) {
        return loc.localeId;
      }
    }

    return requestedLocale;
  }

  @override
  Stream<SpeechRecognitionResult> listen({
    required String localeId,
    Duration? listenFor,
    Duration? pauseFor,
  }) {
    _resultController?.close();
    _resultController = StreamController<SpeechRecognitionResult>.broadcast();

    _startListening(
      localeId: localeId,
      listenFor: listenFor ?? const Duration(minutes: 5),
      pauseFor: pauseFor ?? const Duration(seconds: 30),
    );

    return _resultController!.stream;
  }

  Future<void> _startListening({
    required String localeId,
    required Duration listenFor,
    required Duration pauseFor,
  }) async {
    final available = await initialize();
    if (!available) {
      _resultController?.addError('Speech recognition service is not available on this device.');
      return;
    }

    try {
      if (_speechToText.isListening) {
        await _speechToText.stop();
        await Future.delayed(const Duration(milliseconds: 150));
      }

      // Dynamically resolve the best locale supported by the device
      final resolvedLocale = await _resolveBestLocale(localeId);
      debugPrint('SpeechRecognitionService: listening with resolved locale: $resolvedLocale (requested: $localeId)');

      await _speechToText.listen(
        onResult: (stt_res.SpeechRecognitionResult result) {
          if (_resultController != null && !_resultController!.isClosed) {
            _resultController!.add(
              SpeechRecognitionResult(
                recognizedWords: result.recognizedWords,
                isFinal: result.finalResult,
                confidence: result.confidence,
              ),
            );
          }
        },
        listenOptions: stt.SpeechListenOptions(
          partialResults: true,
          cancelOnError: false,
          listenMode: stt.ListenMode.dictation,
          localeId: resolvedLocale,
          listenFor: listenFor,
          pauseFor: pauseFor,
        ),
      );
    } catch (e) {
      debugPrint('SpeechRecognitionService: listen error: $e');
      if (_resultController != null && !_resultController!.isClosed) {
        _resultController!.addError(e);
      }
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _speechToText.stop();
    } catch (e) {
      debugPrint('SpeechRecognitionService: Error during stop: $e');
    }
  }

  @override
  Future<void> cancel() async {
    try {
      await _speechToText.cancel();
      _resultController?.close();
      _resultController = null;
    } catch (e) {
      debugPrint('SpeechRecognitionService: Error during cancel: $e');
    }
  }
}
