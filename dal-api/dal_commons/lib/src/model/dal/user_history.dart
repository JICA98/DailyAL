// To parse this JSON data, do
//
//     final historyData = historyDataFromJson(jsonString);

import 'dart:convert';

UserHistoryData historyDataFromJson(String str) => UserHistoryData.fromJson(json.decode(str));

String historyDataToJson(UserHistoryData data) => json.encode(data.toJson());

class UserHistoryData {
    final List<Datum>? data;
    final DateTime? lastUpdated;
    final bool? fromCache;
    final String? url;

    UserHistoryData({
        this.data,
        this.lastUpdated,
        this.fromCache,
        this.url,
    });

    factory UserHistoryData.fromJson(Map<String, dynamic> json) => UserHistoryData(
        data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
        lastUpdated: json["lastUpdated"] == null ? null : DateTime.parse(json["lastUpdated"]),
        fromCache: json["fromCache"],
        url: json["url"],
    );

    Map<String, dynamic> toJson() => {
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "lastUpdated": lastUpdated?.toIso8601String(),
        "fromCache": fromCache,
        "url": url,
    };
}

class Datum {
    final String? id;
    final String? title;
    final String? history;
    final Category? category;
    final String? time;
    String? formattedDate;

    Datum({
        this.id,
        this.title,
        this.history,
        this.category,
        this.time,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        title: json["title"],
        history: json["history"],
        category: categoryValues.map[json["category"]]!,
        time: json["time"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "history": history,
        "category": categoryValues.reverse[category],
        "time": time,
    };
}

enum Category {
    ANIME,
    MANGA
}

final categoryValues = EnumValues({
    "anime": Category.ANIME,
    "manga": Category.MANGA
});

class EnumValues<T> {
    Map<String, T> map;
    late Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
        reverseMap = map.map((k, v) => MapEntry(v, k));
        return reverseMap;
    }
}
