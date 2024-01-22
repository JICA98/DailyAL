import 'package:dal_commons/src/model/forum/forum.dart';

class Categories {
  final List<Forum>? forums;
  String? url;
  bool? fromCache;
  DateTime? lastUpdated;

  Categories({
    this.forums,
    this.fromCache,
    this.lastUpdated,
    this.url,
  });

  factory Categories.fromJson(Map<String, dynamic>? json) {
    return json != null
        ? (Categories(
            url: json["url"],
            fromCache: json["fromCache"] ?? false,
            lastUpdated:
                DateTime.tryParse(json["lastUpdated"]?.toString() ?? "") ??
                    DateTime.now(),
            forums: List.from(json["categories"] ?? [])
                .map((e) => Forum.fromJson(e))
                .toList()))
        : Categories();
  }

  Map<String, dynamic> toJson() {
    return {
      "categories": forums,
      "url": url,
      "fromCache": fromCache ?? false,
      "lastUpdated": lastUpdated.toString(),
    };
  }
}
