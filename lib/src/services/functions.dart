import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../vars.dart';
import '../enums.dart';

DateTime? stringToDate(String date, [bool strict = false]) => strict ? _stringToDateStrict(date) : _stringToDateUnStrict(date);

DateTime? _stringToDateStrict(String date) {
  switch (dateFormat) {
    case DateFormats.DMY:
      return DateFormat('dd/MM/yyyy').tryParse(date);
    case DateFormats.MDY:
      return DateFormat('MM/dd/yyyy').tryParse(date);
    case DateFormats.YMD:
      return DateFormat('yyyy/MM/dd').tryParse(date);
  }
}

DateTime? _stringToDateUnStrict(String date) {
  DateTime? a = DateFormat('dd/MM/yyyy').tryParse(date);
  DateTime? b = DateFormat('MM/dd/yyyy').tryParse(date);
  DateTime? c = DateFormat('yyyy/MM/dd').tryParse(date);
  return a ?? b ?? c;
}

String dateToString(DateTime date) {
  switch (dateFormat) {
    case DateFormats.DMY:
      return DateFormat('dd/MM/yyyy').format(date);
    case DateFormats.MDY:
      return DateFormat('MM/dd/yyyy').format(date);
    case DateFormats.YMD:
      return DateFormat('yyyy/MM/dd').format(date);
  }
}

bool isValidDate(String date, [bool strict = false]) => strict ? _isValidDateStrict(date) : _isValidDateUnstrict(date);

bool _isValidDateUnstrict(String date) {
  if (DateFormat('dd/MM/yyyy').tryParse(date) != null) return true;
  if (DateFormat('MM/dd/yyyy').tryParse(date) != null) return true;
  if (DateFormat('yyyy/MM/dd').tryParse(date) != null) return true;
  return false;
}

bool _isValidDateStrict(String date) {
  switch (dateFormat) {
    case DateFormats.DMY:
      if (DateFormat('dd/MM/yyyy').tryParse(date) == null) return false;
    case DateFormats.MDY:
      if (DateFormat('MM/dd/yyyy').tryParse(date) == null) return false;
    case DateFormats.YMD:
      if (DateFormat('yyyy/MM/dd').tryParse(date) == null) return false;
  }
  return true;
}

Future<DateTime?> selectDate(BuildContext context, {DateTime? firstDate, DateTime? lastDate}) async {
  firstDate ??= DateTime(now.year - 150, 0, 0);
  lastDate ??= DateTime(now.year + 150, 0, 0);
  return (await showDatePicker(context: context, firstDate: firstDate, lastDate: lastDate));
}

int sumOfYearDigits(int year) {
  final yearString = year.toString();
  int sum = 0;

  for (int i = 0; i < yearString.length; i++) sum += int.parse(yearString[i]);
  return sum;
}

(String, DateTime) getKi(DateTime birthDate) {
  int birthYear = birthDate.year;
  int rowIndex = -1;
  for (int i = 0; i < dateRanges.length; i++) {
    DateTime start = DateTime(birthDate.year, dateRanges[i]["start"].month, dateRanges[i]["start"].day);
    DateTime end = DateTime(birthDate.year, dateRanges[i]["end"].month, dateRanges[i]["end"].day);

    if ((birthDate.isAfter(start) || birthDate.isAtSameMomentAs(start)) && (birthDate.isBefore(end) || birthDate.isAtSameMomentAs(end))) {
      rowIndex = i;
      break;
    }
  }

  int colIndex = _calculateYearValue(birthYear);

  return (dataTable()[rowIndex][colIndex - 1], dateRanges[rowIndex]["end"]);
}

int _calculateYearValue(int year) {
  int baseYear = 1901;
  int baseValue = 9;

  int offset = (year - baseYear) % 9;

  int yearValue = baseValue - offset;

  if (yearValue <= 0) yearValue += 9;

  return yearValue;
}

int getPartKi(int value, bool kiA) => kiA ? _getKiA(value) : _getKiB(value);

int _getKiA(int value) {
  if (value >= 10) return int.parse(value.toString()[0]);
  return 0;
}

int _getKiB(int value) {
  if (value >= 10) return int.parse(value.toString().substring(value.toString().length - 1));
  return value;
}

int getEnergy(int year, int g, int h) {
  if (year != 2000) return 11 - (g + h);
  return 10 - (g + h);
}

(int, int) getKGen(int kiA, int kiB, Gender g, int en) {
  int kiSum = kiA + kiB;
  int first = 0;
  int last = 0;
  if (kiSum >= 10) first = getNumberPart(kiSum, first: true);
  if (kiSum >= 10) last = getNumberPart(kiSum, first: false);

  int kGen2 = _getKGen2(g, first, last, en);

  return (kiSum, kGen2);
}

int getNumberPart(int n, {bool first = true}) {
  if (first) return int.parse(n.toString()[0]);
  return n % 10;
}

int _getKGen2(Gender g, int o, int p, int k) {
  if (g == Gender.M) return (o + p) + 4;
  return k;
}

int getKua(Gender gender, int value) {
  int defaultValue = -1;
  if (gender == Gender.F) return kuaMale[value] ?? defaultValue;
  if (gender == Gender.M) return kuaFemale[value] ?? defaultValue;
  return defaultValue;
}

dynamic vLookup(int key, Map table) => table[key];

int getDateCoord1(DateTime date) => dateIndexTable[date] ??= 0;

int getDateCoord2(DateTime date) {
  final entries = dateIndexTable.entries.toList();
  final refDate1 = entries[entries.length - 2].key;
  final value1 = entries[entries.length - 2].value;
  final refDate2 = entries[entries.length - 1].key;
  final value2 = entries[entries.length - 1].value;

  if (date.isBefore(refDate1)) return value1;
  if (date.isBefore(refDate2)) return value2;
  return -1;
}

int selectCoordinate(DateTime birthDate, DateTime referenceDate, int coord1, int coord2) {
  return birthDate.isBefore(referenceDate) || birthDate.isAtSameMomentAs(referenceDate) ? coord1 : coord2;
}

String indexLookup(int row, int column) {
  int rowIndex = row - 1;
  int colIndex = column - 1;
  List<List<String>> table = dataTable();

  if (rowIndex < 0 || rowIndex >= table.length || colIndex < 0 || colIndex >= table[rowIndex].length) return lang.error_invalidIndex;
  return table[rowIndex][colIndex];
}

String getStarDistribution(Direction direction) => directionLookupLong[direction] ?? lang.error_notFound;
