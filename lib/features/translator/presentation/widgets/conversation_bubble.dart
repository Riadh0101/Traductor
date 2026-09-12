import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../../../domain/entities/translation_message.dart';
import '../controllers/translator_controller.dart';
import 'full_screen_translation_dialog.dart';

class ConversationBubble extends ConsumerWidget {
  final TranslationMessage message;
  final bool isFromLanguage1;

  const ConversationBubble({
    super.key,
    required this.message,
    required this.isFromLanguage1,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat('HH:mm');
    final formattedTime = timeFormat.format(message.timestamp);

    // Differentiate bubble alignment and style based on speaker/source language
    return Align(
      alignment: isFromLanguage1 ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.86,
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        decoration: BoxDecoration(
          color: isFromLanguage1
              ? theme.colorScheme.surface
              : theme.colorScheme.primaryContainer.withAlpha(80),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isFromLanguage1 ? const Radius.circular(4) : const Radius.circular(20),
            bottomRight: isFromLanguage1 ? const Radius.circular(20) : const Radius.circular(4),
          ),
          border: Border.all(
            color: isFromLanguage1
                ? theme.dividerColor.withAlpha(30)
                : theme.colorScheme.primary.withAlpha(50),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Source Header
              Row(
                children: [
                  Text(
                    message.sourceLanguage.flagEmoji,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    message.sourceLanguage.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    formattedTime,
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Source Spoken Text
              Text(
                message.sourceText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 1.3,
                ),
                textDirection: message.sourceLanguage.isRtl ? TextDirection.rtl : TextDirection.ltr,
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(height: 1),
              ),

              // Target Header
              Row(
                children: [
                  Text(
                    message.targetLanguage.flagEmoji,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    message.targetLanguage.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const Spacer(),
                  // Action buttons: FullScreen, Copy, Replay
                  IconButton(
                    icon: const Icon(Icons.fullscreen_rounded, size: 20),
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Large display',
                    onPressed: () {
                      FullScreenTranslationDialog.show(context, message);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Copy translation',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: message.translatedText));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Translation copied'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.volume_up_rounded, size: 20),
                    visualDensity: VisualDensity.compact,
                    color: theme.colorScheme.primary,
                    tooltip: 'Speak aloud',
                    onPressed: () {
                      ref.read(translatorControllerProvider.notifier).replayMessageAudio(message);
                    },
                  ),
                ],
              ),

              // Translated Text
              Text(
                message.translatedText,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                  height: 1.3,
                ),
                textDirection: message.targetLanguage.isRtl ? TextDirection.rtl : TextDirection.ltr,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
