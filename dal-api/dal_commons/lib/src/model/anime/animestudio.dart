class AnimeStudio {
  final String? name;
  final int? id;

  AnimeStudio({this.name, this.id});

  factory AnimeStudio.fromJson(Map<String, dynamic>? json) {
    return json != null
        ? AnimeStudio(id: json["id"], name: json["name"])
        : AnimeStudio();
  }

  Map<String, dynamic> toJson() {
    return {"name": name, "id": id};
  }
}
