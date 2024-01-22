// To parse this JSON data, do
//
//     final contentAllCharData = contentAllCharDataFromJson(jsonString);

import 'dart:convert';

ContentAllCharData contentAllCharDataFromJson(String str) =>
    ContentAllCharData.fromJson(json.decode(str));

String contentAllCharDataToJson(ContentAllCharData data) =>
    json.encode(data.toJson());

class ContentAllCharData {
  final Data? data;
  final DateTime? lastUpdated;
  final bool? fromCache;
  final String? url;

  ContentAllCharData({
    this.data,
    this.lastUpdated,
    this.fromCache,
    this.url,
  });

  factory ContentAllCharData.fromJson(Map<String, dynamic> ?json) => json == null
      ? ContentAllCharData()
      : ContentAllCharData(
          data: Data.fromJson(json["data"]),
          lastUpdated: DateTime.parse(json["lastUpdated"]),
          fromCache: json["fromCache"],
          url: json["url"],
        );

  Map<String, dynamic> toJson() => {
        "data": data?.toJson(),
        "lastUpdated": lastUpdated?.toIso8601String(),
        "fromCache": fromCache,
        "url": url,
      };
}

class Data {
  final List<Character> ?characters;
  final List<Staff>? staffs;

  Data({
    this.characters,
    this.staffs,
  });

  factory Data.fromJson(Map<String, dynamic>? json) => json == null
      ? Data()
      : Data(
          characters: List<Character>.from(
              json["characters"].map((x) => Character.fromJson(x))),
          staffs:
              List<Staff>.from(json["staffs"].map((x) => Staff.fromJson(x))),
        );

  Map<String, dynamic> toJson() => {
        "characters": List<dynamic>.from(characters?.map((x) => x.toJson()) ?? []),
        "staffs": List<dynamic>.from(staffs?.map((x) => x.toJson()) ?? []),
      };
}

class Character {
  final Staff? charInfo;
  final CharsImage? characterImage;
  final List<StaffInfoList>? staffInfoList;

  Character({
    this.charInfo,
    this.characterImage,
    this.staffInfoList,
  });

  factory Character.fromJson(Map<String, dynamic>? json) => json == null
      ? Character()
      : Character(
          charInfo: Staff.fromJson(json["charInfo"]),
          characterImage: CharsImage.fromJson(json["characterImage"]),
          staffInfoList: List<StaffInfoList>.from(
              json["staffInfoList"].map((x) => StaffInfoList.fromJson(x))),
        );

  Map<String, dynamic> toJson() => {
        "charInfo": charInfo?.toJson(),
        "characterImage": characterImage?.toJson(),
        "staffInfoList":
            List<dynamic>.from(staffInfoList?.map((x) => x.toJson()) ?? []),
      };
}

class Staff {
  final int? id;
  final String ?role;
  final String ?name;
  final int? favorites;
  final CharsImage? image;

  Staff({
    this.id,
    this.role,
    this.name,
    this.favorites,
    this.image,
  });

  factory Staff.fromJson(Map<String, dynamic> ?json) => json == null
      ? Staff()
      : Staff(
          id: json["id"],
          role: json["role"],
          name: json["name"],
          favorites: json["favorites"],
          image: CharsImage.fromJson(json["image"]),
        );

  Map<String, dynamic> toJson() => {
        "id": id,
        "role": role,
        "name": name,
        "favorites": favorites,
        "image": image?.toJson(),
      };
}

class CharsImage {
  final String? medium;
  final String ?large;

  CharsImage({
    this.medium,
    this.large,
  });

  factory CharsImage.fromJson(Map<String, dynamic>? json) => json == null
      ? CharsImage()
      : CharsImage(
          medium: json["medium"],
          large: json["large"],
        );

  Map<String, dynamic> toJson() => {
        "medium": medium,
        "large": large,
      };
}

class StaffInfoList {
  final int ?id;
  final String? name;
  final String? language;
  final CharsImage? image;

  StaffInfoList({
    this.id,
    this.name,
    this.language,
    this.image,
  });

  factory StaffInfoList.fromJson(Map<String, dynamic>? json) => json == null
      ? StaffInfoList()
      : StaffInfoList(
          id: json["id"],
          name: json["name"],
          image: CharsImage.fromJson(json["image"]),
          language: json["language"],
        );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "language": language,
        'image': image?.toJson(),
      };
}
