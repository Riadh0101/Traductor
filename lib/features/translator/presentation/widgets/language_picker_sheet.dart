import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/supported_languages.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../domain/entities/language.dart';
import '../../../subscription/presentation/controllers/subscription_controller.dart';
import '../../../subscription/presentation/screens/paywall_screen.dart';

class LanguagePickerSheet extends ConsumerStatefulWidget {
  final Language currentLanguage;
  final ValueChanged<Language> onSelected;

  const LanguagePickerSheet({
    super.key,
    required this.currentLanguage,
    required this.onSelected,
  });

  static Future<Language?> show(BuildContext context, Language current) {
    return showModalBottomSheet<Language>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => LanguagePickerSheet(
        currentLanguage: current,
        onSelected: (lang) => Navigator.pop(ctx, lang),
      ),
    );
  }

  @override
  ConsumerState<LanguagePickerSheet> createState() => _LanguagePickerSheetState();
}

class _LanguagePickerSheetState extends ConsumerState<LanguagePickerSheet> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final subState = ref.watch(subscriptionControllerProvider);

    final filtered = SupportedLanguages.all.where((l) {
      final query = _search.toLowerCase().trim();
      return l.name.toLowerCase().contains(query) ||
          l.nativeName.toLowerCase().contains(query) ||
          l.isoCode.toLowerCase().contains(query);
    }).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Select Language',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search_rounded),
                  hintText: 'Search language...',
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
                onChanged: (val) => setState(() => _search = val),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final lang = filtered[index];
                    final isSelected = lang == widget.currentLanguage;
                    final isAllowed = subState.isLanguageAllowed(lang);

                    return ListTile(
                      leading: Text(
                        lang.flagEmoji,
                        style: const TextStyle(fontSize: 28),
                      ),
                      title: Row(
                        children: [
                          Text(
                            lang.name,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          if (!isAllowed) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.accentAmber.withAlpha(35),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: AppTheme.accentAmber.withAlpha(120),
                                  width: 0.8,
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.workspace_premium_rounded, size: 11, color: AppTheme.accentAmber),
                                  SizedBox(width: 2),
                                  Text(
                                    'PRO',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.accentAmber,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      subtitle: Text(lang.nativeName),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle_rounded,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : (!isAllowed
                              ? const Icon(Icons.lock_outline_rounded, size: 18, color: AppTheme.accentAmber)
                              : null),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onTap: () {
                        if (!isAllowed) {
                          PaywallScreen.show(context, featureHighlighted: '${lang.name} Language');
                          return;
                        }
                        widget.onSelected(lang);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
