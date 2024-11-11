// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:pepis/src/services/core_functions.dart';

import 'package:pepis/src/services/functions.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    for (int year = 1990; year <= 2024; year++) {
      for (int month = 1; month <= 12; month++) {
        for (int day = 1; day <= DateTime(year, month + 1, 0).day; day++) {
          DateTime date = DateTime(year, month, day);
          // ignore: unused_local_variable
          var a = getKi(date);
        }
        log('$year $month');
      }
    }
  });
}
