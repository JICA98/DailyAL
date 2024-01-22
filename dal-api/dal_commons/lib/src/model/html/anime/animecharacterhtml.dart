class AnimeCharacterHtml {
  final String? characterName;
  final String? characterType;
  final String? animePicture;
  final String? seiyuuName;
  final String? seiyuuOrigin;
  final String? seiyuuPicture;
  final int? characterId;
  final int? seiyuuId;

  AnimeCharacterHtml(
      {this.characterName,
      this.characterId,
      this.seiyuuId,
      this.characterType,
      this.animePicture,
      this.seiyuuName,
      this.seiyuuOrigin,
      this.seiyuuPicture});

  factory AnimeCharacterHtml.fromJson(Map<String, dynamic>? json) {
    return json != null
        ? AnimeCharacterHtml(
            characterId: json["characterId"],
            seiyuuId: json["seiyuuId"],
            animePicture: json["animePicture"],
            characterName: json["characterName"],
            characterType: json["characterType"],
            seiyuuName: json["seiyuuName"],
            seiyuuOrigin: json["seiyuuOrigin"],
            seiyuuPicture: json["seiyuuPicture"])
        : AnimeCharacterHtml();
  }

  Map<String, dynamic> toJson() {
    return {
      "characterId": characterId,
      "seiyuuId": seiyuuId,
      "animePicture": animePicture,
      "characterName": characterName,
      "characterType": characterType,
      "seiyuuName": seiyuuName,
      "seiyuuOrigin": seiyuuOrigin,
      "seiyuuPicture": seiyuuPicture,
    };
  }
}
