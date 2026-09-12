import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../domain/entities/language.dart';
import '../controllers/translator_controller.dart';
import '../controllers/translator_state.dart';

class MicButton extends ConsumerStatefulWidget {
  const MicButton({super.key});

  @override
  ConsumerState<MicButton> createState() => _MicButtonState();
}

class _MicButtonState extends ConsumerState<MicButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(translatorControllerProvider);
    final notifier = ref.read(translatorControllerProvider.notifier);

    // Coordinate pulse animation based on status
    if (state.status == TranslatorStatus.listening ||
        state.status == TranslatorStatus.translating ||
        state.status == TranslatorStatus.speaking) {
      if (!_animController.isAnimating) {
        _animController.repeat(reverse: true);
      }
    } else {
      if (_animController.isAnimating) {
        _animController.stop();
        _animController.reset();
      }
    }

    final isPushToTalk = state.activeMode == AppConstants.modePushToTalk;
    final buttonConfig = _getButtonConfig(state.status, isPushToTalk);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Language 1 Walkie-Talkie Button
              Expanded(
                child: _buildSpeakerButton(
                  context: context,
                  language: state.language1,
                  targetLanguage: state.language2,
                  isActive: state.status == TranslatorStatus.listening &&
                      state.detectedLiveLanguage == state.language1,
                  pulseAnimation: _pulseAnimation,
                  onTapDown: () {
                    HapticFeedback.heavyImpact();
                    notifier.startListeningLanguage1();
                  },
                  onTapUp: () {
                    HapticFeedback.lightImpact();
                    notifier.stopListeningAndTranslate();
                  },
                  onTapCancel: () {
                    notifier.stopListeningAndTranslate();
                  },
                ),
              ),

              // Middle Swap Icon
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: IconButton.filledTonal(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    notifier.swapLanguages();
                  },
                  icon: const Icon(Icons.swap_horiz_rounded, size: 22),
                  tooltip: 'Swap Languages',
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    padding: const EdgeInsets.all(10),
                  ),
                ),
              ),

              // Language 2 Walkie-Talkie Button
              Expanded(
                child: _buildSpeakerButton(
                  context: context,
                  language: state.language2,
                  targetLanguage: state.language1,
                  isActive: state.status == TranslatorStatus.listening &&
                      state.detectedLiveLanguage == state.language2,
                  pulseAnimation: _pulseAnimation,
                  onTapDown: () {
                    HapticFeedback.heavyImpact();
                    notifier.startListeningLanguage2();
                  },
                  onTapUp: () {
                    HapticFeedback.lightImpact();
                    notifier.stopListeningAndTranslate();
                  },
                  onTapCancel: () {
                    notifier.stopListeningAndTranslate();
                  },
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Text(
            buttonConfig.statusText,
            key: ValueKey(buttonConfig.statusText),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: buttonConfig.textColor ?? Theme.of(context).colorScheme.onSurface,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpeakerButton({
    required BuildContext context,
    required Language language,
    required Language targetLanguage,
    required bool isActive,
    required Animation<double> pulseAnimation,
    required VoidCallback onTapDown,
    required VoidCallback onTapUp,
    required VoidCallback onTapCancel,
  }) {
    final theme = Theme.of(context);

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) => onTapDown(),
      onPointerUp: (_) => onTapUp(),
      child: AnimatedBuilder(
        animation: pulseAnimation,
        builder: (context, child) {
          final scale = isActive ? pulseAnimation.value : 1.0;

          return Transform.scale(
            scale: scale,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: isActive
                    ? AppTheme.accentEmerald.withAlpha(45)
                    : theme.colorScheme.surfaceContainerHighest.withAlpha(150),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isActive
                      ? AppTheme.accentEmerald
                      : theme.dividerColor.withAlpha(70),
                  width: isActive ? 2.2 : 1.2,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppTheme.accentEmerald.withAlpha(90),
                          blurRadius: 20,
                          spreadRadius: 4,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withAlpha(15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        language.flagEmoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          language.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isActive
                                ? AppTheme.accentEmerald
                                : theme.colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isActive
                            ? const [AppTheme.accentEmerald, Color(0xFF059669)]
                            : [theme.colorScheme.primary, AppTheme.primaryIndigo],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isActive ? AppTheme.accentEmerald : theme.colorScheme.primary)
                              .withAlpha(80),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        isActive ? Icons.mic_rounded : Icons.mic_none_rounded,
                        size: 26,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isActive ? 'أفلت للترجمة' : 'اضغط مطولاً للتحدث',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isActive
                          ? AppTheme.accentEmerald
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  _ButtonConfig _getButtonConfig(TranslatorStatus status, bool isPushToTalk) {
    switch (status) {
      case TranslatorStatus.listening:
        return const _ButtonConfig(
          icon: Icons.mic_rounded,
          gradientColors: [AppTheme.accentEmerald, Color(0xFF059669)],
          statusText: 'Listening to speech...',
          textColor: AppTheme.accentEmerald,
        );
      case TranslatorStatus.processing:
        return const _ButtonConfig(
          icon: Icons.psychology_rounded,
          gradientColors: [AppTheme.accentAmber, Color(0xFFD97706)],
          statusText: 'Processing sentence...',
          textColor: AppTheme.accentAmber,
        );
      case TranslatorStatus.translating:
        return const _ButtonConfig(
          icon: Icons.translate_rounded,
          gradientColors: [AppTheme.accentCyan, Color(0xFF0891B2)],
          statusText: 'Translating...',
          textColor: AppTheme.accentCyan,
        );
      case TranslatorStatus.speaking:
        return const _ButtonConfig(
          icon: Icons.volume_up_rounded,
          gradientColors: [AppTheme.primaryIndigo, AppTheme.accentCyan],
          statusText: 'Speaking translation...',
          textColor: AppTheme.primaryIndigo,
        );
      case TranslatorStatus.error:
        return const _ButtonConfig(
          icon: Icons.mic_off_rounded,
          gradientColors: [AppTheme.accentRose, Color(0xFFE11D48)],
          statusText: 'Error - Tap to retry',
          textColor: AppTheme.accentRose,
        );
      case TranslatorStatus.paused:
        return const _ButtonConfig(
          icon: Icons.pause_rounded,
          gradientColors: [Color(0xFF64748B), Color(0xFF475569)],
          statusText: 'Paused',
        );
      case TranslatorStatus.idle:
        return _ButtonConfig(
          icon: Icons.mic_rounded,
          gradientColors: const [AppTheme.primaryBlue, AppTheme.primaryIndigo],
          statusText: isPushToTalk ? 'Hold to Speak' : 'Tap to Start Auto',
        );
    }
  }
}

class _ButtonConfig {
  final IconData icon;
  final List<Color> gradientColors;
  final String statusText;
  final Color? textColor;

  const _ButtonConfig({
    required this.icon,
    required this.gradientColors,
    required this.statusText,
    this.textColor,
  });
}
