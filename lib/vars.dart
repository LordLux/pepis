import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pepis/src/enums.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Dynamic
DateTime epoch = DateTime.fromMillisecondsSinceEpoch(0);
DateTime get now => DateTime.now();

// Declare
late AppLocalizations lang;

// Settings
DateFormats dateFormat = DateFormats.DMY;

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

final Map<int, int> kuaFemale = _generateKuaMapping(1930, now.year + 100, 8,  [8, 9, 1, 2, 3, 4, 8, 6, 7]);
final Map<int, int> kuaMale = _generateKuaMapping(1930, now.year + 100, 8,  [7, 6, 2, 4, 3, 2, 1, 9, 8]);

List<List<String>> dataTable({int shift = 0}) {
  // Initialize the table
  List<List<String>> table = [];

  // Headers go from 9 down to 1 for each row
  List<int> firstNumbers = [9, 8, 7, 6, 5, 4, 3, 2, 1]; // Row headers
  List<int> secondStartValues = [5, 4, 3, 2, 1, 9, 8, 7, 6]; // Starting values for the second number
  List<int> thirdStartValues = [9, 1, 2, 3, 4, 5, 6, 7, 8];  // Starting values for the third number

  // Generate each row
  for (int row = 0; row < 9; row++) {
    int first = firstNumbers[row];

    // Apply the shift to the second and third numbers, with wrap-around logic
    int second = (secondStartValues[row] - shift) % 9;
    second = second <= 0 ? second + 9 : second;

    int third = (thirdStartValues[row] + shift) % 9;
    third = third == 0 ? 9 : third;

    // List to hold the row data
    List<String> rowData = [];

    // Generate each cell in the row
    for (int col = 0; col < 9; col++) {
      // Add the current cell to the row
      rowData.add('$first.$second.$third');

      // Update second and third values for the next cell
      second = (second - 1 == 0) ? 9 : second - 1; // Decrease and wrap at 1
      third = (third + 1 > 9) ? 1 : third + 1;     // Increase and wrap at 9
    }

    // Add the row to the table
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

final Map<Direction, String> directionLookupLong = {
  Direction.E: "E(+1) SE(+2) S(+4) SW(-2) W(-4) NW(-1) N(+3) NE(-3)",
  Direction.N: "E(+3) SE(+4) S(+2) SW(-4) W(-2) NW(-3) N(+1) NE(-1)",
  Direction.NE: "E(-3) SE(-4) S(-2) SW(+4) W(+2) NW(+3) N(-1) NE(+1)",
  Direction.NW: "E(-1) SE(-2) S(-4) SW(+2) W(+4) NW(+1) N(-3) NE(+3)",
  Direction.S: "E(+4) SE(+3) S(+1) SW(-3) W(-1) NW(-4) N(+2) NE(-2)",
  Direction.SE: "E(+2) SE(+1) S(+3) SW(-1) W(-3) NW(-2) N(+4) NE(-4)",
  Direction.SW: "E(-2) SE(-1) S(-3) SW(+1) W(+3) NW(+2) N(-4) NE(+4)",
  Direction.W: "E(-4) SE(-3) S(-1) SW(+3) W(+1) NW(+4) N(-2) NE(+2)",
};


String dateToStringFormattedES(DateTime date,[String divider = "/"]) => DateFormat("dd${divider}MMM", "es").format(date);
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