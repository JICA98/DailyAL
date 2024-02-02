enum LinkType {
  resources,
  availableAt,
  streaming,
  otherLists,
}

class AnimeLink {
  final String name;
  final String url;
  final String? imageUrl;
  final LinkType linkType;

  AnimeLink({
    required this.name,
    required this.url,
    this.imageUrl,
    required this.linkType,
  });

  static AnimeLink? fromJson(Map<String, dynamic>? map) {
    if (map == null) return null;
    return AnimeLink(
      name: map['name'] ?? '?',
      url: map['url'] ?? '',
      imageUrl: map['imageUrl'],
      linkType: LinkType.values.firstWhere(
        (e) => e.name == map['linkType'],
        orElse: () => LinkType.resources,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
      'imageUrl': imageUrl,
      'linkType': linkType.name,
    };
  }
}
