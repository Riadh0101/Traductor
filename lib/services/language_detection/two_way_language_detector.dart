import '../../domain/entities/language.dart';

class DetectionResult {
  final Language detectedLanguage;
  final double confidence; // 0.0 to 1.0
  final String reasoning;

  const DetectionResult({
    required this.detectedLanguage,
    required this.confidence,
    required this.reasoning,
  });
}

class TwoWayLanguageDetector {
  static final RegExp _arabicPattern = RegExp(r'[\u0600-\u06FF\u0750-\u077F\uFB50-\uFDFF\uFE70-\uFEFF]');
  static final RegExp _cyrillicPattern = RegExp(r'[\u0400-\u04FF]');
  static final RegExp _cjkPattern = RegExp(r'[\u4E00-\u9FFF]');
  static final RegExp _japanesePattern = RegExp(r'[\u3040-\u309F\u30A0-\u30FF]');
  static final RegExp _koreanPattern = RegExp(r'[\uAC00-\uD7AF\u1100-\u11FF]');

  // Diacritics specific to languages
  static final Map<String, RegExp> _specificCharPatterns = {
    'tr': RegExp(r'[çğıöşüÇĞİÖŞÜ]'),
    'de': RegExp(r'[äöüßÄÖÜ]'),
    'es': RegExp(r'[ñáéíóúÁÉÍÓÚ¿¡]'),
    'fr': RegExp(r'[œæçéèêëàâîïôùûüÇÉÈÊËÀÂÎÏÔÙÛÜ]'),
    'pt': RegExp(r'[ãõáéíóúâêôçÃÕÁÉÍÓÚÂÊÔÇ]'),
    'it': RegExp(r'[àèéìíîòóùú]'),
    'ur': RegExp(r'[ٹڈڑںےہپچژگ]'),
  };

  // Top stop words for Latin & common languages
  static final Map<String, Set<String>> _stopWords = {
    'en': {
      'the', 'is', 'in', 'at', 'of', 'to', 'a', 'and', 'it', 'on',
      'that', 'this', 'for', 'you', 'what', 'where', 'how', 'why',
      'are', 'was', 'with', 'have', 'can', 'please', 'hello', 'yes',
      'no', 'good', 'thank', 'thanks', 'near', 'station', 'direction'
    },
    'tr': {
      'bir', 've', 'bu', 'da', 'de', 'icin', 'için', 'ile', 'mi', 'mu',
      'cok', 'çok', 'en', 'var', 'yok', 'ne', 'o', 'ben', 'sen', 'biz',
      'siz', 'nerede', 'tarafta', 'evet', 'hayır', 'hayir', 'tamam',
      'lutfen', 'lütfen', 'merhaba', 'yakin', 'yakın', 'su', 'şu'
    },
    'ar': {
      'في', 'من', 'إلى', 'على', 'هذا', 'هذه', 'أن', 'ما', 'لا', 'مع',
      'هو', 'هي', 'أين', 'كيف', 'نعم', 'شكرا', 'مرحبا', 'أقرب', 'محطة'
    },
    'ur': {
      'ہے', 'ہیں', 'کا', 'کی', 'کے', 'کو', 'میں', 'سے', 'پر', 'اور',
      'تھا', 'تھی', 'تھے', 'یہ', 'وہ', 'کیا', 'نہیں', 'شکریہ', 'سلام',
      'آپ', 'ہم', 'کیسے', 'کہاں', 'بہت', 'اچھا', 'ہوں'
    },
    'sw': {
      'ya', 'na', 'wa', 'kwa', 'katika', 'ni', 'za', 'la', 'kuwa',
      'cha', 'huu', 'hapa', 'ndiyo', 'hapana', 'asante', 'habari',
      'jambo', 'tafadhali', 'wapi', 'yake', 'yako', 'sana', 'nzuri'
    },
    'fr': {
      'le', 'la', 'les', 'un', 'une', 'des', 'et', 'est', 'en', 'du',
      'de', 'que', 'qui', 'dans', 'pour', 'avec', 'où', 'comment', 'oui',
      'non', 'bonjour', 'merci', 'près'
    },
    'es': {
      'el', 'la', 'los', 'las', 'un', 'una', 'de', 'en', 'y', 'es',
      'que', 'por', 'para', 'con', 'dónde', 'cómo', 'sí', 'no', 'hola',
      'gracias', 'cerca'
    },
    'de': {
      'der', 'die', 'das', 'ein', 'eine', 'und', 'ist', 'in', 'zu',
      'den', 'mit', 'für', 'wo', 'wie', 'ja', 'nein', 'danke', 'hallo',
      'woher', 'bitte'
    },
    'it': {
      'il', 'la', 'lo', 'i', 'gli', 'le', 'un', 'uno', 'una', 'e', 'è',
      'di', 'a', 'da', 'in', 'con', 'su', 'per', 'tra', 'dove', 'come',
      'grazie', 'ciao'
    },
    'pt': {
      'o', 'a', 'os', 'as', 'um', 'uma', 'e', 'é', 'de', 'do', 'da',
      'em', 'no', 'na', 'para', 'por', 'com', 'onde', 'como', 'obrigado',
      'olá', 'sim', 'não'
    },
    'ru': {
      'и', 'в', 'не', 'на', 'я', 'что', 'тот', 'быть', 'с', 'он',
      'а', 'как', 'по', 'но', 'они', 'к', 'у', 'ты', 'где', 'да', 'нет',
      'привет', 'спасибо'
    },
  };

