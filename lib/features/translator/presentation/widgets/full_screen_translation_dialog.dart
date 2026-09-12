import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../domain/entities/translation_message.dart';
import '../controllers/translator_controller.dart';

class FullScreenTranslationDialog extends ConsumerWidget {
  final TranslationMessage message;

  const FullScreenTranslationDialog({
    super.key,
    required this.message,
  });

  static Future<void> show(BuildContext context, TranslationMessage message) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withAlpha(220),
      pageBuilder: (ctx, anim1, anim2) => FullScreenTranslationDialog(message: message),
      transitionDuration: const Duration(milliseconds: 250),
      transitionBuilder: (ctx, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(
              CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, size: 28),
          tooltip: 'Close',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message.targetLanguage.flagEmoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Text(
              message.targetLanguage.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_rounded),
            tooltip: 'Copy',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: message.translatedText));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Translation copied to clipboard'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.volume_up_rounded, size: 26, color: AppTheme.primaryIndigo),
            tooltip: 'Speak',
            onPressed: () {
              ref.read(translatorControllerProvider.notifier).replayMessageAudio(message);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Source context card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(message.sourceLanguage.flagEmoji, style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(
                          message.sourceLanguage.name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message.sourceText,
                      style: TextStyle(
                        fontSize: 15,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                      textDirection:
                          message.sourceLanguage.isRtl ? TextDirection.rtl : TextDirection.ltr,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Giant Translated Text (Billboard)
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        message.translatedText,
                        textAlign: TextAlign.center,
                        textDirection:
                            message.targetLanguage.isRtl ? TextDirection.rtl : TextDirection.ltr,
                        style: TextStyle(
                          fontSize: _calculateFontSize(message.translatedText),
                          fontWeight: FontWeight.bold,
                          height: 1.25,
                          color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom quick-action bar
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        ref.read(translatorControllerProvider.notifier).replayMessageAudio(message);
                      },
                      icon: const Icon(Icons.volume_up_rounded, size: 24),
                      label: const Text('Play Audio', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const VerticalDivider(width: 1),
                    TextButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: message.translatedText));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Copied!'),
                            duration: Duration(milliseconds: 800),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded, size: 20),
                      label: const Text('Copy'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateFontSize(String text) {
    final length = text.length;
    if (length < 30) return 40;
    if (length < 60) return 34;
    if (length < 120) return 28;
    if (length < 200) return 24;
    return 20;
  }
}
