// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Streaming {
  final String? title;
  final String? link;

  Streaming({
    this.title,
    this.link,
  });
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'link': link,
    };
  }

  factory Streaming.fromMap(Map<String, dynamic> map) {
    return Streaming(
      title: map['title'] as String,
      link: map['link'] as String,
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory Streaming.fromJson(String source) =>
      Streaming.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Streaming(title: $title, link: $link)';

  @override
  bool operator ==(covariant Streaming other) {
    if (identical(this, other)) return true;

    return other.title == title && other.link == link;
  }

  @override
  int get hashCode => title.hashCode ^ link.hashCode;
}
