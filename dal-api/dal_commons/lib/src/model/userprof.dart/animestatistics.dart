class UserAnimeStatistics {
  final double? numItemsWatching;
  final double? numItemsCompleted;
  final double? numItemsOnHold;
  final double? numItemsDropped;
  final double? numItemsPlanToWatch;
  final double? numItems;
  final double? numDaysWatched;
  final double? numDaysWatching;
  final double? numDaysCompleted;
  final double? numDaysOnHold;
  final double? numDaysDropped;
  final double? numDays;
  final double? numEpisodes;
  final double? numTimesRewatched;
  final double? meanScore;

  UserAnimeStatistics(
      {this.numItemsWatching,
      this.numItemsCompleted,
      this.numItemsOnHold,
      this.numItemsDropped,
      this.numItemsPlanToWatch,
      this.numItems,
      this.numDaysWatched,
      this.numDaysWatching,
      this.numDaysCompleted,
      this.numDaysOnHold,
      this.numDaysDropped,
      this.numDays,
      this.numEpisodes,
      this.numTimesRewatched,
      this.meanScore});

  factory UserAnimeStatistics.fromJson(Map<String, dynamic>? json) {
    return json != null
        ? UserAnimeStatistics(
            meanScore: double.tryParse(json["mean_score"].toString()),
            numDays: double.tryParse(json["num_days"].toString()),
            numDaysCompleted:
                double.tryParse(json["num_days_completed"].toString()),
            numDaysDropped:
                double.tryParse(json["num_days_dropped"].toString()),
            numDaysOnHold: double.tryParse(json["num_days_on_hold"].toString()),
            numDaysWatched:
                double.tryParse(json["num_days_watched"].toString()),
            numDaysWatching:
                double.tryParse(json["num_days_watching"].toString()),
            numEpisodes: double.tryParse(json["num_episodes"].toString()),
            numItems: double.tryParse(json["num_items"].toString()),
            numItemsCompleted:
                double.tryParse(json["num_items_completed"].toString()),
            numItemsDropped:
                double.tryParse(json["num_items_dropped"].toString()),
            numItemsOnHold:
                double.tryParse(json["num_items_on_hold"].toString()),
            numItemsPlanToWatch:
                double.tryParse(json["num_items_plan_to_watch"].toString()),
            numItemsWatching:
                double.tryParse(json["num_items_watching"].toString()),
            numTimesRewatched:
                double.tryParse(json["num_times_rewatched"].toString()))
        : UserAnimeStatistics();
  }

  Map<String, dynamic> toJson() {
    return {
      "num_items_watching": numItemsWatching,
      "num_items_completed": numItemsCompleted,
      "num_items_on_hold": numItemsOnHold,
      "num_items_dropped": numItemsDropped,
      "num_items_plan_to_watch": numItemsPlanToWatch,
      "num_items": numItems,
      "num_days_watched": numDaysWatched,
      "num_days_watching": numDaysWatching,
      "num_days_completed": numDaysCompleted,
      "num_days_on_hold": numDaysOnHold,
      "num_days_dropped": numDaysDropped,
      "num_days": numDays,
      "num_episodes": numEpisodes,
      "num_times_rewatched": numTimesRewatched,
      "mean_score": meanScore
    };
  }
}
