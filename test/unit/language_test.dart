import 'package:flutter_test/flutter_test.dart';
import 'package:traductor/core/constants/supported_languages.dart';

void main() {
  group('SupportedLanguages Tests', () {
    test('contains at least 28 supported languages', () {
      expect(SupportedLanguages.all.length, greaterThanOrEqualTo(28));
    });

    test('verifies Arabic language configuration', () {
      final ar = SupportedLanguages.arabic;
      expect(ar.isoCode, 'ar');
      expect(ar.isRtl, true);
      expect(ar.sttLocale, 'ar-SA');
      expect(ar.ttsLocale, 'ar-SA');
    });

    test('verifies Turkish language configuration', () {
      final tr = SupportedLanguages.turkish;
      expect(tr.isoCode, 'tr');
      expect(tr.isRtl, false);
      expect(tr.sttLocale, 'tr-TR');
      expect(tr.ttsLocale, 'tr-TR');
    });

    test('verifies Urdu language configuration', () {
      final ur = SupportedLanguages.urdu;
      expect(ur.isoCode, 'ur');
      expect(ur.name, 'Urdu');
      expect(ur.nativeName, 'اردو');
      expect(ur.flagEmoji, '🇵🇰');
      expect(ur.isRtl, true);
      expect(ur.sttLocale, 'ur-PK');
      expect(ur.ttsLocale, 'ur-PK');
    });

    test('verifies Swahili language configuration', () {
      final sw = SupportedLanguages.swahili;
      expect(sw.isoCode, 'sw');
      expect(sw.name, 'Swahili');
      expect(sw.nativeName, 'Kiswahili');
      expect(sw.flagEmoji, '🇹🇿');
      expect(sw.isRtl, false);
      expect(sw.sttLocale, 'sw-TZ');
      expect(sw.ttsLocale, 'sw-TZ');
    });

    test('verifies new languages configurations (Hindi, Indonesian, Persian, etc.)', () {
      final hi = SupportedLanguages.hindi;
      expect(hi.isoCode, 'hi');
      expect(hi.name, 'Hindi');
      expect(hi.nativeName, 'हिन्दी');
      expect(hi.isRtl, false);
      expect(hi.sttLocale, 'hi-IN');

      final id = SupportedLanguages.indonesian;
      expect(id.isoCode, 'id');
      expect(id.name, 'Indonesian');
      expect(id.flagEmoji, '🇮🇩');

      final fa = SupportedLanguages.persian;
      expect(fa.isoCode, 'fa');
      expect(fa.name, 'Persian');
      expect(fa.nativeName, 'فارسی');
      expect(fa.isRtl, true);

      final th = SupportedLanguages.thai;
      expect(th.isoCode, 'th');
      expect(th.nativeName, 'ไทย');

      final vi = SupportedLanguages.vietnamese;
      expect(vi.isoCode, 'vi');
      expect(vi.nativeName, 'Tiếng Việt');

      final el = SupportedLanguages.greek;
      expect(el.isoCode, 'el');
      expect(el.nativeName, 'Ελληνικά');

      final uk = SupportedLanguages.ukrainian;
      expect(uk.isoCode, 'uk');
      expect(uk.nativeName, 'Українська');

      final az = SupportedLanguages.azerbaijani;
      expect(az.isoCode, 'az');
      expect(az.nativeName, 'Azərbaycan dili');
    });

    test('resolves language by ISO code correctly', () {
      final lang = SupportedLanguages.fromIsoCode('tr');
      expect(lang.name, 'Turkish');

      final arLang = SupportedLanguages.fromIsoCode('ar');
      expect(arLang.name, 'Arabic');

      final urLang = SupportedLanguages.fromIsoCode('ur');
      expect(urLang.name, 'Urdu');

      final swLang = SupportedLanguages.fromIsoCode('sw');
      expect(swLang.name, 'Swahili');

      final hiLang = SupportedLanguages.fromIsoCode('hi');
      expect(hiLang.name, 'Hindi');

      final faLang = SupportedLanguages.fromIsoCode('fa');
      expect(faLang.name, 'Persian');

      final fallback = SupportedLanguages.fromIsoCode('non_existing');
      expect(fallback.isoCode, 'en');
    });
  });
}
