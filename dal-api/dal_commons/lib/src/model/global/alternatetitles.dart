class AlternateTitles {
  final List<String>? synonyms;
  final String? en;
  final String? ja;

  AlternateTitles({this.synonyms, this.en, this.ja});

  factory AlternateTitles.fromJson(Map<String, dynamic>? json) {
    return json != null
        ? AlternateTitles(
            en: json["en"],
            ja: json["ja"],
            synonyms: List<String>.from(json["synonyms"]))
        : AlternateTitles();
  }

  Map<String, dynamic> toJson() {
    return {
      "synonyms": synonyms ?? [],
      "en": en,
      "ja": ja,
    };
  }
}
