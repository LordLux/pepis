import 'package:pepis/src/services/functions.dart';

// ignore: constant_identifier_names
enum DateFormats { DMY, MDY, YMD }

enum Gender { M, F, inv }

// ignore: constant_identifier_names
enum Direction { N, S, E, W, NE, NW, SE, SW }

enum Materials { wood, fire, earth, metal, water }

extension GenderX on Gender {
  static Gender parse(String value) {
    switch (value.toLowerCase()) {
      case 'm':
        return Gender.M;
      case 'f':
        return Gender.F;
      default:
        return Gender.inv;
    }
  }

  String get string => name.toUpperCase();
}

extension DateTimeX on DateTime {
  String get date => dateToString(this);
}
