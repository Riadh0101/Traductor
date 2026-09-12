import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import 'settings_state.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized in main()');
});

final settingsControllerProvider =
    StateNotifierProvider<SettingsController, SettingsState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsController(prefs);
});

class SettingsController extends StateNotifier<SettingsState> {
  final SharedPreferences _prefs;

  SettingsController(this._prefs) : super(const SettingsState()) {
    _loadSettings();
  }

  void _loadSettings() {
    final provider = _prefs.getString(AppConstants.prefTranslationProvider) ??
        AppConstants.defaultTranslationProvider;
    final apiUrl = _prefs.getString(AppConstants.prefApiUrl) ?? '';
    final apiKey = _prefs.getString(AppConstants.prefApiKey) ?? '';
    final speechRate =
        _prefs.getDouble(AppConstants.prefSpeechRate) ?? AppConstants.defaultSpeechRate;
    final speechVolume =
        _prefs.getDouble(AppConstants.prefSpeechVolume) ?? AppConstants.defaultSpeechVolume;
    final autoPlayTts =
        _prefs.getBool(AppConstants.prefAutoPlayTts) ?? AppConstants.defaultAutoPlayTts;
    final pauseListeningDuringTts = _prefs.getBool(
            AppConstants.prefPauseListeningDuringTts) ??
        AppConstants.defaultPauseListeningDuringTts;
    final confidenceThreshold = _prefs.getDouble(
            AppConstants.prefConfidenceThreshold) ??
        AppConstants.defaultConfidenceThreshold;
    final silenceTimeoutMs = _prefs.getInt(AppConstants.prefSilenceTimeoutMs) ??
        AppConstants.defaultSilenceTimeoutMs;
    final themeModeStr =
        _prefs.getString(AppConstants.prefThemeMode) ?? 'system';
    final saveHistory = _prefs.getBool(AppConstants.prefSaveHistory) ?? true;

    ThemeMode mode;
    switch (themeModeStr) {
      case 'light':
        mode = ThemeMode.light;
        break;
      case 'dark':
        mode = ThemeMode.dark;
        break;
      default:
        mode = ThemeMode.system;
    }

    state = state.copyWith(
      translationProvider: provider,
      apiUrl: apiUrl,
      apiKey: apiKey,
      speechRate: speechRate,
      speechVolume: speechVolume,
      autoPlayTts: autoPlayTts,
      pauseListeningDuringTts: pauseListeningDuringTts,
      confidenceThreshold: confidenceThreshold,
      silenceTimeoutMs: silenceTimeoutMs,
      themeMode: mode,
      saveHistory: saveHistory,
    );
  }

  Future<void> setTranslationProvider(String provider) async {
    state = state.copyWith(translationProvider: provider);
    await _prefs.setString(AppConstants.prefTranslationProvider, provider);
  }

  Future<void> setApiUrl(String url) async {
    state = state.copyWith(apiUrl: url);
    await _prefs.setString(AppConstants.prefApiUrl, url);
  }

  Future<void> setApiKey(String key) async {
    state = state.copyWith(apiKey: key);
    await _prefs.setString(AppConstants.prefApiKey, key);
  }

  Future<void> setSpeechRate(double rate) async {
    state = state.copyWith(speechRate: rate);
    await _prefs.setDouble(AppConstants.prefSpeechRate, rate);
  }

  Future<void> setSpeechVolume(double volume) async {
    state = state.copyWith(speechVolume: volume);
    await _prefs.setDouble(AppConstants.prefSpeechVolume, volume);
  }

  Future<void> setAutoPlayTts(bool autoPlay) async {
    state = state.copyWith(autoPlayTts: autoPlay);
    await _prefs.setBool(AppConstants.prefAutoPlayTts, autoPlay);
  }

  Future<void> setPauseListeningDuringTts(bool pause) async {
    state = state.copyWith(pauseListeningDuringTts: pause);
    await _prefs.setBool(AppConstants.prefPauseListeningDuringTts, pause);
  }

  Future<void> setConfidenceThreshold(double threshold) async {
    state = state.copyWith(confidenceThreshold: threshold);
    await _prefs.setDouble(AppConstants.prefConfidenceThreshold, threshold);
  }

  Future<void> setSilenceTimeoutMs(int ms) async {
    state = state.copyWith(silenceTimeoutMs: ms);
    await _prefs.setInt(AppConstants.prefSilenceTimeoutMs, ms);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    final str = mode == ThemeMode.light
        ? 'light'
        : mode == ThemeMode.dark
            ? 'dark'
            : 'system';
    await _prefs.setString(AppConstants.prefThemeMode, str);
  }

  Future<void> setSaveHistory(bool save) async {
    state = state.copyWith(saveHistory: save);
    await _prefs.setBool(AppConstants.prefSaveHistory, save);
  }
}
