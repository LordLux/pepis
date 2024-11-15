import 'package:flutter/material.dart';

import '../src/enums.dart';

class AppConfig {
  static const List<String> supportedLanguage = ['en', 'es'];
  static const String defaultLanguage = 'es';
  static double get screenHeight => MediaQueryData.fromView(WidgetsBinding.instance.renderViews.first.flutterView).size.height;
  static double get screenWidth => MediaQueryData.fromView(WidgetsBinding.instance.renderViews.first.flutterView).size.width;
}

class Settings {
  static DateFormats dateFormat = DateFormats.DMY;
  static bool longMonth = true;
  static ValueNotifier<bool> multiselection = ValueNotifier(false);
  static bool initialStar = true;
  static Curve chosenCurve = Curves.easeInOut;
  static double summarySize = 250;
}

class TabManager {
  // ignore: prefer_final_fields
  static List<Map<String, Icon?>> _tabs = [
    {"2024": null},
  ];

  static get tabs => _tabs;

  static void addTab(Map<String, Icon?> tab) => _tabs.add(tab);

  static void removeTab(String name) => _tabs.remove(_tabs.singleWhere((t) => t.entries.first.key == name));
}
