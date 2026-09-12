import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

class SettingsState {
  final String translationProvider;
  final String apiUrl;
  final String apiKey;
  final double speechRate;
  final double speechVolume;
  final bool autoPlayTts;
  final bool pauseListeningDuringTts;
  final double confidenceThreshold;
  final int silenceTimeoutMs;
  final ThemeMode themeMode;
  final bool saveHistory;
  final bool isLoading;

  const SettingsState({
    this.translationProvider = AppConstants.providerGemini,
    this.apiUrl = '',
    this.apiKey = AppConstants.defaultGeminiApiKey,
    this.speechRate = AppConstants.defaultSpeechRate,
    this.speechVolume = AppConstants.defaultSpeechVolume,
    this.autoPlayTts = AppConstants.defaultAutoPlayTts,
    this.pauseListeningDuringTts = AppConstants.defaultPauseListeningDuringTts,
    this.confidenceThreshold = AppConstants.defaultConfidenceThreshold,
    this.silenceTimeoutMs = AppConstants.defaultSilenceTimeoutMs,
    this.themeMode = ThemeMode.system,
    this.saveHistory = true,
    this.isLoading = false,
  });

  SettingsState copyWith({
    String? translationProvider,
    String? apiUrl,
    String? apiKey,
    double? speechRate,
    double? speechVolume,
    bool? autoPlayTts,
    bool? pauseListeningDuringTts,
    double? confidenceThreshold,
    int? silenceTimeoutMs,
    ThemeMode? themeMode,
    bool? saveHistory,
    bool? isLoading,
  }) {
    return SettingsState(
      translationProvider: translationProvider ?? this.translationProvider,
      apiUrl: apiUrl ?? this.apiUrl,
      apiKey: apiKey ?? this.apiKey,
      speechRate: speechRate ?? this.speechRate,
      speechVolume: speechVolume ?? this.speechVolume,
      autoPlayTts: autoPlayTts ?? this.autoPlayTts,
      pauseListeningDuringTts: pauseListeningDuringTts ?? this.pauseListeningDuringTts,
      confidenceThreshold: confidenceThreshold ?? this.confidenceThreshold,
      silenceTimeoutMs: silenceTimeoutMs ?? this.silenceTimeoutMs,
      themeMode: themeMode ?? this.themeMode,
      saveHistory: saveHistory ?? this.saveHistory,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
