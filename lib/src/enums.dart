import 'package:pepis/src/services/functions.dart';

import '../vars.dart';

enum DateFormats { DMY, MDY, YMD }

enum Gender { M, F, inv }

enum Direction { N, S, E, W, NE, NW, SE, SW }

enum Materials { Wood, Fire, Earth, Metal, Water }

enum Animal { Rat, Ox, Tiger, Rabbit, Dragon, Snake, Horse, Goat, Monkey, Rooster, Dog, Pig }

extension GenderX on Gender {
  String get name {
    switch (this) {
      case Gender.M:
        return lang.gender_Mshort;
      case Gender.F:
        return lang.gender_Fshort;
      case Gender.inv:
        return "/";
    }
  }
}

extension DateTimeX on DateTime {
  String get date => dateToString(this);

  bool isBefore(DateTime other) {
    if (month == other.month && day == other.day) return true;

    if (month == DateTime.december && other.month == DateTime.january) return true;
    return month < other.month || (month == other.month && day < other.day);
  }

  bool isAfter(DateTime other) {
    if (month == other.month && day == other.day) return true;

    if (month == DateTime.january && other.month == DateTime.december) return true;
    return month > other.month || (month == other.month && day > other.day);
  }

  bool isBetween(DateTime start, DateTime end) => isAfter(start) && isBefore(end);

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

extension DirectionX on Direction {
  String get name {
    switch (this) {
      case Direction.N:
        return "N";
      case Direction.NE:
        return "NE";
      case Direction.E:
        return "E";
      case Direction.SE:
        return "SE";
      case Direction.S:
        return "S";
      case Direction.SW:
        return "SW";
      case Direction.W:
        return "W";
      case Direction.NW:
        return "NW";
    }
  }
}

class StarDistribution {
  final int n;
  final int ne;
  final int e;
  final int se;
  final int s;
  final int sw;
  final int w;
  final int nw;
  String? err;

  StarDistribution(this.n, this.ne, this.e, this.se, this.s, this.sw, this.w, this.nw, {this.err});

  List<String> get list => [e, se, s, sw, w, nw, n, ne].map((e) => _prefix(e)).toList();

  String get string => "E(${_prefix(e)}) SE(${_prefix(se)}) S(${_prefix(s)}) SW(${_prefix(sw)}) W(${_prefix(w)}) NW(${_prefix(nw)}) N(${_prefix(n)}) NE(${_prefix(ne)})";

  String _prefix(int number) => number > 0 ? '+$number' : '$number';

  int getDirectionValue(Direction direction) {
    switch (direction) {
      case Direction.N:
        return n;
      case Direction.NE:
        return ne;
      case Direction.E:
        return e;
      case Direction.SE:
        return se;
      case Direction.S:
        return s;
      case Direction.SW:
        return sw;
      case Direction.W:
        return w;
      case Direction.NW:
        return nw;
    }
  }
}

extension AnimalX on Animal {
  String get name {
    switch (this){
      case Animal.Rat:
        return lang.animal_rat;
      case Animal.Ox:
        return lang.animal_ox;
      case Animal.Tiger:
        return lang.animal_tiger;
      case Animal.Rabbit:
        return lang.animal_rabbit;
      case Animal.Dragon:
        return lang.animal_dragon;
      case Animal.Snake:
        return lang.animal_snake;
      case Animal.Horse:
        return lang.animal_horse;
      case Animal.Goat:
        return lang.animal_goat;
      case Animal.Monkey:
        return lang.animal_monkey;
      case Animal.Rooster:
        return lang.animal_rooster;
      case Animal.Dog:
        return lang.animal_dog;
      case Animal.Pig:
        return lang.animal_pig;
    }
  }
}