class AppConstants {
  static const String appName = 'RealTime Translator';
  static const String companyName = 'بصيرة - Basira AI 2026';
  static const String appVersion = '1.0.0';
  static const int appBuildNumber = 11; // Auto-increment on every system update/build

  // Preferences Keys
  static const String prefLanguage1 = 'pref_language_1';
  static const String prefLanguage2 = 'pref_language_2';
  static const String prefTranslationProvider = 'pref_translation_provider';
  static const String prefApiUrl = 'pref_api_url';
  static const String prefApiKey = 'pref_api_key';
  static const String prefSpeechRate = 'pref_speech_rate';
  static const String prefSpeechVolume = 'pref_speech_volume';
  static const String prefAutoPlayTts = 'pref_auto_play_tts';
  static const String prefPauseListeningDuringTts = 'pref_pause_listening_during_tts';
  static const String prefConfidenceThreshold = 'pref_confidence_threshold';
  static const String prefSilenceTimeoutMs = 'pref_silence_timeout_ms';
  static const String prefThemeMode = 'pref_theme_mode';
  static const String prefSaveHistory = 'pref_save_history';
  static const String prefActiveMode = 'pref_active_mode';

  // Default values
  static const double defaultSpeechRate = 0.5;
  static const double defaultSpeechVolume = 1.0;
  static const bool defaultAutoPlayTts = true;
  static const bool defaultPauseListeningDuringTts = true;
  static const double defaultConfidenceThreshold = 0.6;
  static const int defaultSilenceTimeoutMs = 1500;
  static const int ttsCooldownDelayMs = 600; // Protection against TTS feedback loop

  // Default API Keys & Config
  static const String defaultGeminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  // Provider Identifiers
  static const String providerFree = 'free_default';
  static const String providerLibreTranslate = 'libre_translate';
  static const String providerOpenAI = 'openai';
  static const String providerGemini = 'gemini';
  static const String defaultTranslationProvider = providerGemini;

  // Modes
  static const String modeAutoConversation = 'auto_conversation';
  static const String modePushToTalk = 'push_to_talk';
  static const String modeManualL1ToL2 = 'manual_l1_to_l2';
  static const String modeManualL2ToL1 = 'manual_l2_to_l1';
  static const String defaultActiveMode = modePushToTalk;
}
