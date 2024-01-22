// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:collection';

import 'package:dal_commons/dal_commons.dart';

enum InterestStackType {
  detailed,
  search,
  content,
}

final Map<String, InterestStackType> interestStackTypeMap = HashMap.from({
  'detailed': InterestStackType.detailed,
  'search': InterestStackType.search,
  'content': InterestStackType.content,
});

class InterestStack extends Node with ToJson {
  final List<String>? imageUrls;
  final String? username;
  final int? entries;
  final String? updatedAt;
  final String? description;
  final int? reStacks;
  InterestStack({
    int? id,
    String? title,
    this.username,
    this.entries,
    this.description,
    this.updatedAt,
    this.imageUrls,
    this.reStacks,
  }) : super(
          id: id,
          title: title,
        );

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'imageUrls': imageUrls,
      'username': username,
      'entries': entries,
      'updatedAt': updatedAt,
      'reStacks': reStacks,
      'description': description,
    };
  }

  factory InterestStack.fromJson(Map<String, dynamic>? map) {
    if (map == null) return InterestStack();
    return InterestStack(
      id: map['id'] as int?,
      title: map['title'] as String?,
      imageUrls: List<String>.from(map['imageUrls'] ?? <String>[]),
      username: map['username'] as String?,
      entries: map['entries'] as int?,
      reStacks: map['reStacks'] as int?,
      description: map['description'],
      updatedAt: map['updatedAt'],
    );
  }
}

class InterestStackDetailed {
  final InterestStack? node;
  final String? createdAt;
  final List<AnimeDetailed>? contentDetailedList;
  final List<InterestStack>? similarStacks;
  final List<InterestStack>? myAnimeListStacks;
  InterestStackDetailed({
    this.createdAt,
    this.node,
    this.myAnimeListStacks,
    this.similarStacks,
    this.contentDetailedList,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'node': node,
      'createdAt': createdAt,
      'similarStacks': similarStacks,
      'myAnimeListStacks': myAnimeListStacks,
      'contentDetailedList': contentDetailedList,
    };
  }

  factory InterestStackDetailed.fromMap(Map<String, dynamic>? map) {
    if (map == null) return InterestStackDetailed();
    return InterestStackDetailed(
      node: InterestStack.fromJson(map['node'] as Map<String, dynamic>?),
      createdAt: map['createdAt'] as String?,
      myAnimeListStacks: List.from(map['myAnimeListStacks']
              ?.map<InterestStack>((x) => InterestStack.fromJson(x)) ??
          []),
      similarStacks: List.from(map['similarStacks']?.map<InterestStack>(
            (x) => InterestStack.fromJson(x as Map<String, dynamic>?),
          ) ??
          []),
      contentDetailedList:
          List.from(map['contentDetailedList']?.map<AnimeDetailed>(
                (x) => AnimeDetailed.fromJson(x as Map<String, dynamic>?),
              ) ??
              []),
    );
  }
}
