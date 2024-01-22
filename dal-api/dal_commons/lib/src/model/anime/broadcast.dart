class Broadcast {
  final String? startTime;
  final String? dayOfTheWeek;

  Broadcast({this.dayOfTheWeek, this.startTime});

  factory Broadcast.fromJson(Map<String, dynamic>? json) {
    return json != null
        ? Broadcast(
            dayOfTheWeek: json["day_of_the_week"],
            startTime: json["start_time"])
        : Broadcast();
  }

  Map<String, dynamic> toJson() {
    return {"start_time": startTime, "day_of_the_week": dayOfTheWeek};
  }
}
