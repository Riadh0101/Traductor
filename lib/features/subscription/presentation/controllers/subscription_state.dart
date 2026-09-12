import '../../../../domain/entities/language.dart';
import '../../domain/models/subscription_plan.dart';

class SubscriptionState {
  final bool isPro;
  final int dailyTranslationsCount;
  final int maxFreeTranslations;
  final String? activePlanId;
  final SubscriptionPlan selectedPlan;
  final bool isLoading;
  final String? errorMessage;

  const SubscriptionState({
    this.isPro = false,
    this.dailyTranslationsCount = 0,
    this.maxFreeTranslations = 15,
    this.activePlanId,
    required this.selectedPlan,
    this.isLoading = false,
    this.errorMessage,
  });

  int get remainingFreeTranslations =>
      (maxFreeTranslations - dailyTranslationsCount).clamp(0, maxFreeTranslations);

  bool get canTranslate => isPro || dailyTranslationsCount < maxFreeTranslations;

  bool get canUseGemini => isPro;

  bool get canUseFaceToFace => isPro;

  bool get canUseAiSummary => isPro;

  static const List<String> freeAllowedLanguageCodes = ['ar', 'en', 'tr', 'fr'];

  bool isLanguageAllowed(Language language) {
    if (isPro) return true;
    return freeAllowedLanguageCodes.contains(language.isoCode);
  }

  SubscriptionState copyWith({
    bool? isPro,
    int? dailyTranslationsCount,
    int? maxFreeTranslations,
    String? activePlanId,
    SubscriptionPlan? selectedPlan,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SubscriptionState(
      isPro: isPro ?? this.isPro,
      dailyTranslationsCount: dailyTranslationsCount ?? this.dailyTranslationsCount,
      maxFreeTranslations: maxFreeTranslations ?? this.maxFreeTranslations,
      activePlanId: activePlanId ?? this.activePlanId,
      selectedPlan: selectedPlan ?? this.selectedPlan,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}
