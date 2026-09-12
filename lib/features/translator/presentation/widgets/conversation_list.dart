import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/translation_message.dart';
import '../controllers/translator_controller.dart';
import 'conversation_bubble.dart';

class ConversationList extends ConsumerStatefulWidget {
  final List<TranslationMessage> messages;

  const ConversationList({
    super.key,
    required this.messages,
  });

  @override
  ConsumerState<ConversationList> createState() => _ConversationListState();
}

class _ConversationListState extends ConsumerState<ConversationList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(covariant ConversationList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messages.length > oldWidget.messages.length) {
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutQuad,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(translatorControllerProvider);

    if (widget.messages.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.record_voice_over_rounded,
                size: 72,
                color: Theme.of(context).colorScheme.primary.withAlpha(80),
              ),
              const SizedBox(height: 16),
              Text(
                'Two-Way Voice Translator',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Speak in ${state.language1.name} or ${state.language2.name}.\nThe app automatically detects who is speaking and translates both ways in real time.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.outline,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: widget.messages.length,
      itemBuilder: (context, index) {
        final message = widget.messages[index];
        final isFromL1 = message.sourceLanguage.isoCode == state.language1.isoCode;

        return ConversationBubble(
          message: message,
          isFromLanguage1: isFromL1,
        );
      },
    );
  }
}
