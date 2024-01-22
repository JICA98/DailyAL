class ThemeSong {
  final int? id;
  final int? animeId;
  final String? name;

  ThemeSong({this.id, this.animeId, this.name});

  factory ThemeSong.fromJson(Map<String, dynamic>? json) {
    return json != null
        ? ThemeSong(
            id: json["id"], name: json["text"], animeId: json["anime_id"])
        : ThemeSong();
  }

  Map<String, dynamic> toJson() {
    return {"text": name, "id": id, "anime_id": animeId};
  }
}
