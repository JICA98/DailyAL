import 'dart:io';

class Environment {
  Environment._();
  static Environment i = Environment._();
  String? _malClientId;

  Map<String, Object> get environment {
    return Platform.environment;
  }

  set malClientId(String? id) {
    _malClientId = id;
  }

  String? get malClientId {
    return _malClientId ?? '${environment['MAL_CLIENT_ID']}';
  }
}
