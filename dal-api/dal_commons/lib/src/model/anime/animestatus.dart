class AnimeStatus {
  final String? watching;
  final String? completed;
  final String? onHold;
  final String? dropped;
  final String? planToWatch;

  AnimeStatus(
      {this.completed,
      this.dropped,
      this.onHold,
      this.planToWatch,
      this.watching});

  factory AnimeStatus.fromJson(Map<String, dynamic>? json) {
    return json != null
        ? AnimeStatus(
            completed: json["completed"].toString(),
            dropped: json["dropped"].toString(),
            onHold: json["on_hold"].toString(),
            planToWatch: json["plan_to_watch"].toString(),
            watching: json["watching"].toString())
        : AnimeStatus();
  }

  Map<String, dynamic> toJson() {
    return {
      "watching": watching,
      "completed": completed,
      "dropped": dropped,
      "on_hold": onHold,
      "plan_to_watch": planToWatch
    };
  }
}
