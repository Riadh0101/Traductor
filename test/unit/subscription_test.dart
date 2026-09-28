import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traductor/core/constants/supported_languages.dart';
import 'package:traductor/features/subscription/domain/models/subscription_plan.dart';
import 'package:traductor/features/subscription/presentation/controllers/subscription_controller.dart';
import 'package:traductor/features/subscription/presentation/controllers/subscription_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SubscriptionState Unit Tests', () {
    test('Initial free tier properties and limits', () {
      final state = SubscriptionState(
        selectedPlan: SubscriptionPlan.defaultPlans.first,
      );

      expect(state.isPro, isFalse);
      expect(state.dailyTranslationsCount, equals(0));
      expect(state.maxFreeTranslations, equals(15));
      expect(state.remainingFreeTranslations, equals(15));
      expect(state.canTranslate, isTrue);
      expect(state.canUseGemini, isFalse);
      expect(state.canUseFaceToFace, isFalse);
      expect(state.canUseAiSummary, isFalse);
    });

    test('Free tier allows core languages and restricts others', () {
      final state = SubscriptionState(
        selectedPlan: SubscriptionPlan.defaultPlans.first,
        isPro: false,
      );

      // Core free languages
      expect(state.isLanguageAllowed(SupportedLanguages.arabic), isTrue);
      expect(state.isLanguageAllowed(SupportedLanguages.english), isTrue);
      expect(state.isLanguageAllowed(SupportedLanguages.french), isTrue);
      expect(state.isLanguageAllowed(SupportedLanguages.turkish), isTrue);

      // Pro-exclusive languages
      expect(state.isLanguageAllowed(SupportedLanguages.urdu), isFalse);
      expect(state.isLanguageAllowed(SupportedLanguages.swahili), isFalse);
      expect(state.isLanguageAllowed(SupportedLanguages.spanish), isFalse);
      expect(state.isLanguageAllowed(SupportedLanguages.german), isFalse);
      expect(state.isLanguageAllowed(SupportedLanguages.japanese), isFalse);
    });

    test('Pro tier unlocks unlimited translations and all languages', () {
      final state = SubscriptionState(
        selectedPlan: SubscriptionPlan.defaultPlans.first,
        isPro: true,
        dailyTranslationsCount: 100,
      );

      expect(state.isPro, isTrue);
      expect(state.canTranslate, isTrue);
      expect(state.canUseGemini, isTrue);
      expect(state.canUseFaceToFace, isTrue);
      expect(state.canUseAiSummary, isTrue);

      // All 30 languages must be allowed for Pro
      for (final lang in SupportedLanguages.all) {
        expect(state.isLanguageAllowed(lang), isTrue);
      }
    });

    test('Daily quota blocks translation when limit is reached', () {
      final state = SubscriptionState(
        selectedPlan: SubscriptionPlan.defaultPlans.first,
        isPro: false,
        dailyTranslationsCount: 15,
        maxFreeTranslations: 15,
      );

      expect(state.remainingFreeTranslations, equals(0));
      expect(state.canTranslate, isFalse);
    });
  });

  group('SubscriptionPlan Unit Tests', () {
    test('Default plans contain Annual, Monthly, and Lifetime', () {
      final plans = SubscriptionPlan.defaultPlans;
      expect(plans.length, equals(3));

      final annual = plans.firstWhere((p) => p.id == 'traductor_pro_annual');
      expect(annual.isPopular, isTrue);
      expect(annual.badge, isNotNull);
      expect(annual.isLifetime, isFalse);

      final monthly = plans.firstWhere((p) => p.id == 'traductor_pro_monthly');
      expect(monthly.isPopular, isFalse);
      expect(monthly.isLifetime, isFalse);

      final lifetime = plans.firstWhere((p) => p.id == 'traductor_pro_lifetime');
      expect(lifetime.isLifetime, isTrue);
      expect(lifetime.badge, isNotNull);
    });
  });

  group('SubscriptionController Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('selectPlan updates the selected plan in state', () {
      final controller = SubscriptionController();
      final monthly = SubscriptionPlan.defaultPlans.firstWhere((p) => p.id == 'traductor_pro_monthly');

      controller.selectPlan(monthly);
      expect(controller.state.selectedPlan.id, equals('traductor_pro_monthly'));
    });

    test('setProStatusForTesting toggles Pro status and persists', () async {
      final controller = SubscriptionController();
      expect(controller.state.isPro, isFalse);

      await controller.setProStatusForTesting(true);
      expect(controller.state.isPro, isTrue);

      await controller.setProStatusForTesting(false);
      expect(controller.state.isPro, isFalse);
    });

    test('incrementTranslationUsage increases count for free user', () async {
      final controller = SubscriptionController();
      expect(controller.state.dailyTranslationsCount, equals(0));

      await controller.incrementTranslationUsage();
      expect(controller.state.dailyTranslationsCount, equals(1));
      expect(controller.state.remainingFreeTranslations, equals(14));

      await controller.resetDailyCountForTesting();
      expect(controller.state.dailyTranslationsCount, equals(0));
    });

    test('purchasePlan simulates Google Play purchase and sets Pro', () async {
      final controller = SubscriptionController();
      final annual = SubscriptionPlan.defaultPlans.first;

      final success = await controller.purchasePlan(annual);
      expect(success, isTrue);
      expect(controller.state.isPro, isTrue);
      expect(controller.state.activePlanId, equals(annual.id));
    });
  });
}
