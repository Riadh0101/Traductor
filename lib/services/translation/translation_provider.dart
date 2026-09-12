class TranslationRequest {
  final String text;
  final String sourceLanguage; // ISO code e.g. "ar"
  final String targetLanguage; // ISO code e.g. "tr"
  final String? apiUrl;
  final String? apiKey;

  const TranslationRequest({
    required this.text,
    required this.sourceLanguage,
    required this.targetLanguage,
    this.apiUrl,
    this.apiKey,
  });
}

class TranslationResult {
  final String translatedText;
  final String providerName;
  final bool isFromCache;
  final String? cleanedSourceText;

  const TranslationResult({
    required this.translatedText,
    required this.providerName,
    this.isFromCache = false,
    this.cleanedSourceText,
  });
}

abstract class TranslationProvider {
  String get id;
  String get name;
  bool get requiresApiKey;
  bool get requiresApiUrl;

  Future<TranslationResult> translate(TranslationRequest request);
}
