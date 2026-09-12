import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:share_plus/share_plus.dart';
import 'package:traductor/core/constants/app_constants.dart';
import 'package:traductor/core/theme/app_theme.dart';
import 'package:traductor/domain/entities/conversation_session.dart';
import 'package:traductor/features/translator/presentation/controllers/translator_controller.dart';
import 'package:traductor/features/translator/presentation/widgets/ai_summary_sheet.dart';
import 'package:traductor/features/translator/presentation/widgets/full_screen_translation_dialog.dart';
import '../controllers/history_controller.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(historyControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversation History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () => ref.read(historyControllerProvider.notifier).loadSessions(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search in History
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search_rounded),
                hintText: 'Search history (ابحث في المحادثات)...',
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),

          Expanded(
            child: historyState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 48, color: AppTheme.accentRose),
                    const SizedBox(height: 12),
                    Text('Failed to load history: $err'),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => ref.read(historyControllerProvider.notifier).loadSessions(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (sessions) {
                final filtered = sessions.where((session) {
                  final q = _searchQuery.toLowerCase().trim();
                  if (q.isEmpty) return true;
                  final lang1 = session.language1.name.toLowerCase();
                  final lang2 = session.language2.name.toLowerCase();
                  final matchLang = lang1.contains(q) || lang2.contains(q);
                  if (matchLang) return true;

                  return session.messages.any((m) =>
                      m.sourceText.toLowerCase().contains(q) ||
                      m.translatedText.toLowerCase().contains(q));
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history_toggle_off_rounded,
                          size: 64,
                          color: Theme.of(context).colorScheme.outline.withAlpha(128),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'No conversations found matching "$_searchQuery"'
                              : 'No saved conversations yet',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                        const SizedBox(height: 8),
                        const Text('Completed voice translations appear here.'),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final session = filtered[index];
                    return _SessionCard(session: session);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionCard extends ConsumerWidget {
  final ConversationSession session;

  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('MMM d, y • HH:mm');
    final formattedDate = dateFormat.format(session.createdAt);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            '${session.language1.flagEmoji}${session.language2.flagEmoji}',
            style: const TextStyle(fontSize: 16),
          ),
        ),
        title: Text(
          '${session.language1.name} ⇄ ${session.language2.name}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          '$formattedDate • ${session.messages.length} message${session.messages.length == 1 ? '' : 's'}',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded),
          onSelected: (val) {
            if (val == 'summary') {
              AiSummarySheet.show(
                context,
                messages: session.messages,
                targetLanguageCode: session.language1.isoCode,
              );
            } else if (val == 'share') {
              _shareSession(session);
            } else if (val == 'delete') {
              ref.read(historyControllerProvider.notifier).deleteSession(session.id);
            }
          },
          itemBuilder: (ctx) => [
            if (session.messages.isNotEmpty)
              const PopupMenuItem(
                value: 'summary',
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome_rounded, size: 18, color: AppTheme.accentAmber),
                    SizedBox(width: 8),
                    Text('AI Summary (تلخيص)'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'share',
              child: Row(
                children: [
                  Icon(Icons.share_rounded, size: 18),
                  SizedBox(width: 8),
                  Text('Share Conversation'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_rounded, size: 18, color: AppTheme.accentRose),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: AppTheme.accentRose)),
                ],
              ),
            ),
          ],
        ),
        children: [
          const Divider(height: 1),
          if (session.messages.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No messages recorded for this session.'),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: session.messages.length,
              separatorBuilder: (context, index) => const Divider(height: 16),
              itemBuilder: (ctx, i) {
                final msg = session.messages[i];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${msg.sourceLanguage.flagEmoji} ${msg.sourceLanguage.name}:',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.fullscreen_rounded, size: 18),
                          tooltip: 'Large Display',
                          onPressed: () {
                            FullScreenTranslationDialog.show(context, msg);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy_rounded, size: 16),
                          tooltip: 'Copy',
                          onPressed: () {
                            Clipboard.setData(ClipboardData(
                              text: '${msg.sourceText}\n${msg.translatedText}',
                            ));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Copied to clipboard')),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.volume_up_rounded, size: 18),
                          tooltip: 'Play translation',
                          onPressed: () {
                            ref.read(ttsServiceProvider).speak(
                                  msg.translatedText,
                                  msg.targetLanguage.ttsLocale,
                                );
                          },
                        ),
                      ],
                    ),
                    Text(
                      msg.sourceText,
                      style: const TextStyle(fontSize: 15),
                      textDirection: msg.sourceLanguage.isRtl ? TextDirection.rtl : TextDirection.ltr,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${msg.targetLanguage.flagEmoji} ${msg.targetLanguage.name}:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Text(
                      msg.translatedText,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      textDirection: msg.targetLanguage.isRtl ? TextDirection.rtl : TextDirection.ltr,
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  void _shareSession(ConversationSession session) {
    final buffer = StringBuffer();
    buffer.writeln('📋 Translation Transcript (${AppConstants.companyName})');
    buffer.writeln('Language Pair: ${session.language1.name} ⇄ ${session.language2.name}');
    buffer.writeln('Date: ${session.createdAt.toLocal()}\n');
    buffer.writeln('----------------------------------------\n');

    for (final msg in session.messages) {
      buffer.writeln('${msg.sourceLanguage.flagEmoji} ${msg.sourceLanguage.name}: ${msg.sourceText}');
      buffer.writeln('${msg.targetLanguage.flagEmoji} ${msg.targetLanguage.name}: ${msg.translatedText}\n');
    }

    // ignore: deprecated_member_use
    Share.share(buffer.toString(), subject: 'Traductor Conversation Transcript');
  }
}
