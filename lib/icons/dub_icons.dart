import 'package:flutter/widgets.dart';
import 'package:dailyanimelist/main.dart' show user;

/// Central place for dub status icons (default + styled).
class DubIcons {
  DubIcons._();

  static const _kFontFam = 'DubStatus';
  static const String? _kFontPkg = null;

  static const IconData style0Dub = IconData(0xE900, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData style0Incomplete = IconData(0xE901, fontFamily: _kFontFam, fontPackage: _kFontPkg);

  static const IconData style1Dub = IconData(0xE902, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData style1Incomplete = IconData(0xE903, fontFamily: _kFontFam, fontPackage: _kFontPkg);

  static const IconData style2Dub = IconData(0xE904, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData style2Incomplete = IconData(0xE905, fontFamily: _kFontFam, fontPackage: _kFontPkg);

  static const IconData style3Dub = IconData(0xE906, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData style3Incomplete = IconData(0xE907, fontFamily: _kFontFam, fontPackage: _kFontPkg);

  static const Map<int, List<IconData>> _stylePairs = {
    0: [style0Dub, style0Incomplete],
    1: [style1Dub, style1Incomplete],
    2: [style2Dub, style2Incomplete],
    3: [style3Dub, style3Incomplete],
  };

  static const Map<int, EdgeInsets> _stylePaddings = {
    0: EdgeInsets.fromLTRB(4, 4, 12, 3),
    1: EdgeInsets.fromLTRB(6, 4, 10, 3),
    2: EdgeInsets.fromLTRB(4, 4, 4, 3),
    3: EdgeInsets.fromLTRB(4, 4, 12, 3),
  };

  static List<IconData> forStyle(dynamic styleKey) {
    final idx = _normalizeStyle(styleKey);
    return _stylePairs[idx] ?? _stylePairs[0]!;
  }

  static EdgeInsets paddingForStyle(dynamic styleKey) {
    final idx = _normalizeStyle(styleKey);
    return _stylePaddings[idx] ?? EdgeInsets.all(5);
  }

  static IconData get preferredDubIcon => forStyle(_safeUserStyle())[0];
  static IconData get preferredIncompleteDubIcon => forStyle(_safeUserStyle())[1];

  static EdgeInsets get preferredPadding => paddingForStyle(_safeUserStyle());

  // Helpers

  static int _normalizeStyle(dynamic v) {
    if (v is int) return v.clamp(0, 3);
    if (v is String) {
      final parsed = int.tryParse(v);
      if (parsed != null) return parsed.clamp(0, 3);
    }
    return 0;
  }

  static dynamic _safeUserStyle() {
    try {
      return user.pref.dubIconStyle;
    } catch (_) {
      return 0;
    }
  }
}
