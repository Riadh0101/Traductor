import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/subscription_plan.dart';
import '../controllers/subscription_controller.dart';

class PaywallScreen extends ConsumerWidget {
  final String? featureHighlighted;

  const PaywallScreen({
    super.key,
    this.featureHighlighted,
  });

  static Future<bool?> show(BuildContext context, {String? featureHighlighted}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PaywallScreen(featureHighlighted: featureHighlighted),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subState = ref.watch(subscriptionControllerProvider);
    final notifier = ref.read(subscriptionControllerProvider.notifier);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(60),
            blurRadius: 30,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Handle bar
            const SizedBox(height: 12),
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Top navigation
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 26),
                    onPressed: () => Navigator.pop(context, false),
                  ),
                  TextButton(
                    onPressed: () async {
                      final restored = await notifier.restorePurchases();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(restored
                                ? 'Purchases restored successfully! Welcome to Pro.'
                                : 'No active subscriptions found to restore.'),
                          ),
                        );
                        if (restored) Navigator.pop(context, true);
                      }
                    },
                    child: const Text('Restore', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // Hero Crown Badge
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF59E0B).withAlpha(80),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.workspace_premium_rounded, size: 44, color: Colors.white),
                    ),
                    const SizedBox(height: 14),

                    Text(
                      'Traductor Pro',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'بصيرة - Basira AI 2026',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.primaryIndigo,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (featureHighlighted != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.accentAmber.withAlpha(30),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.accentAmber.withAlpha(90)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.lock_open_rounded, color: AppTheme.accentAmber, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Upgrade to unlock: $featureHighlighted',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.accentAmber,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Feature Matrix
                    _buildFeatureItem(
                      icon: Icons.all_inclusive_rounded,
                      title: 'Unlimited Voice Translations',
                      subtitle: 'Speak as much as you want without daily caps',
                    ),
                    _buildFeatureItem(
                      icon: Icons.auto_awesome_rounded,
                      title: 'Gemini AI Stutter & Disfluency Sifting',
                      subtitle: 'Flawless sentence restructuring & filler removal',
                    ),
                    _buildFeatureItem(
                      icon: Icons.language_rounded,
                      title: 'All 14 Languages Unlocked',
                      subtitle: 'Urdu, Swahili, Chinese, Japanese, Russian & more',
                    ),
                    _buildFeatureItem(
                      icon: Icons.table_restaurant_rounded,
                      title: 'Face-to-Face Split Screen Mode',
                      subtitle: 'Seamless conversational flow across the table',
                    ),
                    _buildFeatureItem(
                      icon: Icons.summarize_rounded,
                      title: 'Executive AI Summaries',
                      subtitle: 'Instant takeaways, key decisions & PDF exports',
                    ),
                    _buildFeatureItem(
                      icon: Icons.menu_book_rounded,
                      title: 'Complete 7-Category Travel Phrasebook',
                      subtitle: 'Full offline access to essential phrases',
                    ),

                    const SizedBox(height: 20),

                    // Plan Cards
                    ...SubscriptionPlan.defaultPlans.map((plan) {
                      final isSelected = subState.selectedPlan.id == plan.id;

                      return GestureDetector(
                        onTap: () => notifier.selectPlan(plan),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark ? const Color(0xFF1E293B) : const Color(0xFFEEF2FF))
                                : (isDark ? const Color(0xFF1E293B).withAlpha(120) : const Color(0xFFF8FAFC)),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppTheme.primaryIndigo : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                                color: isSelected ? AppTheme.primaryIndigo : Colors.grey,
                                size: 22,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          plan.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        if (plan.badge != null) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: plan.isPopular
                                                  ? const Color(0xFFF59E0B)
                                                  : AppTheme.accentEmerald,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              plan.badge!,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      plan.subPriceString,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? Colors.white60 : Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                plan.priceString,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: AppTheme.primaryIndigo,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // Bottom CTA Button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.primaryIndigo,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      onPressed: subState.isLoading
                          ? null
                          : () async {
                              final success = await notifier.purchasePlan(subState.selectedPlan);
                              if (context.mounted) {
                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('🎉 Congratulations! You are now a Traductor Pro user.'),
                                      backgroundColor: AppTheme.accentEmerald,
                                    ),
                                  );
                                  Navigator.pop(context, true);
                                } else if (subState.errorMessage != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(subState.errorMessage!),
                                      backgroundColor: AppTheme.accentRose,
                                    ),
                                  );
                                }
                              }
                            },
                      child: subState.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              subState.selectedPlan.isLifetime
                                  ? 'Unlock Lifetime Pro (${subState.selectedPlan.priceString})'
                                  : 'Start Free Trial & Subscribe',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Secured by Google Play Billing • Cancel anytime from Google Play',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: theme.colorScheme.outline),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.primaryIndigo.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primaryIndigo, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11.5, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
