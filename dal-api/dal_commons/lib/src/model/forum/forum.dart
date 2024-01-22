import 'package:dal_commons/src/model/forum/board.dart';

class Forum {
  final String? title;
  final List<Board>? boards;

  Forum({this.title, this.boards});

  factory Forum.fromJson(Map<String, dynamic>? json) {
    return json != null
        ? (Forum(
            title: json["title"],
            boards: List.from(json["boards"] ?? [])
                .map((e) => Board.fromJson(e))
                .toList()))
        : Forum();
  }

  Map<String, dynamic> toJson() {
    return {"title": title, "boards": boards};
  }
}
