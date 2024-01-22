class Paging {
  final String? next;
  final String ?previous;

  Paging({this.next, this.previous});

  factory Paging.fromJson(Map<String, dynamic>? json) {
    return json != null
        ? Paging(next: json["next"], previous: json["previous"])
        : Paging();
  }

  Map<String, dynamic> toJson() {
    return {"next": next, "previous": previous};
  }
}
