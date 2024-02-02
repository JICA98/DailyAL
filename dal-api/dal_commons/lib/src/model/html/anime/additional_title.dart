class AdditionalTitle {
  String title;
  String language;

  AdditionalTitle({
    required this.title,
    required this.language,
  });

  factory AdditionalTitle.fromJson(Map<String, dynamic>? json) {
    return json != null
        ? AdditionalTitle(
            title: json["title"],
            language: json["language"],
          )
        : AdditionalTitle(title: "", language: "");
  }

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "language": language,
    };
  }
}