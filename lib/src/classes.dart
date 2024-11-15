import 'package:pepis/src/services/core_functions.dart';

import 'enums.dart';
import 'services/functions.dart';

class FengShuiModel {
  int? id;
  String name;
  Gender gender;
  DateTime birthDate;
  late DateTime colFecha;
  late int total;
  late int kiA;
  late int kiB;

  late int energy;
  late String ki;
  late int kGen1;
  late int kGen2;
  late int kua;

  late Direction direction;
  late Materials material;

  late StarDistribution starDistribution;
  
  late Animal animal;

  FengShuiModel({
    this.id,
    required this.name,
    required this.gender,
    required this.birthDate,
  }) {
    try {
      // ki and colFecha
      final res = getKi(birthDate);
      ki = res.$1; // ki is the year's ki
      colFecha = res.$2; // colFecha is the date of the start of the year

      total = sumOfYearDigits(birthDate.year); // total is the sum of the digits of the year
      logInfo('total: $total');

      kiA = getPartKi(total, true); // kiA is the first part of the ki
      kiB = getPartKi(total, false); // kiB is the second part of the ki
      logInfo('kiA: $kiA, kiB: $kiB');

      energy = getEnergy(birthDate.year, kiA, kiB); // energy is the energy of the year
      logInfo('energy: $energy');

      final res2 = getKGen(kiA, kiB, gender, energy);
      kGen1 = res2.$1;
      kGen2 = res2.$2;

      final res3 = getKua(birthDate, gender);
      kua = res3.$1;
      animal = res3.$2;
      logInfo('kua: $kua, animal: $animal');

      direction = vDirectionLookup(kua);
      logInfo('direction: $direction');

      material = vMaterialLookup(energy);
      logInfo('material: $material');

      starDistribution = getStarDistribution(direction);
      logInfo('starDistribution: ${starDistribution.string}');
    } catch (e) {
      logErr('$e:\n[name: $name, gender: $gender, birthDate: ${dateToString(birthDate)}]');
    }
  }

  factory FengShuiModel.fromMap(Map<String, dynamic> map) {
    return FengShuiModel(
      id: map['id'],
      name: map['name'],
      gender: Gender.values[map['gender']],
      birthDate: stringToDate(map['birthDate'])!,
    );
  }

  factory FengShuiModel.fromSelection(SelectionModel selection) {
    return FengShuiModel(
      id: selection.id,
      name: selection.name,
      gender: selection.gender,
      birthDate: selection.birthDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'gender': gender.index,
      'birthDate': dateToString(birthDate),
      'total': total,
      'kua': kua,
      'energy': energy,
      'ki': ki,
      'direction': direction.index,
      'material': material.index,
      'starDistribution': starDistribution.string,
    };
  }
}

class SelectionModel {
  int? id;
  String name;
  Gender gender;
  DateTime birthDate;

  SelectionModel({
    this.id,
    required this.name,
    required this.gender,
    required this.birthDate,
  });

  factory SelectionModel.fromMap(Map<String, dynamic> map) {
    return SelectionModel(
      id: map['id'],
      name: map['name'],
      gender: Gender.values[map['gender']],
      birthDate: stringToDate(map['birthDate'])!,
    );
  }

