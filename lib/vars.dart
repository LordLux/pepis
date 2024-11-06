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

final Map<int, int> kuaFemale = {
  1930: 8,
  1931: 9,
  1932: 1,
  1933: 2,
  1934: 3,
  1935: 4,
  1936: 8,
  1937: 6,
  1938: 7,
  1939: 8,
  1944: 4,
  1945: 8,
  1946: 6,
  1947: 7,
  1948: 8,
  1949: 9,
  1950: 1,
  1951: 2,
  1952: 3,
  1953: 4,
  1954: 8,
  1955: 6,
  1956: 7,
  1957: 8,
  1958: 9,
  1959: 1,
  1960: 2,
  1961: 3,
  1962: 4,
  1963: 8,
  1964: 6,
  1965: 7,
  1966: 8,
  1967: 9,
  1968: 1,
  1969: 2,
  1970: 3,
  1971: 4,
  1972: 8,
  1973: 6,
  1974: 7,
  1975: 8,
  1976: 9,
  1977: 1,
  1978: 2,
  1979: 3,
  1980: 4,
  1981: 8,
  1982: 6,
  1983: 7,
  1984: 8,
  1985: 9,
  1986: 1,
  1987: 2,
  1988: 3,
  1993: 8,
  1994: 9,
  1995: 1,
  1996: 2,
  1997: 3,
  1998: 4,
  1999: 8,
  2000: 6,
  2001: 7,
  2002: 8,
  2003: 9,
  2004: 1,
  2005: 2,
  2006: 3,
  2007: 4,
  2008: 8,
  2009: 6,
  2010: 7
};

final Map<int, int> kuaMale = {
  1930: 7,
  1931: 6,
  1932: 2,
  1933: 4,
  1934: 3,
  1935: 2,
  1936: 1,
  1937: 9,
  1938: 8,
  1939: 7,
  1944: 2,
  1945: 1,
  1946: 9,
  1947: 8,
  1948: 7,
  1949: 6,
  1950: 2,
  1951: 4,
  1952: 3,
  1953: 2,
  1954: 1,
  1955: 9,
  1956: 8,
  1957: 7,
  1958: 6,
  1959: 2,
  1960: 4,
  1961: 3,
  1962: 2,
  1963: 1,
  1964: 9,
  1965: 8,
  1966: 7,
  1967: 6,
  1968: 2,
  1969: 4,
  1970: 3,
  1971: 2,
  1972: 1,
  1973: 9,
  1974: 8,
  1975: 7,
  1976: 6,
  1977: 2,
  1978: 4,
  1979: 3,
  1980: 2,
  1981: 1,
  1982: 9,
  1983: 8,
  1984: 7,
  1985: 6,
  1986: 2,
  1987: 4,
  1988: 3,
  1993: 7,
  1994: 6,
  1995: 2,
  1996: 4,
  1997: 3,
  1998: 2,
  1999: 1,
  2000: 9,
  2001: 8,
  2002: 7,
  2003: 6,
  2004: 2,
  2005: 4,
  2006: 3,
  2007: 2,
  2008: 1,
  2009: 9,
  2010: 8
};

final List<List<String>> dataTable = [
  // Corresponds to rows DA6 to DI14 in Excel
  ["1.6.9", "2.9.7", "3.3.5", "4.6.3", "5.9.1", "6.3.8", "7.6.6", "8.9.4", "9.3.2"], // Row 1
  ["1.8.7", "2.2.5", "3.5.3", "4.8.1", "5.2.8", "6.5.6", "7.8.4", "8.2.2", "9.5.9"], // Row 2
  ["1.7.8", "2.1.6", "3.4.4", "4.7.2", "5.1.9", "6.4.7", "7.7.5", "8.1.3", "9.4.1"], // Row 3
  ["1.6.9", "2.9.7", "3.3.5", "4.6.3", "5.9.1", "6.3.8", "7.6.6", "8.9.4", "9.3.2"], // Row 4
  ["1.5.1", "2.8.8", "3.2.6", "4.5.4", "5.8.2", "6.2.9", "7.5.7", "8.8.5", "9.2.3"], // Row 5
  ["1.4.2", "2.7.9", "3.1.7", "4.4.5", "5.7.3", "6.1.1", "7.4.8", "8.7.6", "9.1.4"], // Row 6
  ["1.3.3", "2.6.1", "3.8.9", "4.3.6", "5.6.4", "6.9.2", "7.3.9", "8.6.7", "9.1.4"], // Row 7
  ["1.2.4", "2.5.2", "3.8.9", "4.2.7", "5.5.6", "6.8.3", "7.2.1", "8.5.8", "9.8.6"], // Row 8
  ["1.1.5", "2.4.3", "3.7.1", "4.1.8", "5.4.6", "6.7.4", "7.1.2", "8.4.9", "9.7.7"], // Row 9
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


String _a(DateTime date) => DateFormat("dd/MMM", "es").format(date);
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

final Map<String, int> _dateIndexTable = {
  _a(DateTime(0, 1, 5)): 12,
  _a(DateTime(0, 2, 3)): 1,
  _a(DateTime(0, 3, 5)): 2,
  _a(DateTime(0, 4, 5)): 3,
  _a(DateTime(0, 5, 5)): 4,
  _a(DateTime(0, 6, 5)): 5,
  _a(DateTime(0, 7, 7)): 6,
  _a(DateTime(0, 8, 7)): 7,
  _a(DateTime(0, 9, 7)): 8,
  _a(DateTime(0, 10, 8)): 9,
};

final Map<DateTime, DateTime> dateLookupTable = {
  DateTime(2007, 1, 1): DateTime(2015, 1, 5),
  DateTime(2015, 1, 6): DateTime(2015, 2, 3),
  DateTime(2015, 2, 4): DateTime(2015, 3, 5),
  DateTime(2015, 3, 6): DateTime(2015, 4, 5),
  DateTime(2015, 4, 6): DateTime(2015, 5, 5),
  DateTime(2015, 5, 6): DateTime(2015, 6, 5),
  DateTime(2015, 6, 6): DateTime(2015, 7, 7),
  DateTime(2015, 7, 8): DateTime(2015, 8, 7),
  DateTime(2015, 8, 8): DateTime(2015, 9, 7),
  DateTime(2015, 9, 8): DateTime(2015, 10, 8),
};

DateTime defaultDateMapping = DateTime(2015, 1, 5);

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
  1: Materials.water,
  2: Materials.earth,
  3: Materials.wood,
  4: Materials.wood,
  5: Materials.earth,
  6: Materials.metal,
  7: Materials.metal,
  8: Materials.earth,
  9: Materials.fire,
};