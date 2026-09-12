import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/language.dart';
import '../controllers/translator_controller.dart';
import 'language_picker_sheet.dart';

class LanguageSelectorBar extends ConsumerWidget {
  const LanguageSelectorBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(translatorControllerProvider);
    final notifier = ref.read(translatorControllerProvider.notifier);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).dividerColor.withAlpha(40),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Language 1 Pill
          Expanded(
            child: _LanguagePill(
              language: state.language1,
              onTap: () async {
                final selected = await LanguagePickerSheet.show(context, state.language1);
                if (selected != null) {
                  notifier.setLanguage1(selected);
                }
              },
            ),
          ),

          // Swap Button with animated rotation
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: AnimatedRotation(
              turns: state.isSwappingLanguages ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutBack,
              child: IconButton.filledTonal(
                onPressed: notifier.swapLanguages,
                icon: const Icon(Icons.swap_horiz_rounded),
                tooltip: 'Swap Languages',
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ),
          ),

          // Language 2 Pill
          Expanded(
            child: _LanguagePill(
              language: state.language2,
              onTap: () async {
                final selected = await LanguagePickerSheet.show(context, state.language2);
                if (selected != null) {
                  notifier.setLanguage2(selected);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguagePill extends StatelessWidget {
  final Language language;
  final VoidCallback onTap;

  const _LanguagePill({
    required this.language,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              language.flagEmoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    language.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    language.nativeName,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down_rounded, size: 20),
          ],
        ),
      ),
    );
  }
}
