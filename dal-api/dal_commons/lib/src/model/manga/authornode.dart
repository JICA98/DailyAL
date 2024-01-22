class AuthorNode {
  final String? firstName;
  final String? lastName;
  final int? id;

  AuthorNode({this.lastName, this.firstName, this.id});

  factory AuthorNode.fromJson(Map<String, dynamic>? json) {
    return json != null
        ? AuthorNode(
            id: json["id"],
            lastName: json["last_name"],
            firstName: json["first_name"])
        : AuthorNode();
  }

  Map<String, dynamic> toJson() {
    return {"first_name": firstName, "last_name": lastName, "id": id};
  }
}