  factory SelectionModel.fromPerson(FengShuiModel person) {
    return SelectionModel(
      id: person.id,
      name: person.name,
      gender: person.gender,
      birthDate: person.birthDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'gender': gender.index,
      'birthDate': dateToString(birthDate),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return (other is SelectionModel) && (id == other.id && name == other.name && gender == other.gender && birthDate == other.birthDate);
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ gender.hashCode ^ birthDate.hashCode;
}

//TODO fucking fix this shit
class ChineseZodiac {
  static const List<String> animalSigns = ["Rat", "Ox", "Tiger", "Rabbit", "Dragon", "Snake", "Horse", "Goat", "Monkey", "Rooster", "Dog", "Pig"];

  static const List<Materials> elements = [
    Materials.Metal,
    Materials.Water,
    Materials.Wood,
    Materials.Fire,
    Materials.Earth,
  ];

  /// Determines the Chinese Zodiac sign for a given birth date
  static String getZodiacSign(DateTime birthDate) {
    // List of Lunar New Year start dates for the relevant years (1900 - 2020)
    final List<DateTime> lunarNewYearDates = [
      DateTime(1900, 1, 31),
      DateTime(1901, 1, 18),
      DateTime(1902, 2, 19),
      DateTime(1903, 2, 7),
      DateTime(1904, 2, 8),
      DateTime(1905, 1, 28),
      DateTime(1906, 2, 13),
      DateTime(1907, 2, 2),
      DateTime(1908, 2, 22),
      DateTime(1909, 2, 10),
      DateTime(1910, 1, 30),
      
      DateTime(1911, 2, 19),
      DateTime(1912, 2, 6),
      DateTime(1913, 1, 26),
      DateTime(1914, 2, 14),
      DateTime(1915, 2, 3),
      DateTime(1916, 1, 23),
      DateTime(1917, 2, 11),
      DateTime(1918, 1, 31),
      DateTime(1919, 2, 19),
      DateTime(1920, 2, 8),
      
      DateTime(1921, 1, 28),
      DateTime(1922, 2, 16),
      DateTime(1923, 2, 5),
      DateTime(1924, 1, 24),
      DateTime(1925, 2, 13),
      DateTime(1926, 2, 2),
      DateTime(1927, 1, 23),
      DateTime(1928, 2, 10),
      DateTime(1929, 1, 29),
      DateTime(1930, 2, 17),
      
      DateTime(1931, 2, 6),
      DateTime(1932, 1, 26),
      DateTime(1933, 2, 14),
      DateTime(1934, 2, 4),
      DateTime(1935, 1, 24),
      DateTime(1936, 2, 11),
      DateTime(1937, 1, 31),
      DateTime(1938, 2, 19),
      DateTime(1939, 2, 8),
      DateTime(1940, 1, 27),
      
      DateTime(1941, 2, 15),
      DateTime(1942, 2, 5),
      DateTime(1943, 1, 25),
      DateTime(1944, 2, 13),
      DateTime(1945, 2, 1),
      DateTime(1946, 2, 20),
      DateTime(1947, 2, 9),
      DateTime(1948, 1, 29),
      DateTime(1949, 2, 17),
      DateTime(1950, 2, 6),
      
      DateTime(1951, 1, 27),
      DateTime(1952, 2, 14),
      DateTime(1953, 2, 3),
      DateTime(1954, 1, 24),
      DateTime(1955, 2, 12),
      DateTime(1956, 2, 2),
      DateTime(1957, 1, 22),
      DateTime(1958, 2, 10),
      DateTime(1959, 1, 29),
      DateTime(1960, 2, 17),
      DateTime(1961, 2, 5),
      DateTime(1962, 1, 25),
      DateTime(1963, 2, 13),
      DateTime(1964, 2, 2),
      DateTime(1965, 1, 21),
      DateTime(1966, 2, 9),
      DateTime(1967, 1, 30),
      DateTime(1968, 2, 18),
      DateTime(1969, 2, 7),
      DateTime(1970, 1, 27),
      DateTime(1971, 2, 15),
      DateTime(1972, 2, 3),
      DateTime(1973, 1, 23),
      DateTime(1974, 2, 11),
      DateTime(1975, 1, 31),
      DateTime(1976, 2, 20),
      DateTime(1977, 2, 8),
      DateTime(1978, 1, 28),
      DateTime(1979, 2, 16),
      DateTime(1980, 2, 5),
      DateTime(1981, 1, 25),
      DateTime(1982, 2, 14),
      DateTime(1983, 2, 2),
      DateTime(1984, 1, 23),
      DateTime(1985, 2, 10),
      DateTime(1986, 1, 31),
      DateTime(1987, 2, 19),
      DateTime(1988, 2, 6),
      DateTime(1989, 1, 28),
      DateTime(1990, 2, 16),
      DateTime(1991, 2, 5),
      DateTime(1992, 1, 23),
      DateTime(1993, 2, 10),
      DateTime(1994, 1, 31),
      DateTime(1995, 2, 19),
      DateTime(1996, 2, 8),
      DateTime(1997, 1, 28),
      DateTime(1998, 2, 15),
      DateTime(1999, 2, 5),
      DateTime(2000, 1, 24),
      DateTime(2001, 2, 12),
      DateTime(2002, 2, 1),
      DateTime(2003, 1, 22),
      DateTime(2004, 2, 9),
      DateTime(2005, 1, 29),
      DateTime(2006, 2, 18),
      DateTime(2007, 2, 7),
      
      DateTime(2009, 1, 26),
      DateTime(2010, 2, 14),
      DateTime(2011, 2, 3),
      DateTime(2012, 1, 23),
      DateTime(2013, 2, 10),
      DateTime(2014, 1, 31),
      DateTime(2015, 2, 19),
      DateTime(2016, 2, 8),
      DateTime(2017, 1, 28),
      DateTime(2018, 2, 16),
      DateTime(2019, 2, 5),
      DateTime(2020, 1, 25),
      DateTime(2021, 2, 12),
      DateTime(2022, 2, 1),
      DateTime(2023, 1, 22),
      DateTime(2024, 2, 10),
      DateTime(2025, 1, 29),
      DateTime(2026, 2, 17),
      DateTime(2027, 2, 6),
      DateTime(2028, 1, 26),
      DateTime(2029, 2, 13),
      DateTime(2030, 2, 3)
    ];

    // Determine the adjusted year based on the Lunar New Year date
    int adjustedYear = birthDate.year;
    DateTime lunarNewYear = lunarNewYearDates[adjustedYear - 1900];
    if (birthDate.isBefore(lunarNewYear)) {
      adjustedYear -= 1;
    }

    // Calculate the animal sign
    String animal = animalSigns[(adjustedYear - 1900) % 12];

    // Calculate the element
    Materials element = elements[((adjustedYear - 1900) % 10) ~/ 2];

    return "${element.name} $animal";
  }
}
