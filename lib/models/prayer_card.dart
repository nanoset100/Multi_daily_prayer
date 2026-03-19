class PrayerCard {
  final int id;
  final String? date;
  final String? themeKo, themeEn, themeJa, themeZh, themeEs;
  final String? verseKo, verseEn, verseJa, verseZh, verseEs;
  final String? prayerKo, prayerEn, prayerJa, prayerZh, prayerEs;

  PrayerCard({
    required this.id,
    this.date,
    this.themeKo,
    this.themeEn,
    this.themeJa,
    this.themeZh,
    this.themeEs,
    this.verseKo,
    this.verseEn,
    this.verseJa,
    this.verseZh,
    this.verseEs,
    this.prayerKo,
    this.prayerEn,
    this.prayerJa,
    this.prayerZh,
    this.prayerEs,
  });

  factory PrayerCard.fromJson(Map<String, dynamic> json) {
    return PrayerCard(
      id: json['id'],
      date: json['date'],
      themeKo: json['theme_ko'],
      themeEn: json['theme_en'],
      themeJa: json['theme_ja'],
      themeZh: json['theme_zh'],
      themeEs: json['theme_es'],
      verseKo: json['verse_ko'],
      verseEn: json['verse_en'],
      verseJa: json['verse_ja'],
      verseZh: json['verse_zh'],
      verseEs: json['verse_es'],
      prayerKo: json['prayer_ko'],
      prayerEn: json['prayer_en'],
      prayerJa: json['prayer_ja'],
      prayerZh: json['prayer_zh'],
      prayerEs: json['prayer_es'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'theme_ko': themeKo,
      'theme_en': themeEn,
      'theme_ja': themeJa,
      'theme_zh': themeZh,
      'theme_es': themeEs,
      'verse_ko': verseKo,
      'verse_en': verseEn,
      'verse_ja': verseJa,
      'verse_zh': verseZh,
      'verse_es': verseEs,
      'prayer_ko': prayerKo,
      'prayer_en': prayerEn,
      'prayer_ja': prayerJa,
      'prayer_zh': prayerZh,
      'prayer_es': prayerEs,
    };
  }

  String? getTheme(String lang) =>
      {
        'ko': themeKo,
        'en': themeEn,
        'ja': themeJa,
        'zh': themeZh,
        'es': themeEs,
      }[lang];

  String? getVerse(String lang) =>
      {
        'ko': verseKo,
        'en': verseEn,
        'ja': verseJa,
        'zh': verseZh,
        'es': verseEs,
      }[lang];

  String? getPrayer(String lang) =>
      {
        'ko': prayerKo,
        'en': prayerEn,
        'ja': prayerJa,
        'zh': prayerZh,
        'es': prayerEs,
      }[lang];
}
