import 'package:dal_commons/src/model/manga/authornode.dart';

class MangaAuthors {
  final String ? role;
  final AuthorNode? author;

  MangaAuthors({this.author, this.role});

  factory MangaAuthors.fromJson(Map<String, dynamic>? json) {
    return json != null
        ? MangaAuthors(
            author: AuthorNode.fromJson(json["node"]), role: json["role"])
        : MangaAuthors();
  }

  Map<String, dynamic> toJson() {
    return {"role": role, "node": author};
  }
}
