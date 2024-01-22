import 'package:dal_commons/src/model/forum/subboard.dart';

class Board {
  final int? id;
  final String ?title;
  final String ?description;
  final List<SubBoard>? subBoards;

  Board({this.description, this.id, this.title, this.subBoards});

  factory Board.fromJson(Map<String, dynamic> ?json) {
    return json != null
        ? (Board(
            id: json["id"],
            description: json["description"],
            title: json["title"],
            subBoards: List.from(json["subboards"] ?? [])
                .map((e) => SubBoard.fromJson(e))
                .toList()))
        : Board();
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "desciption": description,
      "title": title,
      "subboards": subBoards
    };
  }
}
