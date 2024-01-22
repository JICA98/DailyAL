class SerializationMangaNode {
  final int? id;
  final String? name;

  SerializationMangaNode({this.name, this.id});

  factory SerializationMangaNode.fromJson(Map<String, dynamic>? json) {
    if (json == null) return SerializationMangaNode();
    final dynNode = json['node'] ?? json;
    return SerializationMangaNode(
      name: dynNode != null ? dynNode['name'] : null,
      id: dynNode != null ? dynNode['id'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "name": name};
  }
}
