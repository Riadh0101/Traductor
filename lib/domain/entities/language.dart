class Language {
  final String id;
  final String name;
  final String nativeName;
  final String flagEmoji;
  final String isoCode; // e.g. "ar", "tr", "en"
  final String sttLocale; // e.g. "ar-SA", "tr-TR", "en-US"
  final String ttsLocale; // e.g. "ar-SA", "tr-TR", "en-US"
  final bool isRtl;

  const Language({
    required this.id,
    required this.name,
    required this.nativeName,
    required this.flagEmoji,
    required this.isoCode,
    required this.sttLocale,
    required this.ttsLocale,
    this.isRtl = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Language && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => '$name ($isoCode)';
}
