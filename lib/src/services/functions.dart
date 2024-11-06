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

int getKi(int value, bool kiA) => kiA ? _getKiA(value) : _getKiB(value);

int _getKiA(int value) {
  if (value >= 10)
    // Convert to string, get the first character, and parse it back to an integer
    return int.parse(value.toString()[0]);
  return 0;
}

int _getKiB(int value) {
  if (value >= 10)
    // Convert to string, get the last character, and parse it back to an integer
    return int.parse(value.toString().substring(value.toString().length - 1));
  return value;
}

int getEnergy(int year, int g, int h) => year != 2000 ? 11 - (g + h) : 10 - (g + h);

int getKua(Gender gender, int value) {
  int defaultValue = 0;
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

  if (rowIndex < 0 || rowIndex >= dataTable.length || colIndex < 0 || colIndex >= dataTable[rowIndex].length) return lang.invalidIndex;

  return dataTable[rowIndex][colIndex];
}

String getStarDistribution(Direction direction) => directionLookupLong[direction] ?? lang.notFound;
