import 'package:html/dom.dart';

extension ElementExt on Element {
  Element? getElementByTag(String? tagName) {
    if (this == null) return null;
    var list = this.getElementsByTagName(tagName ?? '') ?? [];
    return list.isEmpty ? null : list.first;
  }

  Element? getElementByClass(String? classNames) {
    if (this == null) return null;
    var list = this.getElementsByClassName(classNames ?? '') ?? [];
    return list.isEmpty ? null : list.first;
  }
}

extension DocumentExt on Document {
  Element? getElementByTag(String? tagName) {
    if (this == null) return null;
    var list = this.getElementsByTagName(tagName ?? '') ?? [];
    return list.isEmpty ? null : list.first;
  }

  Element? getElementByClass(String? classNames) {
    if (this == null) return null;
    var list = this.getElementsByClassName(classNames ?? '') ?? [];
    return list.isEmpty ? null : list.first;
  }
}
