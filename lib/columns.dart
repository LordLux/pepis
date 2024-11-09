import 'package:flutter/widgets.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'vars.dart';

List<GridColumn> get peopleColumns => [
  GridColumn(
    columnName: 'id',
    label: Container(
      padding: const EdgeInsets.all(8),
      alignment: Alignment.center,
      child: Text(lang.id),
    ),
    
  ),
  GridColumn(
    columnName: 'name',
    label: Container(
      padding: const EdgeInsets.all(8),
      alignment: Alignment.center,
      child: Text(lang.name),
    ),
  ),
  GridColumn(
    columnName: 'gender',
    label: Container(
      padding: const EdgeInsets.all(8),
      alignment: Alignment.center,
      child: Text(lang.gender),
    ),
  ),
  GridColumn(
    columnName: 'birthDate',
    label: Container(
      padding: const EdgeInsets.all(8),
      alignment: Alignment.center,
      child: Text(lang.date_birth),
    ),
  ),GridColumn(
    columnName: 'year',
    label: Container(
      padding: const EdgeInsets.all(8),
      alignment: Alignment.center,
      child: Text(lang.date_year),
    ),
  ),
  GridColumn(
    columnName: 'total',
    label: Container(
      padding: const EdgeInsets.all(8),
      alignment: Alignment.center,
      child: Text(lang.total),
    ),
  ),
  GridColumn(
    columnName: 'kua',
    label: Container(
      padding: const EdgeInsets.all(8),
      alignment: Alignment.center,
      child: Text(lang.kua),
    ),
  ),
  GridColumn(
    columnName: 'energy',
    label: Container(
      padding: const EdgeInsets.all(8),
      alignment: Alignment.center,
      child: Text(lang.energy),
    ),
  ),
  GridColumn(
    columnName: 'ki',
    label: Container(
      padding: const EdgeInsets.all(8),
      alignment: Alignment.center,
      child: Text(lang.ki),
    ),
  ),
  GridColumn(
    columnName: 'direction',
    label: Container(
      padding: const EdgeInsets.all(8),
      alignment: Alignment.center,
      child: Text(lang.direction),
    ),
  ),
  GridColumn(
    columnName: 'material',
    label: Container(
      padding: const EdgeInsets.all(8),
      alignment: Alignment.center,
      child: Text(lang.element),
    ),
  ),
  GridColumn(
    columnName: 'starDistribution',
    label: Container(
      padding: const EdgeInsets.all(8),
      alignment: Alignment.center,
      child: Text(lang.starDistribution),
    ),
  ),
];
