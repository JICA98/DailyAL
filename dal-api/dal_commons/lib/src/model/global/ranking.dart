class Ranking {
  final int? rank;

  Ranking({this.rank});

  factory Ranking.fromJson(Map<String, dynamic>? json) {
    return json != null ? (Ranking(rank: json["rank"])) : Ranking();
  }

  Map<String, dynamic> toJson() {
    return {"rank": rank};
  }
}
