class Picture {
  final String? medium;
  final String? large;

  Picture({this.large, this.medium});

  factory Picture.fromJson(Map<String, dynamic>? json) {
    return json != null
        ? Picture(
            large: json["large"].toString(), medium: json["medium"].toString())
        : Picture();
  }

  Map<String, dynamic> toJson() {
    return {"medium": medium, "large": large};
  }
}
