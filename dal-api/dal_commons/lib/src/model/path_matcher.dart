import 'package:shelf/shelf.dart';

class PathMatcher {
  final String path;
  final Future<Map<String, dynamic>> Function(PathMatcher, Request) handler;
  final List<String> mandatoryCachedFeilds;
  static const list = <String>[];

  const PathMatcher(this.path, this.handler,
      [this.mandatoryCachedFeilds = list]);

  bool hasMatch(String url) {
    final splitPaths = url.split("/");
    if (splitPaths.length != _splitPathLength) {
      return false;
    }
    for (var i = 0; i < _splitPathLength; i++) {
      final pathA = _splitPaths[i];
      final pathB = splitPaths[i];
      if (!pathA.startsWith('*') && pathA.compareTo(pathB) != 0) {
        return false;
      }
    }
    return true;
  }

  List<String> pathParams(String url) {
    final list = <String>[];
    final splitPaths = url.split("/");
    for (var i = 0; i < _splitPathLength; i++) {
      final pathA = _splitPaths[i];
      final pathB = splitPaths[i];
      if (pathA.startsWith('*')) {
        list.add(pathB);
      }
    }
    return list;
  }

  T pathParam<T>(String url, [int at = 0]) {
    final params = pathParams(url);
    if (at >= params.length) {
      throw ArgumentError('Invalid At!');
    }
    if (T == int) {
      return int.tryParse(params[at]) as T;
    }
    return params[at] as T;
  }

  List<String> get _splitPaths => path.split("/");
  int get _splitPathLength => _splitPaths.length;
}
