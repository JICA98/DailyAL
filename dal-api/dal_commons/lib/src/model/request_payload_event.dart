import 'dart:convert';

class RequestPaylodEvent {
  final Map<String, dynamic> json;
  static RequestPaylodEvent fromJson(Map<String, dynamic> json) =>
      RequestPaylodEvent(json);

  const RequestPaylodEvent(this.json);

  @override
  String toString() {
    return jsonEncode(json);
  }
}
