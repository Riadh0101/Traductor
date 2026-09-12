class SpeechDisfluencyFilter {
  /// Cleans immediate stutter repetitions and disfluencies from spoken text.
  /// e.g. "أنا أنا أريد أريد أن..." -> "أنا أريد أن..."
  /// e.g. "ben... ben gitmek istiyorum" -> "ben gitmek istiyorum"
  static String cleanImmediateDisfluencies(String input) {
    if (input.trim().isEmpty) return '';

    // Replace ellipses and hyphens often inserted during stutter pauses with space
    var normalized = input.replaceAll(RegExp(r'\.{2,}|…|—|-'), ' ');

    final tokens = normalized.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
    if (tokens.isEmpty) return '';

    final cleanedTokens = <String>[];
    String? lastCleanedWord;

    for (final token in tokens) {
      // Normalize token for comparison (remove punctuation, lowercase)
      final stripped = token.replaceAll(RegExp(r'[^\p{L}\p{N}]', unicode: true), '').toLowerCase();
      
      if (stripped.isEmpty) {
        cleanedTokens.add(token);
        continue;
      }

      if (lastCleanedWord != null && stripped == lastCleanedWord) {
        // Consecutive duplicate word (stutter) detected -> skip
        continue;
      }

      lastCleanedWord = stripped;
      cleanedTokens.add(token);
    }

    return cleanedTokens.join(' ');
  }
}
