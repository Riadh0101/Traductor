import 'package:flutter_test/flutter_test.dart';
import 'package:traductor/core/utils/speech_disfluency_filter.dart';

void main() {
  group('SpeechDisfluencyFilter Tests', () {
    test('returns empty string for empty input', () {
      expect(SpeechDisfluencyFilter.cleanImmediateDisfluencies(''), equals(''));
      expect(SpeechDisfluencyFilter.cleanImmediateDisfluencies('   '), equals(''));
    });

    test('removes repeated Arabic words caused by stuttering', () {
      const input = 'أنا أنا أريد أريد الذهاب إلى السوق';
      final result = SpeechDisfluencyFilter.cleanImmediateDisfluencies(input);
      expect(result, equals('أنا أريد الذهاب إلى السوق'));
    });

    test('removes repeated Turkish words caused by stuttering', () {
      const input = 'ben ben gitmek gitmek istiyorum';
      final result = SpeechDisfluencyFilter.cleanImmediateDisfluencies(input);
      expect(result, equals('ben gitmek istiyorum'));
    });

    test('handles repetitions separated by pause ellipses or dashes', () {
      const input = 'أنا... أنا أريد — أريد المساعدة';
      final result = SpeechDisfluencyFilter.cleanImmediateDisfluencies(input);
      expect(result, equals('أنا أريد المساعدة'));
    });

    test('preserves normal single words without modifying them', () {
      const input = 'صباح الخير كيف حالك اليوم';
      final result = SpeechDisfluencyFilter.cleanImmediateDisfluencies(input);
      expect(result, equals('صباح الخير كيف حالك اليوم'));
    });
  });
}
