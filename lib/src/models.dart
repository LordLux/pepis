import 'package:pepis/vars.dart';

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

  FengShuiModel({
    this.id,
    required this.name,
    required this.gender,
    required this.birthDate,
  }) {
    final res = getKi(birthDate);
    ki = res.$1;
    colFecha = res.$2;
    total = sumOfYearDigits(birthDate.year);
    kiA = getPartKi(total, true);
    kiB = getPartKi(total, false);

    energy = getEnergy(birthDate.year, kiA, kiB);
    final res2 = getKGen(kiA, kiB, gender, energy);
    kGen1 = res2.$1;
    kGen2 = res2.$2;
    kua = getKua(gender, birthDate.year);

    direction = vLookup(kua, directionLookup);

    material = vLookup(energy, materialLookup);
    starDistribution = getStarDistribution(direction);
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
      'starDistribution': starDistribution,
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
