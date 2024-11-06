import 'package:pepis/src/services/functions.dart';

import '../vars.dart';

enum DateFormats { DMY, MDY, YMD }

enum Gender { M, F, inv }

enum Direction { N, S, E, W, NE, NW, SE, SW }

enum Materials { Wood, Fire, Earth, Metal, Water }

extension GenderX on Gender {
  String get name {
    switch (this) {
      case Gender.M:
        return lang.gender_Fshort;
      case Gender.F:
        return lang.gender_Mshort;
      case Gender.inv:
        return "/";
    }
  }
}

extension DateTimeX on DateTime {
  String get date => dateToString(this);

  String get dateES => dateToStringFormattedES(this);
}

extension MaterialsX on Materials {
  String get name {
    switch (this) {
      case Materials.Earth:
        return lang.earth;
      case Materials.Fire:
        return lang.fire;
      case Materials.Metal:
        return lang.metal;
      case Materials.Water:
        return lang.water;
      case Materials.Wood:
        return lang.wood;
    }
  }
}
