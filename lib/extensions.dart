import 'package:flutter/widgets.dart';
import 'package:dal_commons/dal_commons.dart';

extension NavigatorStateExtension on NavigatorState {
  void pushNamedIfNotCurrent(String routeName, {Object? arguments}) {
    if (!isCurrent(routeName)) {
      pushNamed(routeName, arguments: arguments);
    }
  }

  bool isCurrent(String routeName) {
    bool isCurrent = false;
    popUntil((route) {
      if (route.settings.name == routeName) {
        isCurrent = true;
      }
      return true;
    });
    return isCurrent;
  }
}

extension MapExt on Map {
  bool containsKeyIgnoreCase(String? key) {
    if (this == null) return false;
    if (key == null) return false;
    bool contains = false;
    keys.forEach((element) {
      if (element != null && element.toString().equalsIgnoreCase(key)) {
        contains = true;
      }
    });
    return contains;
  }
}

extension IterableExtensions<E> on Iterable<E> {
  Iterable<List<E>> chunked(int chunkSize) sync* {
    if (length <= 0) {
      yield [];
      return;
    }
    int skip = 0;
    while (skip < length) {
      final chunk = this.skip(skip).take(chunkSize);
      yield chunk.toList(growable: false);
      skip += chunkSize;
      if (chunk.length < chunkSize) return;
    }
  }
}
