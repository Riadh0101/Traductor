import '../../services/translation/translation_provider.dart';
import '../entities/language.dart';

abstract class TranslationRepository {
  Future<String> translate({
    required String text,
    required Language sourceLanguage,
    required Language targetLanguage,
    String? preferredProvider,
    String? apiUrl,
    String? apiKey,
  });

  Future<TranslationResult> translateDetailed({
    required String text,
    required Language sourceLanguage,
    required Language targetLanguage,
    String? preferredProvider,
    String? apiUrl,
    String? apiKey,
  });
}
