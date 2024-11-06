import 'dart:math';

import 'package:pepis/vars.dart';

import 'enums.dart';
import 'services/functions.dart';

class FengShuiModel {
  int? id;
  String name;
  Gender gender;
  DateTime birthDate;
  String ki;

  late int total;
  late int kiA;
  late int kiB;

  late int energy;
  late int kua;

  late Direction direction;
  late Materials material;

  late DateTime colFecha;
  late int coord1;
  late int coord2;
  late int coord;
  late int filaFecha;

  late String coordTki;
  late String starDistribution;

  FengShuiModel({
    this.id,
    required this.name,
    required this.gender,
    required this.birthDate,
    required this.ki,
  }) {
    colFecha = defaultDateMapping;
    total = sumOfYearDigits(birthDate.year);
    kiA = getKi(total, true);
    kiB = getKi(total, false);

    energy = getEnergy(birthDate.year, kiA, kiB);

    kua = getKua(gender, birthDate.year);

    direction = vLookup(kua, directionLookup);

    material = vLookup(energy, materialLookup);
    coord1 = getDateCoord1(colFecha);
    coord2 = getDateCoord2(birthDate);
    coord = selectCoordinate(birthDate, colFecha, coord1, coord2);

    filaFecha = energy;
    coordTki = indexLookup(coord, filaFecha);
    starDistribution = getStarDistribution(direction);
  }
  
  factory FengShuiModel.fromMap(Map<String, dynamic> map) {
    return FengShuiModel(
      id: map['id'],
      name: map['name'],
      gender: Gender.values[map['gender']],
      birthDate: DateTime.parse(map['birthDate']),
      ki: map['ki'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'gender': gender.index,
      'birthDate': birthDate.toIso8601String(),
      'ki': ki,
      'total': total,
      'kiA': kiA,
      'kiB': kiB,
      'energy': energy,
      'kua': kua,
      'direction': direction.index,
      'material': material.index,
      'colFecha': colFecha.toIso8601String(),
      'coord1': coord1,
      'coord2': coord2,
      'coord': coord,
      'filaFecha': filaFecha,
      'coordTki': coordTki,
      'starDistribution': starDistribution,
    };
  }
}
