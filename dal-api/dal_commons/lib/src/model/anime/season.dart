class Season {
  final int? year;
  final String? season;

  Season({this.season, this.year});

  factory Season.fromJson(Map<String, dynamic>? json) {
    return json != null
        ? Season(season: json["season"], year: json["year"])
        : Season();
  }

  Map<String, dynamic> toJson() {
    return {
      "season": season,
      "year": year,
    };
  }
}
