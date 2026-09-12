import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../controllers/translator_controller.dart';

class ModeSelectorBar extends ConsumerWidget {
  const ModeSelectorBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(translatorControllerProvider);
    final notifier = ref.read(translatorControllerProvider.notifier);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          ChoiceChip(
            label: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.touch_app_rounded, size: 16),
                SizedBox(width: 6),
                Text('Push to Talk'),
              ],
            ),
            selected: true,
            onSelected: (selected) {
              notifier.setActiveMode(AppConstants.modePushToTalk);
            },
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: Text('${state.language1.flagEmoji} → ${state.language2.flagEmoji}'),
            selected: state.activeMode == AppConstants.modeManualL1ToL2,
            onSelected: (selected) {
              if (selected) {
                notifier.setActiveMode(AppConstants.modeManualL1ToL2);
              }
            },
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: Text('${state.language2.flagEmoji} → ${state.language1.flagEmoji}'),
            selected: state.activeMode == AppConstants.modeManualL2ToL1,
            onSelected: (selected) {
              if (selected) {
                notifier.setActiveMode(AppConstants.modeManualL2ToL1);
              }
            },
          ),
        ],
      ),
    );
  }
}
