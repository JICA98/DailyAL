
import 'package:dal_commons/src/model/forum/categories.dart';

class MalResult {
  String? url;
  bool? fromCache;
  DateTime? lastUpdated;
  dynamic data;

  MalResult({this.data, this.url, this.fromCache, this.lastUpdated});

  factory MalResult.fromJson(Map<String, dynamic>? json, dynamic convertType) {
    dynamic result;
    if (json != null) {
      if (convertType is Categories) {
        result = Categories.fromJson(json["data"]);
      }
    }
    return json != null
        ? MalResult(
            url: json["url"],
            fromCache: json["fromCache"] ?? false,
            data: result,
            lastUpdated:
                DateTime.tryParse(json["lastUpdated"]?.toString() ?? "") ??
                    DateTime.now(),
          )
        : MalResult();
  }
  Map<String, dynamic> toJson() {
    return {
      "url": url,
      "fromCache": fromCache ?? false,
      "data": data?.toJson(),
      "lastUpdated": lastUpdated.toString()
    };
  }
}
