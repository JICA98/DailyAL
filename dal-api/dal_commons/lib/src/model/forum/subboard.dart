class SubBoard {
  final int? id;
  final String ?title;

  SubBoard({this.id, this.title});

  factory SubBoard.fromJson(Map<String, dynamic>? json) {
    return json != null
        ? (SubBoard(id: json["id"], title: json["title"]))
        : SubBoard();
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "title": title};
  }
}
