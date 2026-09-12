# RealTime Two-Way Voice Translator (Android)

A commercial-grade, real-time two-way voice translation application built with **Flutter & Dart**, featuring **Clean Architecture**, **Riverpod** state management, zero-latency two-way language detection, feedback-loop prevention, SQLite conversation history, and a Material 3 design system.

---

## Key Features

1. **Two-Way Voice Translation**:
   - Seamless conversations between two speakers speaking different languages (e.g. Arabic ⇄ Turkish, English ⇄ Arabic, etc.).
   - Continuously listens, detects which language is being spoken, translates into the other language, displays both transcripts, and speaks the translation aloud.

2. **Automatic Two-Way Language Detection**:
   - Zero-latency local discriminator specifically tailored to the two selected languages.
   - Unicode script analysis (Arabic, Cyrillic, CJK, Hangul, Kana) + Latin diacritic analysis (Turkish `ç, ğ, ı, ö, ş, ü`, etc.) + stop-word frequency modeling.
   - Automatic turn-taking speaker alternating bias when confidence is tied.

3. **Audio Feedback-Loop Prevention**:
   - When the app speaks the translated sentence through device speakers, speech recognition is automatically paused and resumed after speech completion + a 600ms cooldown buffer to avoid translating its own voice.

4. **Multiple Modes**:
   - **Auto Detect ⇄**: Continuous listening and automatic two-way translation.
   - **Push to Talk 🎙️**: Hold to speak, release to translate (ideal for noisy environments).
   - **Manual Direction**: Lock translation direction ($L_1 \rightarrow L_2$ or $L_2 \rightarrow L_1$).

5. **Configurable Translation Providers**:
   - **Free Built-in Engine**: Works out-of-the-box (MyMemory API with smart caching and Lingva fallback) — no API keys required!
   - **LibreTranslate**: Configurable custom self-hosted or public server endpoint + optional API key.
   - **OpenAI GPT-4o-mini**: Natural conversational translation with idiom and context preservation.
   - **Google Gemini 1.5 Flash**: Low-latency AI translation.

6. **Conversation History & Privacy**:
   - Local SQLite database persists sessions and messages with timestamp, copy, share, and speech replay.
   - Audio is processed on-device and never stored permanently.

---

## Supported Languages

Initially pre-configured with 12 world languages:
- 🇸🇦 **Arabic** (`ar-SA`, RTL)
- 🇹🇷 **Turkish** (`tr-TR`)
- 🇺🇸 **English** (`en-US`)
- 🇫🇷 **French** (`fr-FR`)
- 🇪🇸 **Spanish** (`es-ES`)
- 🇩🇪 **German** (`de-DE`)
- 🇮🇹 **Italian** (`it-IT`)
- 🇵🇹 **Portuguese** (`pt-PT`)
- 🇷🇺 **Russian** (`ru-RU`)
- 🇨🇳 **Chinese** (`zh-CN`)
- 🇯🇵 **Japanese** (`ja-JP`)
- 🇰🇷 **Korean** (`ko-KR`)

---

## Clean Architecture Structure

```
lib/
├── core/
│   ├── constants/            # AppConstants, SupportedLanguages
│   ├── errors/               # AppFailure hierarchy
│   ├── network/              # NetworkInfo (connectivity check)
│   ├── permissions/          # PermissionService (microphone permission handling)
│   ├── theme/                # Material 3 light and dark theme configurations
│   └── utils/                # Debouncer
├── data/
│   ├── datasources/          # DatabaseHelper (SQLite schema & queries)
│   ├── models/               # ConversationSessionModel, TranslationMessageModel
│   └── repositories/         # HistoryRepositoryImpl, TranslationRepositoryImpl
├── domain/
│   ├── entities/             # Language, TranslationMessage, ConversationSession
│   └── repositories/         # HistoryRepository, TranslationRepository
├── services/
│   ├── language_detection/   # TwoWayLanguageDetector
│   ├── speech/               # SpeechRecognitionService (speech_to_text abstraction)
│   ├── translation/          # TranslationProvider, Free, LibreTranslate, AI (OpenAI/Gemini)
│   └── tts/                  # TextToSpeechService (flutter_tts abstraction)
├── features/
│   ├── history/              # HistoryScreen, HistoryController
│   ├── settings/             # SettingsScreen, SettingsController
│   └── translator/           # TranslatorScreen, TranslatorController, UI Widgets
└── main.dart
```

---

## Prerequisites

- **Flutter SDK**: 3.22+ / 3.44+
- **Dart SDK**: 3.4+ / 3.12+
- **Android SDK**: Android 10+ (API level 29+, minSdk 21)
- **Physical Device or Android Emulator** with Google Play Services (required for Android SpeechRecognizer & TTS engines).

---

## How to Install & Run

1. **Clone or open the repository**:
   ```bash
   cd d:/Apps/Antigravity/Traductor
   ```

2. **Get dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run on an Android device or emulator**:
   ```bash
   flutter run
   ```

---

## How to Configure API Keys

The app works immediately out of the box with the **Free Built-In Engine**. To use OpenAI, Google Gemini, or a private LibreTranslate server:

1. Tap the **Settings** icon (gear) in the top-right corner of the app.
2. Under **Translation Engine**, select:
   - **LibreTranslate**: Enter your custom server URL (e.g. `https://translate.example.com/`) and API key.
   - **OpenAI GPT-4o-mini**: Enter your OpenAI API key (`sk-...`).
   - **Google Gemini 1.5 Flash**: Enter your Google AI Studio API key (`AIza...`).
3. Settings are encrypted and saved in device local preferences (`SharedPreferences`).

---

## How to Build Android APK

### Build Debug APK:
```bash
flutter build apk --debug
```
Output: `build/app/outputs/flutter-apk/app-debug.apk`

### Build Release APK:
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

---

## How to Add Another Language

Adding a new language is trivial thanks to the extensible `Language` domain entity:

1. Open `lib/core/constants/supported_languages.dart`.
2. Add your language constant:
   ```dart
   static const Language hindi = Language(
     id: 'hi',
     name: 'Hindi',
     nativeName: 'हिन्दी',
     flagEmoji: '🇮🇳',
     isoCode: 'hi',
     sttLocale: 'hi-IN',
     ttsLocale: 'hi-IN',
     isRtl: false,
   );
   ```
3. Add `hindi` to the `SupportedLanguages.all` list.
4. Optionally, add its character patterns or common stop words in `lib/services/language_detection/two_way_language_detector.dart` for enhanced detection accuracy.

---

## How to Add Another Translation Provider

To integrate a new translation service (e.g. DeepL, Microsoft Azure Translator, or on-device model):

1. Implement the `TranslationProvider` interface from `lib/services/translation/translation_provider.dart`:
   ```dart
   class DeepLTranslationProvider implements TranslationProvider {
     @override
     String get id => 'deepl';

     @override
     String get name => 'DeepL API';

     @override
     bool get requiresApiKey => true;

     @override
     bool get requiresApiUrl => false;

     @override
     Future<TranslationResult> translate(TranslationRequest request) async {
       // Call DeepL API endpoint
       return TranslationResult(
         translatedText: '...',
         providerName: name,
       );
     }
   }
   ```
2. Register the provider in `lib/data/repositories/translation_repository_impl.dart`:
   ```dart
   _providers['deepl'] = DeepLTranslationProvider();
   ```
3. Add the provider option to `lib/features/settings/presentation/screens/settings_screen.dart`.

---

## Running Automated Tests

Run the full test suite (unit tests and widget tests):
```bash
flutter test
```

Analyze the project for lints and static type safety:
```bash
flutter analyze
```

---

## License
MIT
