class MalGenre {
  final int? id;
  final String? name;
  final int? count;

  MalGenre({this.id, this.name, this.count});
  factory MalGenre.fromJson(Map<String, dynamic>? json) {
    return json != null
        ? MalGenre(id: json["id"], name: json["name"], count: json["count"])
        : MalGenre();
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "name": name, "count": count};
  }
}

class GenreType {
  final String? type;
  final List<MalGenre>? genres;
  GenreType({this.type, this.genres});
  factory GenreType.fromJson(Map<String, dynamic>? json) {
    return json != null
        ? GenreType(
            type: json["type"],
            genres: List<MalGenre>.from(
                json["genres"].map((x) => MalGenre.fromJson(x))))
        : GenreType();
  }

  Map<String, dynamic> toJson() {
    return {"type": type, "genres": genres};
  }
}
