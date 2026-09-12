import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../translator/presentation/controllers/translator_controller.dart';
import '../../data/travel_phrases_data.dart';

class PhrasebookScreen extends ConsumerStatefulWidget {
  const PhrasebookScreen({super.key});

  @override
  ConsumerState<PhrasebookScreen> createState() => _PhrasebookScreenState();
}

class _PhrasebookScreenState extends ConsumerState<PhrasebookScreen> {
  String _search = '';
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(translatorControllerProvider);
    final notifier = ref.read(translatorControllerProvider.notifier);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Filter phrases
    final allPhrasesWithCategory = <Map<String, dynamic>>[];
    for (final cat in TravelPhrasesData.categories) {
      if (_selectedCategory == null || _selectedCategory == cat.title) {
        for (final p in cat.phrases) {
          final query = _search.toLowerCase().trim();
          final matches = query.isEmpty ||
              p.english.toLowerCase().contains(query) ||
              p.arabic.toLowerCase().contains(query) ||
              cat.titleArabic.toLowerCase().contains(query) ||
              cat.title.toLowerCase().contains(query);

          if (matches) {
            allPhrasesWithCategory.add({
              'phrase': p,
              'category': cat,
            });
          }
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Phrasebook'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'To: ${state.language2.flagEmoji} ${state.language2.name}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search_rounded),
                hintText: 'Search travel phrases (بحث في العبارات)...',
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (val) => setState(() => _search = val),
            ),
          ),

          // Categories horizontal scroll
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: const Text('All (الكل)'),
                    selected: _selectedCategory == null,
                    onSelected: (_) => setState(() => _selectedCategory = null),
                  ),
                ),
                ...TravelPhrasesData.categories.map((cat) {
                  final isSelected = _selectedCategory == cat.title;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      label: Text('${cat.emoji} ${cat.titleArabic}'),
                      selected: isSelected,
                      onSelected: (_) => setState(() {
                        _selectedCategory = isSelected ? null : cat.title;
                      }),
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Phrase List
          Expanded(
            child: allPhrasesWithCategory.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 54, color: theme.colorScheme.outline),
                        const SizedBox(height: 12),
                        Text(
                          'No phrases found matching your search',
                          style: TextStyle(color: theme.colorScheme.outline),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: allPhrasesWithCategory.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = allPhrasesWithCategory[index];
                      final PhraseItem phrase = item['phrase'];
                      final PhraseCategory cat = item['category'];

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Text(cat.emoji, style: const TextStyle(fontSize: 18)),
                                  const SizedBox(width: 8),
                                  Text(
                                    cat.titleArabic,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(Icons.copy_rounded, size: 18),
                                    tooltip: 'Copy',
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(text: '${phrase.arabic}\n${phrase.english}'));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Copied phrase')),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                phrase.arabic,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                                textDirection: TextDirection.rtl,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                phrase.english,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? Colors.white70 : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 12),
                              FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppTheme.primaryIndigo,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {
                                  // Speak and translate in conversation
                                  final textToTranslate = state.language1.isoCode == 'ar'
                                      ? phrase.arabic
                                      : phrase.english;
                                  notifier.translateCustomText(
                                    text: textToTranslate,
                                    source: state.language1,
                                    target: state.language2,
                                  );
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Translating to ${state.language2.name}...'),
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.record_voice_over_rounded, size: 18),
                                label: Text('Translate to ${state.language2.flagEmoji} ${state.language2.name}'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
