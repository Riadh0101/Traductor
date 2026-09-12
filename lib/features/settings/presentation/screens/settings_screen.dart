// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../history/presentation/controllers/history_controller.dart';
import '../../../subscription/presentation/controllers/subscription_controller.dart';
import '../../../subscription/presentation/screens/paywall_screen.dart';
import '../controllers/settings_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final notifier = ref.read(settingsControllerProvider.notifier);
    final subState = ref.watch(subscriptionControllerProvider);
    final subNotifier = ref.read(subscriptionControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Subscription & License Section
          _buildSectionHeader(context, 'Subscription & License', Icons.workspace_premium_rounded),
          Card(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: subState.isPro
                    ? const Color(0xFFF59E0B)
                    : Theme.of(context).colorScheme.outlineVariant.withAlpha(60),
                width: subState.isPro ? 1.5 : 1,
              ),
            ),
            child: Container(
              decoration: subState.isPro
                  ? BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFFF59E0B).withAlpha(25),
                          const Color(0xFFD97706).withAlpha(10),
                        ],
                      ),
                    )
                  : null,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: subState.isPro
                              ? const Color(0xFFF59E0B)
                              : Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.workspace_premium_rounded,
                          color: subState.isPro ? Colors.white : AppTheme.accentAmber,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subState.isPro ? 'Traductor Pro Active' : 'Free Tier',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              subState.isPro
                                  ? 'All features unlocked • Unlimited translations'
                                  : '${subState.remainingFreeTranslations}/15 free translations remaining today',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (subState.isPro)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.accentEmerald.withAlpha(30),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.accentEmerald.withAlpha(100)),
                          ),
                          child: const Text(
                            'ACTIVE',
                            style: TextStyle(
                              color: AppTheme.accentEmerald,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (!subState.isPro) ...[
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFF59E0B),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => PaywallScreen.show(context),
                        icon: const Icon(Icons.star_rounded, size: 20),
                        label: const Text(
                          'Upgrade to Traductor Pro',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ),
                  ] else ...[
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => PaywallScreen.show(context),
                      icon: const Icon(Icons.info_outline_rounded, size: 16),
                      label: const Text('View Plan Benefits & Pricing'),
                    ),
                  ],
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  // Testing helper toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Developer Testing Switch:',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                            onPressed: () {
                              subNotifier.resetDailyCountForTesting();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Free translation count reset to 0/15')),
                              );
                            },
                            child: const Text('Reset Quota', style: TextStyle(fontSize: 11)),
                          ),
                          Switch(
                            value: subState.isPro,
                            onChanged: (val) {
                              subNotifier.setProStatusForTesting(val);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Translation Engine Section
          _buildSectionHeader(context, 'Translation Engine', Icons.translate_rounded),
          Card(
            child: Column(
              children: [
                RadioListTile<String>(
                  title: const Text('Free Built-In Engine'),
                  subtitle: const Text('No API key required • Fast & reliable'),
                  value: AppConstants.providerFree,
                  groupValue: settings.translationProvider,
                  onChanged: (val) => notifier.setTranslationProvider(val!),
                ),
                const Divider(height: 1),
                RadioListTile<String>(
                  title: const Text('LibreTranslate'),
                  subtitle: const Text('Self-hosted or public LibreTranslate server'),
                  value: AppConstants.providerLibreTranslate,
                  groupValue: settings.translationProvider,
                  onChanged: (val) => notifier.setTranslationProvider(val!),
                ),
                const Divider(height: 1),
                RadioListTile<String>(
                  title: const Text('OpenAI GPT-4o-mini'),
                  subtitle: const Text('High-quality conversational translation'),
                  value: AppConstants.providerOpenAI,
                  groupValue: settings.translationProvider,
                  onChanged: (val) => notifier.setTranslationProvider(val!),
                ),
                const Divider(height: 1),
                RadioListTile<String>(
                  title: const Text('Google Gemini 1.5 Flash'),
                  subtitle: const Text('Ultra-low latency AI translation'),
                  value: AppConstants.providerGemini,
                  groupValue: settings.translationProvider,
                  onChanged: (val) => notifier.setTranslationProvider(val!),
                ),
              ],
            ),
          ),

          // API Configuration
          if (settings.translationProvider != AppConstants.providerFree) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'API Configuration',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    if (settings.translationProvider == AppConstants.providerLibreTranslate)
                      TextFormField(
                        initialValue: settings.apiUrl,
                        decoration: const InputDecoration(
                          labelText: 'LibreTranslate URL',
                          hintText: 'https://translate.terraprint.co/',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.link_rounded),
                        ),
                        onChanged: notifier.setApiUrl,
                      ),
                    if (settings.translationProvider == AppConstants.providerLibreTranslate)
                      const SizedBox(height: 12),
                    TextFormField(
                      initialValue: settings.apiKey,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: settings.translationProvider == AppConstants.providerLibreTranslate
                            ? 'API Key (Optional)'
                            : 'API Key',
                        hintText: 'Enter API Key',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.key_rounded),
                      ),
                      onChanged: notifier.setApiKey,
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Speech & Audio Section
          _buildSectionHeader(context, 'Speech & Feedback Control', Icons.record_voice_over_rounded),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Auto-Play Speech'),
                    subtitle: const Text('Automatically read translated text aloud'),
                    value: settings.autoPlayTts,
                    onChanged: notifier.setAutoPlayTts,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Prevent Feedback Loop'),
                    subtitle: const Text('Pause microphone listening while speaking'),
                    value: settings.pauseListeningDuringTts,
                    onChanged: notifier.setPauseListeningDuringTts,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Speech Speed Rate'),
                    subtitle: Slider(
                      value: settings.speechRate,
                      min: 0.2,
                      max: 1.0,
                      divisions: 8,
                      label: '${(settings.speechRate * 2).toStringAsFixed(1)}x',
                      onChanged: notifier.setSpeechRate,
                    ),
                    trailing: Text(
                      '${(settings.speechRate * 2).toStringAsFixed(1)}x',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Speech Volume'),
                    subtitle: Slider(
                      value: settings.speechVolume,
                      min: 0.1,
                      max: 1.0,
                      divisions: 9,
                      label: '${(settings.speechVolume * 100).toInt()}%',
                      onChanged: notifier.setSpeechVolume,
                    ),
                    trailing: Text(
                      '${(settings.speechVolume * 100).toInt()}%',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Conversation & Detection
          _buildSectionHeader(context, 'Detection & Timing', Icons.tune_rounded),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Silence Detection Timeout'),
                    subtitle: Slider(
                      value: settings.silenceTimeoutMs.toDouble(),
                      min: 800,
                      max: 3000,
                      divisions: 11,
                      label: '${(settings.silenceTimeoutMs / 1000).toStringAsFixed(1)}s',
                      onChanged: (val) => notifier.setSilenceTimeoutMs(val.toInt()),
                    ),
                    trailing: Text(
                      '${(settings.silenceTimeoutMs / 1000).toStringAsFixed(1)}s',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Language Detection Confidence Threshold'),
                    subtitle: Slider(
                      value: settings.confidenceThreshold,
                      min: 0.4,
                      max: 0.9,
                      divisions: 5,
                      label: '${(settings.confidenceThreshold * 100).toInt()}%',
                      onChanged: notifier.setConfidenceThreshold,
                    ),
                    trailing: Text(
                      '${(settings.confidenceThreshold * 100).toInt()}%',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Appearance & Theme
          _buildSectionHeader(context, 'Appearance', Icons.palette_rounded),
          Card(
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  title: const Text('System Default'),
                  value: ThemeMode.system,
                  groupValue: settings.themeMode,
                  onChanged: (val) => notifier.setThemeMode(val!),
                ),
                const Divider(height: 1),
                RadioListTile<ThemeMode>(
                  title: const Text('Light Mode'),
                  value: ThemeMode.light,
                  groupValue: settings.themeMode,
                  onChanged: (val) => notifier.setThemeMode(val!),
                ),
                const Divider(height: 1),
                RadioListTile<ThemeMode>(
                  title: const Text('Dark Mode'),
                  value: ThemeMode.dark,
                  groupValue: settings.themeMode,
                  onChanged: (val) => notifier.setThemeMode(val!),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // History & Privacy
          _buildSectionHeader(context, 'History & Privacy', Icons.security_rounded),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Save Conversation History'),
                  subtitle: const Text('Store translation logs locally on device'),
                  value: settings.saveHistory,
                  onChanged: notifier.setSaveHistory,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: AppTheme.accentRose),
                  title: const Text('Clear All Conversation History',
                      style: TextStyle(color: AppTheme.accentRose)),
                  onTap: () => _confirmClearHistory(context, ref),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Privacy Information'),
                  subtitle: const Text('Review data handling and audio safety'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _showPrivacyDialog(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Company & Version Footer
          Center(
            child: Column(
              children: [
                Text(
                  AppConstants.companyName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${AppConstants.appName} v${AppConstants.appVersion} (Build #${AppConstants.appBuildNumber})',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(150),
                      ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmClearHistory(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All History?'),
        content: const Text(
          'This will permanently delete all saved translation conversations from your device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.accentRose),
            onPressed: () {
              ref.read(historyControllerProvider.notifier).clearAllHistory();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All conversation history cleared.')),
              );
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.privacy_tip_rounded, color: AppTheme.accentEmerald),
            SizedBox(width: 8),
            Text('Privacy Policy'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '1. Microphone & Audio',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                '• Raw audio is processed directly through Android on-device speech recognition. Audio streams are NEVER permanently stored or uploaded to third-party tracking servers.',
              ),
              SizedBox(height: 12),
              Text(
                '2. Translation Text Data',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                '• Only transcribed text is transmitted over HTTPS to your chosen translation provider to compute the translation.',
              ),
              SizedBox(height: 12),
              Text(
                '3. Local Conversation Storage',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                '• Conversations are stored exclusively in your device\'s local SQLite database. You can disable history saving or clear all data at any time.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
