import '../../domain/entities/language.dart';

class SupportedLanguages {
  static const Language arabic = Language(
    id: 'ar',
    name: 'Arabic',
    nativeName: 'العربية',
    flagEmoji: '🇸🇦',
    isoCode: 'ar',
    sttLocale: 'ar-SA',
    ttsLocale: 'ar-SA',
    isRtl: true,
  );

  static const Language turkish = Language(
    id: 'tr',
    name: 'Turkish',
    nativeName: 'Türkçe',
    flagEmoji: '🇹🇷',
    isoCode: 'tr',
    sttLocale: 'tr-TR',
    ttsLocale: 'tr-TR',
    isRtl: false,
  );

  static const Language english = Language(
    id: 'en',
    name: 'English',
    nativeName: 'English',
    flagEmoji: '🇺🇸',
    isoCode: 'en',
    sttLocale: 'en-US',
    ttsLocale: 'en-US',
    isRtl: false,
  );

  static const Language french = Language(
    id: 'fr',
    name: 'French',
    nativeName: 'Français',
    flagEmoji: '🇫🇷',
    isoCode: 'fr',
    sttLocale: 'fr-FR',
    ttsLocale: 'fr-FR',
    isRtl: false,
  );

  static const Language spanish = Language(
    id: 'es',
    name: 'Spanish',
    nativeName: 'Español',
    flagEmoji: '🇪🇸',
    isoCode: 'es',
    sttLocale: 'es-ES',
    ttsLocale: 'es-ES',
    isRtl: false,
  );

  static const Language german = Language(
    id: 'de',
    name: 'German',
    nativeName: 'Deutsch',
    flagEmoji: '🇩🇪',
    isoCode: 'de',
    sttLocale: 'de-DE',
    ttsLocale: 'de-DE',
    isRtl: false,
  );

  static const Language italian = Language(
    id: 'it',
    name: 'Italian',
    nativeName: 'Italiano',
    flagEmoji: '🇮🇹',
    isoCode: 'it',
    sttLocale: 'it-IT',
    ttsLocale: 'it-IT',
    isRtl: false,
  );

  static const Language portuguese = Language(
    id: 'pt',
    name: 'Portuguese',
    nativeName: 'Português',
    flagEmoji: '🇵🇹',
    isoCode: 'pt',
    sttLocale: 'pt-PT',
    ttsLocale: 'pt-PT',
    isRtl: false,
  );

  static const Language russian = Language(
    id: 'ru',
    name: 'Russian',
    nativeName: 'Русский',
    flagEmoji: '🇷🇺',
    isoCode: 'ru',
    sttLocale: 'ru-RU',
    ttsLocale: 'ru-RU',
    isRtl: false,
  );

  static const Language chinese = Language(
    id: 'zh',
    name: 'Chinese',
    nativeName: '中文',
    flagEmoji: '🇨🇳',
    isoCode: 'zh',
    sttLocale: 'zh-CN',
    ttsLocale: 'zh-CN',
    isRtl: false,
  );

  static const Language japanese = Language(
    id: 'ja',
    name: 'Japanese',
    nativeName: '日本語',
    flagEmoji: '🇯🇵',
    isoCode: 'ja',
    sttLocale: 'ja-JP',
    ttsLocale: 'ja-JP',
    isRtl: false,
  );

  static const Language korean = Language(
    id: 'ko',
    name: 'Korean',
    nativeName: '한국어',
    flagEmoji: '🇰🇷',
    isoCode: 'ko',
    sttLocale: 'ko-KR',
    ttsLocale: 'ko-KR',
    isRtl: false,
  );

  static const Language urdu = Language(
    id: 'ur',
    name: 'Urdu',
    nativeName: 'اردو',
    flagEmoji: '🇵🇰',
    isoCode: 'ur',
    sttLocale: 'ur-PK',
    ttsLocale: 'ur-PK',
    isRtl: true,
  );

  static const Language swahili = Language(
    id: 'sw',
    name: 'Swahili',
    nativeName: 'Kiswahili',
    flagEmoji: '🇹🇿',
    isoCode: 'sw',
    sttLocale: 'sw-TZ',
    ttsLocale: 'sw-TZ',
    isRtl: false,
  );

  static const List<Language> all = [
    arabic,
    turkish,
    english,
    french,
    spanish,
    german,
    italian,
    portuguese,
    russian,
    chinese,
    japanese,
    korean,
    urdu,
    swahili,
  ];

  static Language fromIsoCode(String code, {Language fallback = english}) {
    final lower = code.toLowerCase().trim();
    return all.firstWhere(
      (lang) => lang.isoCode == lower || lang.id == lower || lang.sttLocale.toLowerCase().startsWith(lower),
      orElse: () => fallback,
    );
  }
}
