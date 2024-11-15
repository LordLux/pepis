// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:pepis/src/enums.dart';
import 'package:pepis/src/services/core_functions.dart';

import 'package:pepis/src/services/functions.dart';

void main() {
  test('KI test', () async {
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

  test("KiA and KiB test", () {
    for (int year = 1990; year <= 2024; year++) {
      for (int month = 1; month <= 12; month++) {
        for (int day = 1; day <= DateTime(year, month + 1, 0).day; day++) {
          DateTime birthDate = DateTime(year, month, day);
          final Gender gender = Random().nextBool() ? Gender.M : Gender.F;

          final total = sumOfYearDigits(birthDate.year);
          logInfo('total: $total');

          final kiA = getPartKi(total, true);
          final kiB = getPartKi(total, false);
          logInfo('kiA: $kiA, kiB: $kiB');

          final energy = getEnergy(birthDate.year, kiA, kiB);
          logInfo('energy: $energy');

          final kua = getKua(birthDate, gender);
          logInfo('kua: $kua');

          final direction = vDirectionLookup(kua);
          logInfo('direction: $direction');

          final material = vMaterialLookup(energy);
          logInfo('material: $material');

          final starDistribution = getStarDistribution(direction);
          logInfo('starDistribution: ${starDistribution.string}');
        }
        log('$year $month');
      }
    }
  });

  test('KUA test', () async {
    int? lastValue;
    for (int year = 1930; year <= 2024; year++) {
      for (int month = 1; month <= 2; month++) {
        for (int day = 1; day <= DateTime(year, month + 1, 0).day; day++) {
          DateTime date = DateTime(year, month, day);
          int currentValue = getKua(date, Gender.M);
          int currentValue2 = getKua(date, Gender.F);

          if (currentValue != lastValue) {
            int y = date.year + 1;
            if (date.year >= 2000) y -= 1;
            print('$y - H $currentValue | M $currentValue2');
            lastValue = currentValue;
          }
        }
      }
    }
  });
}
