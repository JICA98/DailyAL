class MalGenre {
  final int? id;
  final String? name;

  MalGenre({this.id, this.name});
  factory MalGenre.fromJson(Map<String, dynamic>? json) {
    return json != null
        ? MalGenre(id: json["id"], name: json["name"])
        : MalGenre();
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "name": name};
  }
}
