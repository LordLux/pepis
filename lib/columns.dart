import 'package:flutter/widgets.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'vars.dart';

const String header_id = 'id';
const String header_name = 'name';
const String header_gender = 'gender';
const String header_birthDate = 'birthDate';
const String header_year = 'year';
const String header_total = 'total';
const String header_kua = 'kua';
const String header_energy = 'energy';
const String header_ki = 'ki';
const String header_direction = 'direction';
const String header_material = 'material';
const String header_starDistribution = 'starDistribution';

List<GridColumn> get peopleColumns => [
      GridColumn(
        columnName: header_id,
        label: Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.center,
          child: Text(lang.id),
        ),
      ),
      GridColumn(
        columnName: header_name,
        label: Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.center,
          child: Text(lang.name),
        ),
      ),
      GridColumn(
        columnName: header_gender,
        label: Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.center,
          child: Text(lang.gender),
        ),
      ),
      GridColumn(
        columnName: header_birthDate,
        label: Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.center,
          child: Text(lang.date_birth),
        ),
      ),
      GridColumn(
        columnName: header_year,
        label: Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.center,
          child: Text(lang.date_year),
        ),
      ),
      GridColumn(
        columnName: header_total,
        label: Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.center,
          child: Text(lang.total),
        ),
      ),
      GridColumn(
        columnName: header_kua,
        label: Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.center,
          child: Text(lang.kua),
        ),
      ),
      GridColumn(
        columnName: header_energy,
        label: Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.center,
          child: Text(lang.energy),
        ),
      ),
      GridColumn(
        columnName: header_ki,
        label: Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.center,
          child: Text(lang.ki),
        ),
      ),
      GridColumn(
        columnName: header_direction,
        label: Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.center,
          child: Text(lang.direction),
        ),
      ),
      GridColumn(
        columnName: header_material,
        label: Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.center,
          child: Text(lang.element),
        ),
      ),
      GridColumn(
        columnName: header_starDistribution,
        label: Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.center,
          child: Text(lang.starDistribution),
        ),
        minimumWidth: 390,
      ),
    ];