  /// Disambiguates between [languageA] and [languageB] for a given [text].
  /// [lastSpokenLanguage] can be passed to apply conversation turn-taking bias when confidence is tied.
  DetectionResult detectBetween({
    required String text,
    required Language languageA,
    required Language languageB,
    Language? lastSpokenLanguage,
  }) {
    final cleanText = text.trim();
    if (cleanText.isEmpty) {
      final fallback = lastSpokenLanguage == languageA ? languageB : languageA;
      return DetectionResult(
        detectedLanguage: fallback,
        confidence: 0.5,
        reasoning: 'Empty text, default to conversation turn',
      );
    }

    // 1. Script Disambiguation (Deterministic for non-Latin scripts)
    final scriptResult = _checkDistinctScripts(cleanText, languageA, languageB);
    if (scriptResult != null) {
      return scriptResult;
    }

    // 2. Specific Character/Diacritic Check
    final charScoreA = _countSpecificChars(cleanText, languageA.isoCode);
    final charScoreB = _countSpecificChars(cleanText, languageB.isoCode);

    if (charScoreA > 0 && charScoreB == 0) {
      return DetectionResult(
        detectedLanguage: languageA,
        confidence: 0.95,
        reasoning: 'Distinctive characters found for ${languageA.name}',
      );
    } else if (charScoreB > 0 && charScoreA == 0) {
      return DetectionResult(
        detectedLanguage: languageB,
        confidence: 0.95,
        reasoning: 'Distinctive characters found for ${languageB.name}',
      );
    }

    // 3. Stop Words Frequency Matching
    final words = cleanText.toLowerCase().split(RegExp(r'[\s\p{P}]+', unicode: true));
    int scoreA = 0;
    int scoreB = 0;

    final setA = _stopWords[languageA.isoCode] ?? {};
    final setB = _stopWords[languageB.isoCode] ?? {};

    for (final word in words) {
      if (word.isEmpty) continue;
      if (setA.contains(word)) scoreA++;
      if (setB.contains(word)) scoreB++;
    }

    if (scoreA > scoreB) {
      final confidence = (0.7 + (scoreA - scoreB) * 0.1).clamp(0.7, 0.95);
      return DetectionResult(
        detectedLanguage: languageA,
        confidence: confidence,
        reasoning: 'Stop-word matches for ${languageA.name} ($scoreA vs $scoreB)',
      );
    } else if (scoreB > scoreA) {
      final confidence = (0.7 + (scoreB - scoreA) * 0.1).clamp(0.7, 0.95);
      return DetectionResult(
        detectedLanguage: languageB,
        confidence: confidence,
        reasoning: 'Stop-word matches for ${languageB.name} ($scoreB vs $scoreA)',
      );
    }

    // 4. Conversation Turn Bias
    // In two-way conversations, speakers typically alternate.
    if (lastSpokenLanguage != null) {
      final alternate = (lastSpokenLanguage == languageA) ? languageB : languageA;
      return DetectionResult(
        detectedLanguage: alternate,
        confidence: 0.65,
        reasoning: 'Turn-taking alternating bias from last spoken ${lastSpokenLanguage.name}',
      );
    }

    // 5. Default fallback to Language A
    return DetectionResult(
      detectedLanguage: languageA,
      confidence: 0.60,
      reasoning: 'Fallback to primary selected language',
    );
  }

