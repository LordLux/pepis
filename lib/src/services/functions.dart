import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:recase/recase.dart';

import '../../config/config.dart';
import '../../vars.dart';
import '../enums.dart';
import 'core_functions.dart';

DateTime? stringToDate(String date, [bool strict = false]) => strict ? _stringToDateStrict(date) : _stringToDateUnStrict(date);

DateTime? _stringToDateStrict(String date) {
  switch (Settings.dateFormat) {
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
  switch (Settings.dateFormat) {
    case DateFormats.DMY:
      return DateFormat('dd/MM/yyyy').format(date);
    case DateFormats.MDY:
      return DateFormat('MM/dd/yyyy').format(date);
    case DateFormats.YMD:
      return DateFormat('yyyy/MM/dd').format(date);
  }
}

String dateToStringFormattedES(DateTime date, [String divider = "/", bool long = false]) {
  final a = DateFormat("dd", "es").format(date);

  String format = "MMM";
  if (Settings.longMonth) format += "M";
  if (long) format += " yyyy";
  final b = DateFormat(format, "es").format(date).titleCase;

  return "$a$divider$b";
}

bool isValidDate(String date, [bool strict = false]) => strict ? _isValidDateStrict(date) : _isValidDateUnstrict(date);

bool _isValidDateUnstrict(String date) {
  if (DateFormat('dd/MM/yyyy').tryParse(date) != null) return true;
  if (DateFormat('MM/dd/yyyy').tryParse(date) != null) return true;
  if (DateFormat('yyyy/MM/dd').tryParse(date) != null) return true;
  return false;
}

bool _isValidDateStrict(String date) {
  switch (Settings.dateFormat) {
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
  lastDate ??= DateTime(now.year, 0, 0);
  return (await showDatePicker(context: context, firstDate: firstDate, lastDate: lastDate));
}

int sumOfYearDigits(int year) {
  final yearString = year.toString();
  int sum = 0;

  for (int i = 0; i < yearString.length; i++) sum += int.parse(yearString[i]);
  return sum;
}

void printFormattedList(List<List<String>> list) {
  int rows = list[0].length;
  int cols = list.length;

  for (int i = 0; i < rows; i++) {
    String row = '';
    for (int j = 0; j < cols; j++) {
      row += list[j][i] + (j < cols - 1 ? '  ' : '');
    }
    log(row);
  }
}

void printFormattedListWithHighlight(List<List<String>> list, int highlightX, int highlightY) {
  int rows = list[0].length;
  int cols = list.length;

  List<List<dynamic>> messages = [];

  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      String cellValue = list[j][i];

      // Highlight the specific cell in red
      if (i == highlightY && j == highlightX) {
        messages.add([cellValue, Colors.amber]);
      }
      // Highlight cells in the same row or column in green
      else if ((i == highlightY && j < highlightX) || (j == highlightX && i < highlightY)) {
        messages.add([cellValue, Colors.lightBlue]);
      }
      // Default color for other cells
      else {
        messages.add([cellValue, Colors.white]);
      }

      if (j < cols - 1) {
        messages.add(['  ']); // Add spacing between elements
      }
    }
    messages.add(['\n']); // Add newline after
  }

  logMulti(messages);
}

(String, DateTime) getKi(DateTime birthDate) {
  List<List<String>> table = dataTable();
  int rowIndex = _calculateDateValue(birthDate);
  int colIndex = _calculateYearValue(birthDate.year);
  //printFormattedListWithHighlight(table, colIndex, rowIndex);

  return (table[colIndex][rowIndex], dateRanges[rowIndex]["end"]);
}

/// Calculate the date value based on the birth date [1 - 12]
int _calculateDateValue(DateTime birthDate) {
  // Adjust the birthDate to a common year for comparison (e.g., 2000)
  DateTime adjustedBirthDate = DateTime(2000, birthDate.month, birthDate.day);

  for (int i = 0; i < dateRanges.length; i++) {
    DateTime start = DateTime(2000, dateRanges[i]["start"].month, dateRanges[i]["start"].day);
    DateTime end = DateTime(2000, dateRanges[i]["end"].month, dateRanges[i]["end"].day);

    // Adjust the end date if the range crosses over the year boundary
    if (dateRanges[i]["start"].month > dateRanges[i]["end"].month) //
      end = DateTime(2001, dateRanges[i]["end"].month, dateRanges[i]["end"].day);

    if ((adjustedBirthDate.isBetween(start, end)) && //
        (adjustedBirthDate.isBetween(start, end))) {
      return i;
    }
  }

  logErr("Error: Date not found: ${dateToString(birthDate)}");
  return -1;
}

/// Calculate the year value based on the birth year [1 - 9]
int _calculateYearValue(int year) {
  int baseYear = 1901;
  int baseValue = 9;

  int offset = (year - baseYear) % 9;

  int yearValue = baseValue - offset;

  if (yearValue <= 0) yearValue += 9;

  return yearValue - 1;
}

/// Gets KI A or KI B based on the value
int getPartKi(int value, bool kiA) => kiA ? _getKiA(value) : _getKiB(value);

/// Gets the first digit of the value
int _getKiA(int value) {
  if (value >= 10) return int.parse(value.toString()[0]);
  return 0;
}

/// Gets the last digit of the value
int _getKiB(int value) {
  if (value >= 10) return int.parse(value.toString().substring(value.toString().length - 1));
  return value;
}

/// Gets the energy value based on the year and KI A and KI B values [0-9]
int getEnergy(int year, int kiaA, int kiaB) {
  if (year != 2000) return reduce(11 - (kiaA + kiaB));
  return reduce(10 - (kiaA + kiaB));
}

int reduce(int number) {
  while (number > 9) //
    number = number.toString().split('').map(int.parse).reduce((a, b) => a + b); // Sums all the digits until it's a single digit

  return number;
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

(int, Animal) getKua(DateTime birthDate, Gender gender) {
  final int year = birthDate.year;
  final int lunarYear;

  // Se la data di nascita è prima del Capodanno Cinese, considera l'anno precedente
  if (chineseNewYearDates.containsKey(year) && birthDate.isBefore(chineseNewYearDates[year]!)) //
    lunarYear = year - 1;
  else
    lunarYear = year;

  // Calcolo della somma delle cifre dell'anno di nascita
  int kuaNumber;
  if (gender == Gender.M) {
    if (lunarYear >= 2000)
      kuaNumber = reduce(lunarYear) - 11;
    else
      kuaNumber = reduce(lunarYear) - 10;
  } else {
    if (lunarYear >= 2000)
      kuaNumber = reduce(lunarYear) + 4;
    else
      kuaNumber = reduce(lunarYear) + 5;
  }

  // Togli il segno meno
  kuaNumber = kuaNumber.abs();

  // Riduci il numero Kua a una singola cifra (esclusi i numeri 5)
  kuaNumber = reduce(kuaNumber);

  // Trattamento speciale per il numero Kua 5
  if (kuaNumber == 5) //
    kuaNumber = (gender == Gender.M) ? 2 : 8;

  final Animal animal = Animal.values[(lunarYear - 1900) % 12];

  return (kuaNumber, animal);
}

Direction vDirectionLookup(int key) => directionLookup[key]!;

Materials vMaterialLookup(int key) => materialLookup[key]!;

dynamic vLookup(int key, Map table) => table[key]!;

StarDistribution getStarDistribution(Direction direction) => directionLookupLong[direction] ?? StarDistribution(-1, -2, -3, -4, -5, -6, -7, -8, err: lang.error_notFound);
