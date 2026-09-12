import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traductor/features/settings/presentation/controllers/settings_controller.dart';
import 'package:traductor/features/translator/presentation/controllers/translator_controller.dart';
import 'package:traductor/features/translator/presentation/screens/translator_screen.dart';
import 'package:traductor/services/speech/speech_recognition_service.dart';
import 'package:traductor/services/tts/text_to_speech_service.dart';

class MockSpeechRecognitionService implements SpeechRecognitionService {
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
  }) {
    return const Stream.empty();
  }

  @override
  Future<void> stop() async {}

  @override
  Future<void> cancel() async {}
}

class MockTextToSpeechService implements TextToSpeechService {
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
  }) async {}

  @override
  Future<void> stop() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('TranslatorScreen renders UI elements correctly', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPrefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPrefs),
          speechRecognitionServiceProvider.overrideWithValue(MockSpeechRecognitionService()),
          ttsServiceProvider.overrideWithValue(MockTextToSpeechService()),
        ],
        child: const MaterialApp(
          home: TranslatorScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Title
    expect(find.text('RealTime Translator'), findsOneWidget);

    // Verify Language Selector Bar contains Arabic and Turkish
    expect(find.text('Arabic'), findsWidgets);
    expect(find.text('Turkish'), findsWidgets);
    expect(find.byTooltip('Swap Languages'), findsWidgets);

    // Verify Mic Button initial state
    expect(find.text('Hold to Speak'), findsOneWidget);

    // Verify Action Icons
    expect(find.byTooltip('Conversation History'), findsOneWidget);
    expect(find.byTooltip('Settings'), findsOneWidget);
  });

  testWidgets('Language swapping swaps positions', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPrefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPrefs),
          speechRecognitionServiceProvider.overrideWithValue(MockSpeechRecognitionService()),
          ttsServiceProvider.overrideWithValue(MockTextToSpeechService()),
        ],
        child: const MaterialApp(
          home: TranslatorScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Tap swap languages button
    await tester.tap(find.byTooltip('Swap Languages').first);
    await tester.pumpAndSettle();

    // The languages should still exist in swapped order
    expect(find.text('Arabic'), findsWidgets);
    expect(find.text('Turkish'), findsWidgets);
  });
}
