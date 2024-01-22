import 'package:html/dom.dart';

class Constants {
  ///EndPoint
  static final String endPoint = "https://api.myanimelist.net/v2/";

  ///Html EndPoint
  static final String htmlEnd = "https://myanimelist.net/";

  ///Client Header
  static final String clientHeader = 'X-MAL-Client-ID';

  static const String jikanV4 = "https://api.jikan.moe/v4/";
}

/// LOG-Config
class LogConfig {
  bool debugMode;
  LogConfig({this.debugMode = true});
}

final dalLogConfig = LogConfig();

/// LOG
void logDal(dynamic message) {
  if (dalLogConfig.debugMode) {
    final time = DateTime.now().toIso8601String();
    if (message == null) {
      print('$time  null');
    } else {
      print('$time  $message');
    }
  }
}

V? tryGet<K, V>(dynamic map, K key) {
  if (map == null) return null;
  if (map.containsKey(key)) {
    return map[key];
  } else {
    return null;
  }
}

extension MapExtension<K, V> on Map<K, V> {
  V? tryAt(K key) {
    if (this == null) return null;
    if (containsKey(key)) {
      return this[key];
    } else {
      return null;
    }
  }
}

extension ListExtension<T> on List<T> {
  T? tryAt([int index = 0]) {
    if (this == null) null;
    if (index < 0) return null;
    if (index >= length) return null;
    try {
      return elementAt(index);
    } catch (e) {
      return null;
    }
  }
}

extension StringExtension on String {
  static final RegExp numberRegExp = RegExp(r'\d');
  static final RegExp alphaDigitExp = RegExp('^[a-zA-Zd]\$');

  String substringToN(int n) {
    if (n >= this.length) {
      return this; // Return the original string if n is greater than or equal to the string's length.
    } else {
      return this.substring(0, n);
    }
  }

  String? capitalize() {
    if (this == null) return null;
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }

  String? capitalizeAll() {
    if (this == null) return null;
    var split = this.split(" ");
    var result = "";
    for (var str in split) {
      result += '${StringExtension(str).capitalize()} ';
    }
    return result.substring(0, result.length - 1);
  }

  bool equals(String? other) {
    if (other == null) return false;
    return compareTo(other) == 0;
  }

  bool notEquals(String? other) {
    return !equals(other);
  }

  bool equalsIgnoreCase(String? other) {
    if (other == null) return false;
    return toLowerCase().compareTo(other.toLowerCase()) == 0;
  }

  String? standardize() {
    return StringExtension(replaceAll("_", " ")).capitalize();
  }

  String? standardizeLower() {
    return replaceAll(" ", "_").toLowerCase();
  }

  String? toDate() {
    if (this == null) return null;
    return substring(0, indexOf(":") - 2);
  }

  bool isAlphaDigit() {
    return (alphaDigitExp.hasMatch(this));
  }

  bool isDigit() {
    return (numberRegExp.hasMatch(this));
  }

  String formattedTitleforSearch() {
    String formattedTitle = "";
    for (int i = 0; i < length; ++i) {
      if (this[i] == ".") {
        continue;
      }
      if (this[i] == " ") {
        formattedTitle += "_";
      } else {
        formattedTitle += this[i];
      }
    }
    return formattedTitle;
  }

  String? getFormattedTitleForHtml([bool includeDigits = false]) {
    if (this == null) return null;
    String formattedTitle = "";
    for (int i = 0; i < length; ++i) {
      if (includeDigits && codeUnitAt(i) ^ 0x30 <= 9) {
        formattedTitle += this[i];
      } else if (this[i].isAlphaDigit()) {
        formattedTitle += this[i];
      } else {
        formattedTitle += "_";
      }
    }
    return formattedTitle;
  }

  String? getOnlyDigits() {
    if (this == null) return null;
    String formattedTitle = "";
    for (int i = 0; i < length; ++i) {
      if (this[i].isDigit()) {
        formattedTitle += this[i];
      }
    }
    return formattedTitle;
  }

  int countAll(String string) {
    int count = 0;
    String current = this;
    while (current.contains(string)) {
      current = current.replaceFirst(string, "");
      count++;
    }
    return count;
  }

  bool get isBlank {
    return trim().equals("");
  }

  bool get isNotBlank {
    return !isBlank;
  }
}

List<String> jikanSearchTypes = ["character", "person"];

bool shouldUpdateContentServer({
  dynamic result,
  double timeinHoursD = 0,
  int timeinHours = 0,
}) {
  try {
    var lastUpdated = result is String
        ? DateTime.parse(result)
        : DateTime.parse(result['lastUpdated']);
    return ((DateTime.now().difference(lastUpdated).inMinutes / 60.0) >=
        (timeinHoursD + timeinHours));
  } catch (e) {
    return true;
  }
}

enum ContentType { anime, manga, character, characters, people, news, featured }

T? queryParamsUri<T>(Uri? uri, String key, [T? defaultValue]) {
  if (uri == null) return defaultValue;
  final value = uri.queryParameters[key];
  if (value == null || value.equals('null')) return defaultValue;
  if (T == bool) {
    return (value == 'true'
        ? true
        : value == 'false'
            ? false
            : defaultValue) as T?;
  } else if (T == int) {
    return (int.tryParse(value) ?? defaultValue) as T?;
  } else {
    try {
      return value as T?;
    } catch (e) {
      return defaultValue;
    }
  }
}

T? queryParamsUrl<T>(String? url, String key, [T? defaultValue]) {
  if (url == null) return null;
  return queryParamsUri(Uri.tryParse(url), key, defaultValue);
}

extension ElementExt on Element {
  Element? getElementByTag(String tagName) {
    if (this == null) return null;
    var list = getElementsByTagName(tagName) ?? [];
    return list.isEmpty ? null : list.first;
  }

  Element? getElementByClass(String classNames) {
    if (this == null) return null;
    var list = getElementsByClassName(classNames) ?? [];
    return list.isEmpty ? null : list.first;
  }
}

extension DocumentExt on Document {
  Element? getElementByTag(String tagName) {
    if (this == null) return null;
    var list = getElementsByTagName(tagName) ?? [];
    return list.isEmpty ? null : list.first;
  }

  Element? getElementByClass(String classNames) {
    if (this == null) return null;
    var list = getElementsByClassName(classNames) ?? [];
    return list.isEmpty ? null : list.first;
  }
}

String buildQueryParams(Map<String, dynamic> queryParams) {
  if (queryParams.isEmpty) {
    return '';
  }
  return queryParams.entries
      .where((p) => p.value != null)
      .map((p) => '${p.key}=${p.value}')
      .join('&');
}

K? switchCase<T, K>(
  T? find,
  Map<List<T>?, K Function(T)?>? values, [
  K? defaultValue,
]) {
  if (find == null || values == null || values.isEmpty) return defaultValue;
  final entries = values.entries;
  for (var entry in entries) {
    final key = entry.key;
    if (key != null && key.contains(find)) {
      final value = entry.value;
      if (value != null) {
        return value(find);
      }
    }
  }
  return defaultValue;
}
