import 'package:flutter/widgets.dart';
import 'package:pepis/src/db.dart';
import 'package:pepis/src/enums.dart';
import 'package:pepis/src/models.dart';
import 'package:pepis/vars.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:uuid/uuid.dart';

import 'services/functions.dart';

PersonaDataSource? personaDataSource;

Future<PersonaDataSource> getDataSource() async {
  await DatabaseHelper().getPeople();
  return PersonaDataSource();
}

class PersonaDataSource extends DataGridSource {
  PersonaDataSource() {
    List<FengShuiModel> people = DatabaseHelper.people;
    _personas = people
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<int>(columnName: 'id', value: e.id ?? -1),
              DataGridCell<String>(columnName: 'name', value: e.name),
              DataGridCell<String>(columnName: 'gender', value: e.gender.name),
              DataGridCell<String>(columnName: 'birthDate', value: dateToStringFormattedES(e.birthDate, " ")),
              DataGridCell<int>(columnName: 'year', value: e.birthDate.year),
              DataGridCell<int>(columnName: 'total', value: e.total),
              DataGridCell<int>(columnName: 'kua', value: e.kua),
              DataGridCell<int>(columnName: 'energy', value: e.energy),
              DataGridCell<String>(columnName: 'ki', value: e.ki),
              DataGridCell<Direction>(columnName: 'direction', value: e.direction),
              DataGridCell<Materials>(columnName: 'material', value: e.material),
              DataGridCell<String>(columnName: 'starDistribution', value: e.starDistribution),
            ]))
        .toList();
  }

  Alignment _getAlignment(DataGridCell cell) {
    return Alignment.center;
    final value = cell.value;
    return (value is int) ? Alignment.centerRight : Alignment.center;
  }

  String _getTextToDisplay(DataGridCell cell) {
    final value = cell.value;
    if (value is Enum) return value.name;
    return value.toString();
  }

  List<DataGridRow> _personas = [];

  @override
  List<DataGridRow> get rows => _personas;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((dataGridCell) {
      return Container(
        alignment: _getAlignment(dataGridCell),
        padding: const EdgeInsets.all(16.0),
        child: Text(_getTextToDisplay(dataGridCell)),
      );
    }).toList());
  }
}
