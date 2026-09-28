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

  static const Language indonesian = Language(
    id: 'id',
    name: 'Indonesian',
    nativeName: 'Bahasa Indonesia',
    flagEmoji: '🇮🇩',
    isoCode: 'id',
    sttLocale: 'id-ID',
    ttsLocale: 'id-ID',
    isRtl: false,
  );

  static const Language bengali = Language(
    id: 'bn',
    name: 'Bengali',
    nativeName: 'বাংলা',
    flagEmoji: '🇧🇩',
    isoCode: 'bn',
    sttLocale: 'bn-BD',
    ttsLocale: 'bn-BD',
    isRtl: false,
  );

  static const Language persian = Language(
    id: 'fa',
    name: 'Persian',
    nativeName: 'فارسی',
    flagEmoji: '🇮🇷',
    isoCode: 'fa',
    sttLocale: 'fa-IR',
    ttsLocale: 'fa-IR',
    isRtl: true,
  );

  static const Language thai = Language(
    id: 'th',
    name: 'Thai',
    nativeName: 'ไทย',
    flagEmoji: '🇹🇭',
    isoCode: 'th',
    sttLocale: 'th-TH',
    ttsLocale: 'th-TH',
    isRtl: false,
  );

  static const Language vietnamese = Language(
    id: 'vi',
    name: 'Vietnamese',
    nativeName: 'Tiếng Việt',
    flagEmoji: '🇻🇳',
    isoCode: 'vi',
    sttLocale: 'vi-VN',
    ttsLocale: 'vi-VN',
    isRtl: false,
  );

  static const Language malay = Language(
    id: 'ms',
    name: 'Malay',
    nativeName: 'Bahasa Melayu',
    flagEmoji: '🇲🇾',
    isoCode: 'ms',
    sttLocale: 'ms-MY',
    ttsLocale: 'ms-MY',
    isRtl: false,
  );

  static const Language dutch = Language(
    id: 'nl',
    name: 'Dutch',
    nativeName: 'Nederlands',
    flagEmoji: '🇳🇱',
    isoCode: 'nl',
    sttLocale: 'nl-NL',
    ttsLocale: 'nl-NL',
    isRtl: false,
  );

  static const Language polish = Language(
    id: 'pl',
    name: 'Polish',
    nativeName: 'Polski',
    flagEmoji: '🇵🇱',
    isoCode: 'pl',
    sttLocale: 'pl-PL',
    ttsLocale: 'pl-PL',
    isRtl: false,
  );

  static const Language greek = Language(
    id: 'el',
    name: 'Greek',
    nativeName: 'Ελληνικά',
    flagEmoji: '🇬🇷',
    isoCode: 'el',
    sttLocale: 'el-GR',
    ttsLocale: 'el-GR',
    isRtl: false,
  );

  static const Language ukrainian = Language(
    id: 'uk',
    name: 'Ukrainian',
    nativeName: 'Українська',
    flagEmoji: '🇺🇦',
    isoCode: 'uk',
    sttLocale: 'uk-UA',
    ttsLocale: 'uk-UA',
    isRtl: false,
  );

  static const Language azerbaijani = Language(
    id: 'az',
    name: 'Azerbaijani',
    nativeName: 'Azərbaycan dili',
    flagEmoji: '🇦🇿',
    isoCode: 'az',
    sttLocale: 'az-AZ',
    ttsLocale: 'az-AZ',
    isRtl: false,
  );

  static const Language uzbek = Language(
    id: 'uz',
    name: 'Uzbek',
    nativeName: 'Oʻzbekcha',
    flagEmoji: '🇺🇿',
    isoCode: 'uz',
    sttLocale: 'uz-UZ',
    ttsLocale: 'uz-UZ',
    isRtl: false,
  );

  static const Language kazakh = Language(
    id: 'kk',
    name: 'Kazakh',
    nativeName: 'Қазақша',
    flagEmoji: '🇰🇿',
    isoCode: 'kk',
    sttLocale: 'kk-KZ',
    ttsLocale: 'kk-KZ',
    isRtl: false,
  );

  static const Language filipino = Language(
    id: 'tl',
    name: 'Tagalog (Filipino)',
    nativeName: 'Tagalog',
    flagEmoji: '🇵🇭',
    isoCode: 'tl',
    sttLocale: 'fil-PH',
    ttsLocale: 'fil-PH',
    isRtl: false,
  );

  static const Language tamil = Language(
    id: 'ta',
    name: 'Tamil',
    nativeName: 'தமிழ்',
    flagEmoji: '🇮🇳',
    isoCode: 'ta',
    sttLocale: 'ta-IN',
    ttsLocale: 'ta-IN',
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
    hindi,
    indonesian,
    bengali,
    persian,
    thai,
    vietnamese,
    malay,
    dutch,
    polish,
    greek,
    ukrainian,
    azerbaijani,
    uzbek,
    kazakh,
    filipino,
    tamil,
  ];

  static Language fromIsoCode(String code, {Language fallback = english}) {
    final lower = code.toLowerCase().trim();
    return all.firstWhere(
      (lang) =>
          lang.isoCode == lower ||
          lang.id == lower ||
          lang.sttLocale.toLowerCase().startsWith(lower) ||
          (lower == 'fil' && lang.isoCode == 'tl'),
      orElse: () => fallback,
    );
  }
}
