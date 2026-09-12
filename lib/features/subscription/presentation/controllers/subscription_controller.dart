import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/subscription_plan.dart';
import 'subscription_state.dart';

final subscriptionControllerProvider =
    StateNotifierProvider<SubscriptionController, SubscriptionState>((ref) {
  return SubscriptionController();
});

class SubscriptionController extends StateNotifier<SubscriptionState> {
  static const String _keyIsPro = 'pref_is_pro_user';
  static const String _keyDailyCount = 'pref_daily_translations_count';
  static const String _keyLastDate = 'pref_last_translation_date';
  static const String _keyActivePlan = 'pref_active_subscription_plan';

  SubscriptionController()
      : super(SubscriptionState(selectedPlan: SubscriptionPlan.defaultPlans.first)) {
    _loadSubscriptionData();
  }

  Future<void> _loadSubscriptionData() async {
    final prefs = await SharedPreferences.getInstance();
    final isPro = prefs.getBool(_keyIsPro) ?? false;
    final activePlan = prefs.getString(_keyActivePlan);

    final lastDateStr = prefs.getString(_keyLastDate);
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month}-${now.day}';

    int count = 0;
    if (lastDateStr == todayStr) {
      count = prefs.getInt(_keyDailyCount) ?? 0;
    } else {
      // New day, reset count
      await prefs.setString(_keyLastDate, todayStr);
      await prefs.setInt(_keyDailyCount, 0);
    }

    state = state.copyWith(
      isPro: isPro,
      dailyTranslationsCount: count,
      activePlanId: activePlan,
    );
  }

  void selectPlan(SubscriptionPlan plan) {
    state = state.copyWith(selectedPlan: plan);
  }

  Future<void> incrementTranslationUsage() async {
    if (state.isPro) return; // Unlimited for Pro

    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month}-${now.day}';

    final newCount = state.dailyTranslationsCount + 1;
    await prefs.setString(_keyLastDate, todayStr);
    await prefs.setInt(_keyDailyCount, newCount);

    state = state.copyWith(dailyTranslationsCount: newCount);
  }

  Future<bool> purchasePlan(SubscriptionPlan plan) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Simulate Google Play Billing handshake and verification
      await Future.delayed(const Duration(milliseconds: 900));

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsPro, true);
      await prefs.setString(_keyActivePlan, plan.id);

      state = state.copyWith(
        isPro: true,
        activePlanId: plan.id,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to process purchase: $e',
      );
      return false;
    }
  }

  Future<bool> restorePurchases() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await Future.delayed(const Duration(milliseconds: 800));
      final prefs = await SharedPreferences.getInstance();
      final isPro = prefs.getBool(_keyIsPro) ?? false;

      state = state.copyWith(
        isPro: isPro,
        isLoading: false,
      );
      return isPro;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Could not restore purchases: $e',
      );
      return false;
    }
  }

  /// Toggle Pro for testing & verification
  Future<void> setProStatusForTesting(bool isPro) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsPro, isPro);
    state = state.copyWith(isPro: isPro);
  }

  Future<void> resetDailyCountForTesting() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyDailyCount, 0);
    state = state.copyWith(dailyTranslationsCount: 0);
  }
}
