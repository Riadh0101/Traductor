import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../history/presentation/screens/history_screen.dart';
import '../../../phrasebook/presentation/screens/phrasebook_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../../../subscription/presentation/controllers/subscription_controller.dart';
import '../../../subscription/presentation/screens/paywall_screen.dart';
import '../controllers/translator_controller.dart';
import '../controllers/translator_state.dart';
import '../widgets/ai_summary_sheet.dart';
import '../widgets/conversation_list.dart';
import '../widgets/language_selector_bar.dart';
import '../widgets/live_transcript_card.dart';
import '../widgets/mic_button.dart';
import 'face_to_face_screen.dart';

class TranslatorScreen extends ConsumerWidget {
  const TranslatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(translatorControllerProvider);
    final notifier = ref.read(translatorControllerProvider.notifier);
    final subState = ref.watch(subscriptionControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.translate_rounded, color: AppTheme.primaryIndigo),
                SizedBox(width: 8),
                Text('RealTime Translator'),
              ],
            ),
            Text(
              AppConstants.companyName,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryIndigo,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        actions: [
          // Pro Status / Upgrade Badge
          InkWell(
            onTap: () => PaywallScreen.show(context),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              decoration: BoxDecoration(
                gradient: subState.isPro
                    ? const LinearGradient(
                        colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                      )
                    : null,
                color: subState.isPro
                    ? null
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: subState.isPro
                      ? const Color(0xFFFBBF24)
                      : Theme.of(context).colorScheme.outlineVariant.withAlpha(80),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.workspace_premium_rounded,
                    size: 15,
                    color: subState.isPro ? Colors.white : AppTheme.accentAmber,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    subState.isPro ? 'PRO' : '${subState.remainingFreeTranslations}/15',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: subState.isPro ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Conversation History',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
            },
          ),
          if (state.messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: 'Clear Conversation',
              onPressed: () => _confirmClearConversation(context, notifier),
            ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Section: Two-way language selector
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: LanguageSelectorBar(),
            ),

            // Quick Pro Tools Strip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  // Face-to-Face Mode button
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: Theme.of(context).colorScheme.primary.withAlpha(80)),
                      ),
                      onPressed: () {
                        if (!subState.canUseFaceToFace) {
                          PaywallScreen.show(context, featureHighlighted: 'Face-to-Face Split Screen');
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const FaceToFaceScreen()),
                        );
                      },
                      icon: Icon(
                        subState.canUseFaceToFace ? Icons.table_restaurant_rounded : Icons.lock_outline_rounded,
                        size: 18,
                        color: subState.canUseFaceToFace ? null : AppTheme.accentAmber,
                      ),
                      label: Text(
                        subState.canUseFaceToFace ? 'Face-to-Face' : 'Face-to-Face 👑',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Smart Phrasebook button
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: Theme.of(context).colorScheme.primary.withAlpha(80)),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PhrasebookScreen()),
                        );
                      },
                      icon: const Icon(Icons.menu_book_rounded, size: 18),
                      label: const Text('Phrasebook', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ),

                  if (state.messages.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    // AI Summary button
                    IconButton.filledTonal(
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.accentAmber.withAlpha(35),
                        foregroundColor: AppTheme.accentAmber,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      tooltip: subState.canUseAiSummary ? 'AI Summary by Gemini' : 'Unlock AI Summary (Pro)',
                      icon: Icon(
                        subState.canUseAiSummary ? Icons.auto_awesome_rounded : Icons.lock_outline_rounded,
                        size: 20,
                      ),
                      onPressed: () {
                        if (!subState.canUseAiSummary) {
                          PaywallScreen.show(context, featureHighlighted: 'Gemini AI Conversation Summaries');
                          return;
                        }
                        AiSummarySheet.show(
                          context,
                          messages: state.messages,
                          targetLanguageCode: state.language1.isoCode,
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),

            // Free Tier Daily Usage Progress Banner
            if (!subState.isPro)
              GestureDetector(
                onTap: () => PaywallScreen.show(context),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: subState.canTranslate
                        ? Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(120)
                        : AppTheme.accentRose.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: subState.canTranslate
                          ? Theme.of(context).colorScheme.outlineVariant.withAlpha(60)
                          : AppTheme.accentRose.withAlpha(120),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        subState.canTranslate ? Icons.bolt_rounded : Icons.lock_clock_rounded,
                        size: 16,
                        color: subState.canTranslate ? AppTheme.accentAmber : AppTheme.accentRose,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          subState.canTranslate
                              ? 'Free translations remaining: ${subState.remainingFreeTranslations}/15 today'
                              : 'Daily limit reached (15/15). Unlock unlimited Pro.',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: subState.canTranslate
                                ? Theme.of(context).colorScheme.onSurfaceVariant
                                : AppTheme.accentRose,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.accentAmber.withAlpha(40),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'PRO',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.accentAmber,
                              ),
                            ),
                            SizedBox(width: 2),
                            Icon(Icons.arrow_forward_ios_rounded, size: 9, color: AppTheme.accentAmber),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Error Message Banner (if any)
            if (state.errorMessage != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.accentRose.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.accentRose.withAlpha(80)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: AppTheme.accentRose, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        state.errorMessage!,
                        style: const TextStyle(
                          color: AppTheme.accentRose,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 16, color: AppTheme.accentRose),
                      visualDensity: VisualDensity.compact,
                      onPressed: () => notifier.toggleListening(),
                    ),
                  ],
                ),
              ),

            // Middle Section: Conversation list bubbles
            Expanded(
              child: ConversationList(messages: state.messages),
            ),

            // Live Partial Speech Card
            const LiveTranscriptCard(),

            // Bottom Section: Large Microphone & Controls
            Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 8),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const MicButton(),

                  // Pause / Stop auxiliary button when listening
                  if (state.status == TranslatorStatus.listening)
                    Positioned(
                      right: 32,
                      child: IconButton.filledTonal(
                        onPressed: notifier.stopListening,
                        icon: const Icon(Icons.stop_rounded),
                        tooltip: 'Stop Listening',
                        style: IconButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // App Build & Company Branding Tag
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(120),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant.withAlpha(60),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_user_rounded, size: 13, color: AppTheme.accentEmerald),
                    const SizedBox(width: 6),
                    Text(
                      AppConstants.companyName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '• v${AppConstants.appVersion} (Build #${AppConstants.appBuildNumber})',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                        color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(180),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmClearConversation(BuildContext context, TranslatorController notifier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Conversation?'),
        content: const Text('Are you sure you want to clear the current conversation screen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.accentRose),
            onPressed: () {
              notifier.clearConversation();
              Navigator.pop(ctx);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
