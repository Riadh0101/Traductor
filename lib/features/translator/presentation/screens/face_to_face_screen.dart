import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../domain/entities/language.dart';
import '../controllers/translator_controller.dart';
import '../controllers/translator_state.dart';

class FaceToFaceScreen extends ConsumerWidget {
  const FaceToFaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(translatorControllerProvider);
    final notifier = ref.read(translatorControllerProvider.notifier);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Column(
          children: [
            // Top Half: Partner Side (Inverted 180 degrees)
            Expanded(
              child: Transform.rotate(
                angle: math.pi,
                child: _SpeakerZone(
                  language: state.language2,
                  targetLanguage: state.language1,
                  isTopZone: true,
                  state: state,
                  onStartListening: () {
                    HapticFeedback.heavyImpact();
                    notifier.startListeningLanguage2();
                  },
                  onStopListening: () {
                    HapticFeedback.lightImpact();
                    notifier.stopListeningAndTranslate();
                  },
                ),
              ),
            ),

            // Middle Divider Control Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(15),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_fullscreen_rounded),
                    tooltip: 'Exit Face-to-Face Mode',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  // Status Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(state.status).withAlpha(25),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _getStatusColor(state.status).withAlpha(80),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getStatusColor(state.status),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getStatusLabel(state.status),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(state.status),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.swap_vert_rounded, size: 24),
                    tooltip: 'Swap Sides',
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      notifier.swapLanguages();
                    },
                  ),
                ],
              ),
            ),

            // Bottom Half: Primary Speaker Side (0 degrees)
            Expanded(
              child: _SpeakerZone(
                language: state.language1,
                targetLanguage: state.language2,
                isTopZone: false,
                state: state,
                onStartListening: () {
                  HapticFeedback.heavyImpact();
                  notifier.startListeningLanguage1();
                },
                onStopListening: () {
                  HapticFeedback.lightImpact();
                  notifier.stopListeningAndTranslate();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(TranslatorStatus status) {
    switch (status) {
      case TranslatorStatus.listening:
        return AppTheme.accentRose;
      case TranslatorStatus.processing:
      case TranslatorStatus.translating:
        return AppTheme.accentAmber;
      case TranslatorStatus.speaking:
        return AppTheme.accentEmerald;
      case TranslatorStatus.paused:
        return Colors.grey;
      case TranslatorStatus.error:
        return AppTheme.accentRose;
      case TranslatorStatus.idle:
        return AppTheme.primaryIndigo;
    }
  }

  String _getStatusLabel(TranslatorStatus status) {
    switch (status) {
      case TranslatorStatus.listening:
        return 'Listening...';
      case TranslatorStatus.processing:
        return 'Processing...';
      case TranslatorStatus.translating:
        return 'Translating...';
      case TranslatorStatus.speaking:
        return 'Speaking...';
      case TranslatorStatus.paused:
        return 'Paused';
      case TranslatorStatus.error:
        return 'Error';
      case TranslatorStatus.idle:
        return 'Face-to-Face Ready';
    }
  }
}

class _SpeakerZone extends StatelessWidget {
  final Language language;
  final Language targetLanguage;
  final bool isTopZone;
  final TranslatorState state;
  final VoidCallback onStartListening;
  final VoidCallback onStopListening;

  const _SpeakerZone({
    required this.language,
    required this.targetLanguage,
    required this.isTopZone,
    required this.state,
    required this.onStartListening,
    required this.onStopListening,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isListeningThisZone = state.status == TranslatorStatus.listening &&
        state.detectedLiveLanguage?.isoCode == language.isoCode;

    // Latest message directed to this speaker (where targetLanguage == this language)
    final messagesForThisSpeaker = state.messages.where((m) => m.targetLanguage.isoCode == language.isoCode);
    final lastMessage = messagesForThisSpeaker.isNotEmpty ? messagesForThisSpeaker.last : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Flag and Language Title
          Row(
            children: [
              Text(language.flagEmoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                '${language.name} (${language.nativeName})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Speaks to ${targetLanguage.flagEmoji}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Speech Output / Live Display Card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isListeningThisZone
                      ? AppTheme.accentRose
                      : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  width: isListeningThisZone ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: _buildTextContent(isListeningThisZone, lastMessage),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Large Push-to-Talk Button
          Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (_) => onStartListening(),
            onPointerUp: (_) => onStopListening(),
            onPointerCancel: (_) => onStopListening(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isListeningThisZone
                      ? [AppTheme.accentRose, const Color(0xFFBE123C)]
                      : [AppTheme.primaryIndigo, const Color(0xFF3730A3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (isListeningThisZone ? AppTheme.accentRose : AppTheme.primaryIndigo)
                        .withAlpha(80),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isListeningThisZone ? Icons.mic_rounded : Icons.mic_none_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isListeningThisZone ? 'Listening... Release to translate' : 'Hold to Speak',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextContent(bool isListeningThisZone, dynamic lastMessage) {
    if (isListeningThisZone && state.liveTranscript.isNotEmpty) {
      return Text(
        state.liveTranscript,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppTheme.accentRose,
          height: 1.3,
        ),
      );
    }

    if (lastMessage != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            lastMessage.translatedText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
            textDirection: language.isRtl ? TextDirection.rtl : TextDirection.ltr,
          ),
          const SizedBox(height: 8),
          Text(
            '${lastMessage.sourceLanguage.flagEmoji} ${lastMessage.sourceText}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
        ],
      );
    }

    return Text(
      'Translations in ${language.name} will appear here.',
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 15,
        color: Colors.grey,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}
