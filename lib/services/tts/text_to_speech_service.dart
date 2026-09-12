import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

abstract class TextToSpeechService {
  Future<void> initialize();
  Future<void> speak(
    String text,
    String languageCode, {
    double? speechRate,
    double? volume,
  });
  Future<void> stop();
  bool get isSpeaking;
  void setOnCompletionHandler(VoidCallback callback);
  void setOnStartHandler(VoidCallback callback);
  void setOnErrorHandler(Function(dynamic) callback);
}

class TextToSpeechServiceImpl implements TextToSpeechService {
  final FlutterTts _flutterTts;
  bool _isSpeaking = false;
  VoidCallback? _onCompletion;
  VoidCallback? _onStart;
  Function(dynamic)? _onError;

  TextToSpeechServiceImpl([FlutterTts? flutterTts])
      : _flutterTts = flutterTts ?? FlutterTts();

  @override
  bool get isSpeaking => _isSpeaking;

  @override
  void setOnCompletionHandler(VoidCallback callback) {
    _onCompletion = callback;
  }

  @override
  void setOnStartHandler(VoidCallback callback) {
    _onStart = callback;
  }

  @override
  void setOnErrorHandler(Function(dynamic) callback) {
    _onError = callback;
  }

  @override
  Future<void> initialize() async {
    try {
      await _flutterTts.awaitSpeakCompletion(true);

      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
        _onStart?.call();
      });

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        _onCompletion?.call();
      });

      _flutterTts.setCancelHandler(() {
        _isSpeaking = false;
        _onCompletion?.call();
      });

      _flutterTts.setErrorHandler((msg) {
        _isSpeaking = false;
        debugPrint('TextToSpeechService error: $msg');
        _onError?.call(msg);
      });
    } catch (e) {
      debugPrint('TextToSpeechService initialize failed: $e');
    }
  }

  @override
  Future<void> speak(
    String text,
    String languageCode, {
    double? speechRate,
    double? volume,
  }) async {
    try {
      await _flutterTts.stop();

      // Ensure appropriate locale format for TTS (e.g. "tr-TR", "ar-SA", "en-US")
      await _flutterTts.setLanguage(languageCode);
      if (speechRate != null) {
        await _flutterTts.setSpeechRate(speechRate);
      }
      if (volume != null) {
        await _flutterTts.setVolume(volume);
      }

      _isSpeaking = true;
      _onStart?.call();
      await _flutterTts.speak(text);
    } catch (e) {
      _isSpeaking = false;
      debugPrint('TextToSpeechService speak failed: $e');
      _onError?.call(e);
    }
  }

  @override
  Future<void> stop() async {
    try {
      _isSpeaking = false;
      await _flutterTts.stop();
    } catch (e) {
      debugPrint('TextToSpeechService stop failed: $e');
    }
  }
}
