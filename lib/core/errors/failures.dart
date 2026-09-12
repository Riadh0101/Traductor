abstract class AppFailure {
  final String message;
  final dynamic cause;

  const AppFailure(this.message, [this.cause]);

  @override
  String toString() => message;
}

class NetworkFailure extends AppFailure {
  const NetworkFailure([super.message = 'No internet connection available.', super.cause]);
}

class TranslationFailure extends AppFailure {
  const TranslationFailure([super.message = 'Translation failed. Please check network or API settings.', super.cause]);
}

class SpeechRecognitionFailure extends AppFailure {
  const SpeechRecognitionFailure([super.message = 'Speech recognition error occurred.', super.cause]);
}

class TtsFailure extends AppFailure {
  const TtsFailure([super.message = 'Text-to-speech engine error occurred.', super.cause]);
}

class PermissionFailure extends AppFailure {
  const PermissionFailure([super.message = 'Microphone permission is required for voice translation.', super.cause]);
}

class DatabaseFailure extends AppFailure {
  const DatabaseFailure([super.message = 'Database operation failed.', super.cause]);
}
