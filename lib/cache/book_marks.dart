// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:dal_commons/commons.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:flutter/foundation.dart';

class BookMarks {
  Map<String, Node> anime;
  Map<String, Node> manga;
  Map<String, Featured> news;
  Map<String, Featured> featured;
  Map<String, CharacterV4Data> character;
  Map<String, PeopleV4Data> person;
  Map<String, UserProf> malUser;
  Map<String, ForumTopicsData> forumTopics;
  Map<String, InterestStack> interestStacks;
  Map<String, ClubHtml> clubs;
  BookMarks({
    required this.anime,
    required this.manga,
    required this.news,
    required this.featured,
    required this.character,
    required this.person,
    required this.clubs,
    required this.forumTopics,
    required this.interestStacks,
    required this.malUser,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'anime': anime,
      'manga': manga,
      'news': news,
      'featured': featured,
      'character': character,
      'person': person,
      'clubs': clubs,
      'forumTopics': forumTopics,
      'interestStacks': interestStacks,
      'malUser': malUser,
    };
  }

  static BookMarks fromJson(Map<String, dynamic>? map) {
    if (map == null || map.isEmpty) {
      return BookMarks(
        anime: {},
        manga: {},
        news: {},
        character: {},
        person: {},
        featured: {},
        clubs: {},
        forumTopics: {},
        interestStacks: {},
        malUser: {},
      );
    }
    return BookMarks(
      anime: fromTJson(map['anime'], (e) => Node.fromJson(e)),
      manga: fromTJson(map['manga'], (e) => Node.fromJson(e)),
      news: fromTJson(map['news'], (e) => Featured.fromJson(e)),
      featured: fromTJson(map['featured'], (e) => Featured.fromJson(e)),
      character:
          fromTJson(map['character'], (e) => CharacterV4Data.fromJson(e)),
      person: fromTJson(map['person'], (e) => PeopleV4Data.fromJson(e)),
      clubs: fromTJson(map['clubs'], (e) => ClubHtml.fromJson(e)),
      forumTopics: fromTJson(
          map['forumTopics'],
          (e) => e.containsKey('topic_id')
              ? ForumHtml.fromJson(e)
              : ForumTopicsData.fromJson(e)),
      interestStacks:
          fromTJson(map['interestStacks'], (e) => InterestStack.fromJson(e)),
      malUser: fromTJson(map['malUser'], (e) => UserProf.fromJson(e)),
    );
  }

  static Map<String, T> fromTJson<T>(
      Map<String, dynamic>? map, T Function(dynamic) fromJson) {
    if (map == null) return {};
    return Map.fromEntries(
        map.entries.map((e) => MapEntry(e.key, fromJson(e.value))));
  }

  @override
  String toString() {
    return 'BookMarks(anime: $anime, manga: $manga, news: $news, featured: $featured)';
  }

  @override
  bool operator ==(covariant BookMarks other) {
    if (identical(this, other)) return true;

    return mapEquals(other.anime, anime) &&
        mapEquals(other.manga, manga) &&
        mapEquals(other.news, news) &&
        mapEquals(other.featured, featured);
  }

  @override
  int get hashCode {
    return anime.hashCode ^ manga.hashCode ^ news.hashCode ^ featured.hashCode;
  }
}
