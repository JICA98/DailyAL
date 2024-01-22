import 'package:dailyanimelist/main.dart';
import 'package:flutter/material.dart';

import 'theme.dart';

class UserThemeData {
  static final colors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
  ];
  static Map<String, Color> _colorSchemeMap = {
    UserThemeColor.Red.name: Colors.red,
    UserThemeColor.Pink.name: Colors.pink,
    UserThemeColor.Purple.name: Colors.purple,
    UserThemeColor.DeepPurple.name: Colors.deepPurple,
    UserThemeColor.Indigo.name: Colors.indigo,
    UserThemeColor.Blue.name: Colors.blue,
    UserThemeColor.LightBlue.name: Colors.lightBlue,
    UserThemeColor.Cyan.name: Colors.cyan,
    UserThemeColor.Teal.name: Colors.teal,
    UserThemeColor.Green.name: Colors.green,
    UserThemeColor.LightGreen.name: Colors.lightGreen,
    UserThemeColor.Lime.name: Colors.lime,
    UserThemeColor.Yellow.name: Colors.yellow,
    UserThemeColor.Amber.name: Colors.amber,
    UserThemeColor.Orange.name: Colors.orange,
    UserThemeColor.DeepOrange.name: Colors.deepOrange,
    UserThemeColor.Brown.name: Colors.brown,
    UserThemeColor.Grey.name: Color(0xff1F1F1F),
    UserThemeColor.Black.name: Color.fromARGB(255, 2, 0, 27),
  };

  static Map<String, Color> get colorSchemeMap {
    return {
      ..._colorSchemeMap,
      ...user.theme.userDefinedColors
          .map((key, value) => MapEntry(key, Color(value)))
    };
  }

  static final Map<String, String> v2ToV3ThemeMap = {
    "spring": UserThemeColor.Pink.name,
    "summer": UserThemeColor.DeepOrange.name,
    "fall": UserThemeColor.Brown.name,
    "winter": UserThemeColor.LightBlue.name,
    "dust": UserThemeColor.Grey.name,
    "night": UserThemeColor.Black.name,
    "day": UserThemeColor.Grey.name,
    "day_spring": UserThemeColor.Pink.name,
    "day_summer": UserThemeColor.DeepOrange.name,
    "day_fall": UserThemeColor.Brown.name,
    "day_winter": UserThemeColor.LightBlue.name,
    "dracula": UserThemeColor.Red.name,
    "dust_dracula": UserThemeColor.Red.name
  };
}
