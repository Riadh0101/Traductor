import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../controllers/translator_controller.dart';
import '../controllers/translator_state.dart';

class LiveTranscriptCard extends ConsumerWidget {
  const LiveTranscriptCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(translatorControllerProvider);

    if (state.liveTranscript.trim().isEmpty &&
        state.status != TranslatorStatus.listening) {
      return const SizedBox.shrink();
    }

    final isListening = state.status == TranslatorStatus.listening;
    final detected = state.detectedLiveLanguage;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color?.withAlpha(240),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isListening ? AppTheme.accentEmerald.withAlpha(120) : AppTheme.accentCyan.withAlpha(120),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isListening ? AppTheme.accentEmerald : AppTheme.accentCyan).withAlpha(25),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isListening ? AppTheme.accentEmerald : AppTheme.accentAmber,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isListening ? 'Live Listening...' : 'Processing Speech...',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isListening ? AppTheme.accentEmerald : AppTheme.accentAmber,
                ),
              ),
              const Spacer(),
              if (detected != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(detected.flagEmoji, style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text(
                        detected.name,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            state.liveTranscript.isEmpty
                ? 'Speak now in ${state.language1.name} or ${state.language2.name}...'
                : state.liveTranscript,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              fontStyle: state.liveTranscript.isEmpty ? FontStyle.italic : FontStyle.normal,
              color: state.liveTranscript.isEmpty
                  ? Theme.of(context).colorScheme.outline
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
