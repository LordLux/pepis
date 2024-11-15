import 'package:flutter/material.dart';
import 'package:pepis/src/enums.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

final chineseNewYearDates = {
  1930: DateTime(1930, 1, 30),
  1931: DateTime(1931, 2, 17),
  1932: DateTime(1932, 2, 6),
  1933: DateTime(1933, 1, 26),
  1934: DateTime(1934, 2, 14),
  1935: DateTime(1935, 2, 4),
  1936: DateTime(1936, 1, 24),
  1937: DateTime(1937, 2, 11),
  1938: DateTime(1938, 1, 31),
  1939: DateTime(1939, 2, 19),
  1940: DateTime(1940, 2, 8),
  1941: DateTime(1941, 1, 27),
  1942: DateTime(1942, 2, 15),
  1943: DateTime(1943, 2, 5),
  1944: DateTime(1944, 1, 25),
  1945: DateTime(1945, 2, 13),
  1946: DateTime(1946, 2, 2),
  1947: DateTime(1947, 1, 22),
  1948: DateTime(1948, 2, 10),
  1949: DateTime(1949, 1, 29),
  1950: DateTime(1950, 2, 17),
  1951: DateTime(1951, 2, 6),
  1952: DateTime(1952, 1, 27),
  1953: DateTime(1953, 2, 14),
  1954: DateTime(1954, 2, 3),
  1955: DateTime(1955, 1, 24),
  1956: DateTime(1956, 2, 12),
  1957: DateTime(1957, 1, 31),
  1958: DateTime(1958, 2, 18),
  1959: DateTime(1959, 2, 8),
  1960: DateTime(1960, 1, 28),
  1961: DateTime(1961, 2, 15),
  1962: DateTime(1962, 2, 5),
  1963: DateTime(1963, 1, 25),
  1964: DateTime(1964, 2, 13),
  1965: DateTime(1965, 2, 2),
  1966: DateTime(1966, 1, 21),
  1967: DateTime(1967, 2, 9),
  1968: DateTime(1968, 1, 30),
  1969: DateTime(1969, 2, 17),
  1970: DateTime(1970, 2, 6),
  1971: DateTime(1971, 1, 27),
  1972: DateTime(1972, 2, 15),
  1973: DateTime(1973, 2, 3),
  1974: DateTime(1974, 1, 23),
  1975: DateTime(1975, 2, 11),
  1976: DateTime(1976, 1, 31),
  1977: DateTime(1977, 2, 18),
  1978: DateTime(1978, 2, 7),
  1979: DateTime(1979, 1, 28),
  1980: DateTime(1980, 2, 16),
  1981: DateTime(1981, 2, 5),
  1982: DateTime(1982, 1, 25),
  1983: DateTime(1983, 2, 13),
  1984: DateTime(1984, 2, 2),
  1985: DateTime(1985, 2, 20),
  1986: DateTime(1986, 2, 9),
  1987: DateTime(1987, 1, 29),
  1988: DateTime(1988, 2, 17),
  1989: DateTime(1989, 2, 6),
  1990: DateTime(1990, 1, 27),
  1991: DateTime(1991, 2, 15),
  1992: DateTime(1992, 2, 4),
  1993: DateTime(1993, 1, 23),
  1994: DateTime(1994, 2, 10),
  1995: DateTime(1995, 1, 31),
  1996: DateTime(1996, 2, 19),
  1997: DateTime(1997, 2, 7),
  1998: DateTime(1998, 1, 28),
  1999: DateTime(1999, 2, 16),
  2000: DateTime(2000, 2, 5),
  2001: DateTime(2001, 1, 24),
  2002: DateTime(2002, 2, 12),
  2003: DateTime(2003, 2, 1),
  2004: DateTime(2004, 1, 22),
  2005: DateTime(2005, 2, 9),
  2006: DateTime(2006, 1, 29),
  2007: DateTime(2007, 2, 18),
  2008: DateTime(2008, 2, 7),
  2009: DateTime(2009, 1, 26),
  2010: DateTime(2010, 2, 14), //24? nah
  2011: DateTime(2011, 2, 3),
  2012: DateTime(2012, 1, 23),
  2013: DateTime(2013, 2, 10),
  2014: DateTime(2014, 1, 31),
  2015: DateTime(2015, 2, 19),
  2016: DateTime(2016, 2, 8),
  2017: DateTime(2017, 1, 28),
  2018: DateTime(2018, 2, 16),
  2019: DateTime(2019, 2, 5),
  2020: DateTime(2020, 1, 25),
  2021: DateTime(2021, 2, 12),
  2022: DateTime(2022, 2, 1),
  2023: DateTime(2023, 1, 22),
  2024: DateTime(2024, 2, 10)
};
