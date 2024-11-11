import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pepis/src/enums.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'src/services/core_functions.dart';

// Dynamic
DateTime epoch = DateTime.fromMillisecondsSinceEpoch(0);
DateTime get now => DateTime.now();

// Declare
late AppLocalizations lang;
late ThemeData theme;
late ColorScheme palette;


// Constants
const Color femalePink = Color.fromARGB(255, 239, 131, 255);
const Color maleBlue = Color.fromARGB(255, 69, 143, 255);

Map<int, int> _generateKuaMapping(int startYear, int endYear, int startValue, List<int> pattern) {
  Map<int, int> kuaMap = {};
  int patternLength = pattern.length;

  for (int year = startYear; year <= endYear; year++) {
    // Calculate the index in the pattern for the current year
    int patternIndex = (year - startYear) % patternLength;
    kuaMap[year] = pattern[patternIndex];
  }

  return kuaMap;
}

final Map<int, int> kuaFemale = _generateKuaMapping(1930, now.year + 100, 8, [8, 9, 1, 2, 3, 4, 8, 6, 7]);
final Map<int, int> kuaMale = _generateKuaMapping(1930, now.year + 100, 8, [7, 6, 2, 4, 3, 2, 1, 9, 8]);

//TODO fix out of range error
List<List<String>> dataTable({int shift = 0}) {
  List<List<String>> table = [];

  List<int> firstNumbers = [9, 8, 7, 6, 5, 4, 3, 2, 1];
  List<int> secondStartValues = [5, 4, 3, 2, 1, 9, 8, 7, 6];
  List<int> thirdStartValues = [9, 1, 2, 3, 4, 5, 6, 7, 8];

  for (int row = 0; row < 9; row++) {
    int first = firstNumbers[row];

    int second = (secondStartValues[row] - shift) % 9;
    second = second <= 0 ? second + 9 : second;

    int third = (thirdStartValues[row] + shift) % 9;
    third = third == 0 ? 9 : third;

    List<String> rowData = [];

    for (int col = 0; col < 12; col++) {
      rowData.add('$first.$second.$third');

      second = (second - 1 == 0) ? 9 : second - 1; // Decrease and wrap at 1
      third = (third + 1 > 9) ? 1 : third + 1; // Increase and wrap at 9
    }

    table.add(rowData);
  }
  return table;
}

final List<Map<String, dynamic>> dateRanges = [
  {"range": "4 Feb - 5 Mar", "start": DateTime(0, 2, 4), "end": DateTime(0, 3, 5)},
  {"range": "6 Mar - 5 Apr", "start": DateTime(0, 3, 6), "end": DateTime(0, 4, 5)},
  {"range": "6 Apr - 5 May", "start": DateTime(0, 4, 6), "end": DateTime(0, 5, 5)},
  {"range": "6 May - 5 Jun", "start": DateTime(0, 5, 6), "end": DateTime(0, 6, 5)},
  {"range": "6 Jun - 7 Jul", "start": DateTime(0, 6, 6), "end": DateTime(0, 7, 7)},
  {"range": "8 Jul - 7 Ago", "start": DateTime(0, 7, 8), "end": DateTime(0, 8, 7)},
  {"range": "8 Ago - 7 Sep", "start": DateTime(0, 8, 8), "end": DateTime(0, 9, 7)},
  {"range": "8 Sep - 8 Oct", "start": DateTime(0, 9, 8), "end": DateTime(0, 10, 8)},
  {"range": "9 Oct - 7 Nov", "start": DateTime(0, 10, 9), "end": DateTime(0, 11, 7)},
  {"range": "8 Nov - 7 Dic", "start": DateTime(0, 11, 8), "end": DateTime(0, 12, 7)},
  {"range": "8 Dic - 5 Ene", "start": DateTime(0, 12, 8), "end": DateTime(1, 1, 5)},
  {"range": "6 Ene - 3 Feb", "start": DateTime(1, 1, 6), "end": DateTime(1, 2, 3)},
];

final Map<Direction, StarDistribution> directionLookupLong = {
  Direction.E: StarDistribution(1, 2, 4, -2, -4, -1, 3, -3),
  Direction.N: StarDistribution(3, 4, 2, -4, -2, -3, 1, -1),
  Direction.NE: StarDistribution(-3, -4, -2, 4, 2, 3, -1, 1),
  Direction.NW: StarDistribution(-1, -2, -4, 2, 4, 1, -3, 3),
  Direction.S: StarDistribution(4, 3, 1, -3, -1, -4, 2, -2),
  Direction.SE: StarDistribution(2, 1, 3, -1, -3, -2, 4, -4),
  Direction.SW: StarDistribution(-2, -1, -3, 1, 3, 2, -4, 4),
  Direction.W: StarDistribution(-4, -3, -1, 3, 1, 4, -2, 2),
};

final Map<DateTime, int> dateIndexTable = {
  DateTime(0, 1, 5): 12,
  DateTime(0, 2, 3): 1,
  DateTime(0, 3, 5): 2,
  DateTime(0, 4, 5): 3,
  DateTime(0, 5, 5): 4,
  DateTime(0, 6, 5): 5,
  DateTime(0, 7, 7): 6,
  DateTime(0, 8, 7): 7,
  DateTime(0, 9, 7): 8,
  DateTime(0, 10, 8): 9,
};

final Map<int, Direction> directionLookup = {
  1: Direction.N,
  2: Direction.SW,
  3: Direction.E,
  4: Direction.SE,
  6: Direction.NW,
  7: Direction.W,
  8: Direction.NE,
  9: Direction.S,
};

final Map<int, Materials> materialLookup = {
  1: Materials.Water,
  2: Materials.Earth,
  3: Materials.Wood,
  4: Materials.Wood,
  5: Materials.Earth,
  6: Materials.Metal,
  7: Materials.Metal,
  8: Materials.Earth,
  9: Materials.Fire,
};
