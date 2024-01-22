class MangaCharacterHtml {
  final String? characterName;
  final String? characterType;
  final String ?animePicture;
  final int? characterId;

  MangaCharacterHtml({
    this.characterName,
    this.characterId,
    this.characterType,
    this.animePicture,
  });

  factory MangaCharacterHtml.fromJson(Map<String, dynamic>? json) {
    return json != null
        ? MangaCharacterHtml(
            characterId: json["characterId"],
            animePicture: json["animePicture"],
            characterName: json["characterName"],
            characterType: json["characterType"],
          )
        : MangaCharacterHtml();
  }

  Map<String, dynamic> toJson() {
    return {
      "characterId": characterId,
      "animePicture": animePicture,
      "characterName": characterName,
      "characterType": characterType,
    };
  }
}
