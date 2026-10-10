/// Languages the app can recognise and translate to Arabic.
/// [code] is the ISO 639-1 code shared by Whisper and ML Kit.
enum SourceLanguage {
  en('en', 'English', 'الإنجليزية'),
  fr('fr', 'Français', 'الفرنسية'),
  es('es', 'Español', 'الإسبانية'),
  de('de', 'Deutsch', 'الألمانية'),
  it('it', 'Italiano', 'الإيطالية'),
  pt('pt', 'Português', 'البرتغالية'),
  tr('tr', 'Türkçe', 'التركية'),
  ru('ru', 'Русский', 'الروسية')
  ;

  const SourceLanguage(this.code, this.nativeName, this.arabicName);
  final String code;
  final String nativeName;
  final String arabicName;

  bool get isEnglish => this == SourceLanguage.en;

  static SourceLanguage fromCode(String? code) =>
      SourceLanguage.values.firstWhere(
        (l) => l.code == code,
        orElse: () => SourceLanguage.en,
      );
}