  DetectionResult? _checkDistinctScripts(String text, Language langA, Language langB) {
    // Check Arabic / Perso-Arabic script
    final arabicCount = _arabicPattern.allMatches(text).length;
    if (arabicCount > 0) {
      final aIsArabicFamily = langA.isoCode == 'ar' || langA.isoCode == 'ur';
      final bIsArabicFamily = langB.isoCode == 'ar' || langB.isoCode == 'ur';

      if (aIsArabicFamily && !bIsArabicFamily) {
        return DetectionResult(
          detectedLanguage: langA,
          confidence: 0.99,
          reasoning: '${langA.name} script detected ($arabicCount characters)',
        );
      }
      if (bIsArabicFamily && !aIsArabicFamily) {
        return DetectionResult(
          detectedLanguage: langB,
          confidence: 0.99,
          reasoning: '${langB.name} script detected ($arabicCount characters)',
        );
      }
      // If both use Arabic script (e.g. Arabic vs Urdu), let character & stop-word analysis decide!
    }

    // Check Cyrillic (Russian)
    final cyrillicCount = _cyrillicPattern.allMatches(text).length;
    if (cyrillicCount > 0) {
      if (langA.isoCode == 'ru') {
        return DetectionResult(
          detectedLanguage: langA,
          confidence: 0.99,
          reasoning: 'Cyrillic script detected',
        );
      }
      if (langB.isoCode == 'ru') {
        return DetectionResult(
          detectedLanguage: langB,
          confidence: 0.99,
          reasoning: 'Cyrillic script detected',
        );
      }
    }

    // Check Japanese (Kana)
    final japaneseCount = _japanesePattern.allMatches(text).length;
    if (japaneseCount > 0) {
      if (langA.isoCode == 'ja') {
        return DetectionResult(
          detectedLanguage: langA,
          confidence: 0.99,
          reasoning: 'Japanese Kana detected',
        );
      }
      if (langB.isoCode == 'ja') {
        return DetectionResult(
          detectedLanguage: langB,
          confidence: 0.99,
          reasoning: 'Japanese Kana detected',
        );
      }
    }

    // Check Korean (Hangul)
    final koreanCount = _koreanPattern.allMatches(text).length;
    if (koreanCount > 0) {
      if (langA.isoCode == 'ko') {
        return DetectionResult(
          detectedLanguage: langA,
          confidence: 0.99,
          reasoning: 'Korean Hangul detected',
        );
      }
      if (langB.isoCode == 'ko') {
        return DetectionResult(
          detectedLanguage: langB,
          confidence: 0.99,
          reasoning: 'Korean Hangul detected',
        );
      }
    }

    // Check CJK (Chinese)
    final cjkCount = _cjkPattern.allMatches(text).length;
    if (cjkCount > 0) {
      if (langA.isoCode == 'zh') {
        return DetectionResult(
          detectedLanguage: langA,
          confidence: 0.99,
          reasoning: 'Chinese characters detected',
        );
      }
      if (langB.isoCode == 'zh') {
        return DetectionResult(
          detectedLanguage: langB,
          confidence: 0.99,
          reasoning: 'Chinese characters detected',
        );
      }
    }

    return null;
  }

  int _countSpecificChars(String text, String isoCode) {
    final pattern = _specificCharPatterns[isoCode];
    if (pattern == null) return 0;
    return pattern.allMatches(text).length;
  }
}
