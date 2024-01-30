import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'theme.g.dart';

enum UserThemeMode { Auto, Light, Dark, Black }

enum UserThemeColor {
  Auto,
  Red,
  Pink,
  Purple,
  DeepPurple,
  Indigo,
  Blue,
  LightBlue,
  Cyan,
  Teal,
  Green,
  LightGreen,
  Lime,
  Yellow,
  Amber,
  Orange,
  DeepOrange,
  Brown,
  Grey,
  Black
}

enum UserThemeBg {
  fall,
  spring,
  winter,
  summer,
  night,
}

const backgroundMap = {
  UserThemeBg.fall: 'assets/images/fall.jpg',
  UserThemeBg.summer: 'assets/images/summer.jpg',
  UserThemeBg.night: 'assets/images/opm.jpg',
  UserThemeBg.spring: 'assets/images/cherry.jpg',
  UserThemeBg.winter: 'assets/images/winter.png',
};

Color getTextColor(Color backgroundColor) {
  // Calculate the relative luminance of the background color
  final luminance = (0.2126 * backgroundColor.red + 0.7152 * backgroundColor.green + 0.0722 * backgroundColor.blue) / 255;

  // Choose white or black based on the luminance
  return luminance > 0.5 ? Colors.black : Colors.white;
}

@JsonSerializable()
class UserTheme {
  UserThemeMode themeMode;
  String color;
  UserThemeBg background;
  Map<String, int> userDefinedColors;
  UserTheme(
    this.themeMode,
    this.color,
    this.background,
    this.userDefinedColors,
  );
  factory UserTheme.defaultTheme() {
    return UserTheme(
      UserThemeMode.Auto,
      UserThemeColor.Brown.name,
      UserThemeBg.fall,
      {},
    );
  }
  factory UserTheme.fromJson(Map<String, dynamic> json) =>
      _$UserThemeFromJson(json);
  Map<String, dynamic> toJson() => _$UserThemeToJson(this);
}

class UserThemeV2 {
  int? primaryColor;
  int? textint;

  int? navbarintOrg;
  int? navbarint;
  int? navbarIconint;

  int? appbarint;
  int? appabarTextint;
  int? appabarIconint;
  int? buttonColor;

  String? bg;

  UserThemeV2({
    required this.appabarIconint,
    required this.buttonColor,
    required this.appabarTextint,
    required this.appbarint,
    required this.navbarIconint,
    required this.navbarint,
    required this.navbarintOrg,
    required this.primaryColor,
    required this.bg,
    required this.textint,
  });

  UserThemeV2 copy() {
    return UserThemeV2(
      appabarIconint: appabarIconint,
      appabarTextint: appabarTextint,
      appbarint: appbarint,
      bg: bg,
      buttonColor: buttonColor,
      navbarIconint: navbarIconint,
      navbarint: navbarint,
      navbarintOrg: navbarintOrg,
      primaryColor: primaryColor,
      textint: textint,
    );
  }

  static UserThemeV2? fromJson(Map<String, dynamic>? json) {
    return json != null
        ? UserThemeV2(
            bg: json["bg"],
            buttonColor: json["buttonColor"],
            appabarIconint: json["appabarIconint"],
            appabarTextint: json["appabarTextint"],
            appbarint: json["appbarint"],
            navbarIconint: json["navbarIconint"],
            navbarint: json["navbarint"],
            navbarintOrg: json["navbarintOrg"],
            primaryColor: json["primaryint"],
            textint: json["textint"])
        : null;
  }

  Map<String, dynamic> toJson() {
    return {
      "buttonColor": buttonColor,
      "appabarIconint": appabarIconint,
      "appabarTextint": appabarTextint,
      "appbarint": appbarint,
      "navbarIconint": navbarIconint,
      "navbarint": navbarint,
      "navbarintOrg": navbarintOrg,
      "primaryint": primaryColor,
      "textint": textint,
      "bg": bg,
    };
  }

  factory UserThemeV2.fromValues({
    appabarIconint,
    buttonColor,
    appabarTextint,
    appbarint,
    navbarIconint,
    navbarint,
    navbarintOrg,
    primaryColor,
    bg,
    textint,
  }) {
    return UserThemeV2(
      appabarIconint: appabarIconint,
      appabarTextint: appabarTextint,
      appbarint: appbarint,
      bg: bg,
      buttonColor: buttonColor,
      navbarIconint: navbarIconint,
      navbarint: navbarint,
      navbarintOrg: navbarintOrg,
      primaryColor: primaryColor,
      textint: textint,
    );
  }
}
