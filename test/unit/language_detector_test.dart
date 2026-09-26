import 'package:flutter_test/flutter_test.dart';
import 'package:traductor/core/constants/supported_languages.dart';
import 'package:traductor/services/language_detection/two_way_language_detector.dart';

void main() {
  group('TwoWayLanguageDetector Tests', () {
    late TwoWayLanguageDetector detector;

    setUp(() {
      detector = TwoWayLanguageDetector();
    });

    test('detects Arabic correctly against Turkish', () {
      const arabicText = 'السلام عليكم، أين أقرب محطة مترو؟';
      final result = detector.detectBetween(
        text: arabicText,
        languageA: SupportedLanguages.arabic,
        languageB: SupportedLanguages.turkish,
      );

      expect(result.detectedLanguage.isoCode, 'ar');
      expect(result.confidence, greaterThanOrEqualTo(0.9));
    });

    test('detects Turkish correctly against Arabic', () {
      const turkishText = 'En yakın metro istasyonu şu tarafta.';
      final result = detector.detectBetween(
        text: turkishText,
        languageA: SupportedLanguages.arabic,
        languageB: SupportedLanguages.turkish,
      );

      expect(result.detectedLanguage.isoCode, 'tr');
      expect(result.confidence, greaterThanOrEqualTo(0.7));
    });

    test('detects Turkish specific characters correctly', () {
      const turkishText = 'Teşekkür ederim, çok sağ olun';
      final result = detector.detectBetween(
        text: turkishText,
        languageA: SupportedLanguages.english,
        languageB: SupportedLanguages.turkish,
      );

      expect(result.detectedLanguage.isoCode, 'tr');
      expect(result.confidence, greaterThanOrEqualTo(0.9));
    });

    test('detects English stop-words against Turkish', () {
      const englishText = 'Where is the nearest metro station?';
      final result = detector.detectBetween(
        text: englishText,
        languageA: SupportedLanguages.english,
        languageB: SupportedLanguages.turkish,
      );

      expect(result.detectedLanguage.isoCode, 'en');
      expect(result.confidence, greaterThanOrEqualTo(0.7));
    });

    test('handles conversation turn bias on ambiguous text', () {
      const neutralText = 'Metro';
      final result = detector.detectBetween(
        text: neutralText,
        languageA: SupportedLanguages.arabic,
        languageB: SupportedLanguages.turkish,
        lastSpokenLanguage: SupportedLanguages.arabic,
      );

      // Should prefer alternating to Turkish
      expect(result.detectedLanguage.isoCode, 'tr');
    });

    test('detects Urdu correctly against English', () {
      const urduText = 'آپ کیسے ہیں؟ شکریہ';
      final result = detector.detectBetween(
        text: urduText,
        languageA: SupportedLanguages.urdu,
        languageB: SupportedLanguages.english,
      );

      expect(result.detectedLanguage.isoCode, 'ur');
      expect(result.confidence, greaterThanOrEqualTo(0.9));
    });

    test('detects Urdu distinctive characters against Arabic', () {
      const urduText = 'گاڑی کہاں کھڑی ہے؟';
      final result = detector.detectBetween(
        text: urduText,
        languageA: SupportedLanguages.arabic,
        languageB: SupportedLanguages.urdu,
      );

      expect(result.detectedLanguage.isoCode, 'ur');
      expect(result.confidence, greaterThanOrEqualTo(0.9));
    });

    test('detects Swahili stop-words against English', () {
      const swahiliText = 'Habari za asubuhi, asante sana';
      final result = detector.detectBetween(
        text: swahiliText,
        languageA: SupportedLanguages.swahili,
        languageB: SupportedLanguages.english,
      );

      expect(result.detectedLanguage.isoCode, 'sw');
      expect(result.confidence, greaterThanOrEqualTo(0.7));
    });

    test('detects Hindi Devanagari script against English', () {
      const hindiText = 'नमस्ते, आप कैसे हैं? धन्यवाद';
      final result = detector.detectBetween(
        text: hindiText,
        languageA: SupportedLanguages.hindi,
        languageB: SupportedLanguages.english,
      );

      expect(result.detectedLanguage.isoCode, 'hi');
      expect(result.confidence, greaterThanOrEqualTo(0.9));
    });

    test('detects Persian distinctive characters against Arabic', () {
      const farsiText = 'چطور هستید؟ خیلی ممنون';
      final result = detector.detectBetween(
        text: farsiText,
        languageA: SupportedLanguages.arabic,
        languageB: SupportedLanguages.persian,
      );

      expect(result.detectedLanguage.isoCode, 'fa');
      expect(result.confidence, greaterThanOrEqualTo(0.9));
    });

    test('detects Thai script against English', () {
      const thaiText = 'สวัสดีครับ ขอบคุณมากครับ';
      final result = detector.detectBetween(
        text: thaiText,
        languageA: SupportedLanguages.thai,
        languageB: SupportedLanguages.english,
      );

      expect(result.detectedLanguage.isoCode, 'th');
      expect(result.confidence, greaterThanOrEqualTo(0.9));
    });

    test('detects Greek script against English', () {
      const greekText = 'Γεια σας, ευχαριστώ πολύ';
      final result = detector.detectBetween(
        text: greekText,
        languageA: SupportedLanguages.greek,
        languageB: SupportedLanguages.english,
      );

      expect(result.detectedLanguage.isoCode, 'el');
      expect(result.confidence, greaterThanOrEqualTo(0.9));
    });

    test('detects Indonesian stop-words against English', () {
      const indoText = 'Halo, terima kasih banyak dan sampai jumpa';
      final result = detector.detectBetween(
        text: indoText,
        languageA: SupportedLanguages.indonesian,
        languageB: SupportedLanguages.english,
      );

      expect(result.detectedLanguage.isoCode, 'id');
      expect(result.confidence, greaterThanOrEqualTo(0.7));
    });

    test('detects Ukrainian distinctive characters against Russian', () {
      const ukrText = 'Привіт, як справи? Дякую';
      final result = detector.detectBetween(
        text: ukrText,
        languageA: SupportedLanguages.russian,
        languageB: SupportedLanguages.ukrainian,
      );

      expect(result.detectedLanguage.isoCode, 'uk');
      expect(result.confidence, greaterThanOrEqualTo(0.9));
    });

    test('detects Azerbaijani distinctive characters and stop-words against Turkish', () {
      const azeriText = 'Salam, necəsiniz? Təşəkkür edirəm';
      final result = detector.detectBetween(
        text: azeriText,
        languageA: SupportedLanguages.turkish,
        languageB: SupportedLanguages.azerbaijani,
      );

      expect(result.detectedLanguage.isoCode, 'az');
      expect(result.confidence, greaterThanOrEqualTo(0.75));
    });
  });
}
