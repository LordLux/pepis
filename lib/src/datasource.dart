import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart' as svgp;
import 'package:pepis/src/db.dart';
import 'package:pepis/src/enums.dart';
import 'package:pepis/src/models.dart';
import 'package:pepis/vars.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../columns.dart';
import 'services/core_functions.dart';
import 'services/functions.dart';
import 'widgets/svg.dart';

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
              DataGridCell<int>(columnName: header_id, value: e.id ?? -1),
              DataGridCell<String>(columnName: header_name, value: e.name),
              DataGridCell<Gender>(columnName: header_gender, value: e.gender),
              DataGridCell<String>(columnName: header_birthDate, value: dateToStringFormattedES(e.birthDate, " ")),
              DataGridCell<int>(columnName: header_year, value: e.birthDate.year),
              DataGridCell<int>(columnName: header_total, value: e.total),
              DataGridCell<int>(columnName: header_kua, value: e.kua),
              DataGridCell<int>(columnName: header_energy, value: e.energy),
              DataGridCell<String>(columnName: header_ki, value: e.ki),
              DataGridCell<Direction>(columnName: header_direction, value: e.direction),
              DataGridCell<Materials>(columnName: header_material, value: e.material),
              DataGridCell<StarDistribution>(columnName: header_starDistribution, value: e.starDistribution),
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
    if (value is StarDistribution) return value.string;
    return value.toString();
  }

  TextStyle _getStyleToDisplay(DataGridCell cell) {
    final value = cell.value;
    final String columnName = cell.columnName;

    return const TextStyle();
  }

  Widget? _getCustomWidget(DataGridCell cell) {
    final value = cell.value;
    final String columnName = cell.columnName;

    if (columnName == header_gender) {
      Gender a = value as Gender;
      return Text(a.name, style: TextStyle(color: getGenderColor(value)));
    }

    if (columnName == header_material) {
      Widget a = getEnergyIcon(value as Materials);
      return Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        a,
        const SizedBox(width: 5),
        Text(value.name),
      ]);
    }
    if (columnName == header_starDistribution) {
      final String a = (cell.value as StarDistribution).string;
      final List<String> directions = a.split(" ");
      List<TextSpan> children = [];

      for (String direction in directions) {
        final List<String> parts = direction.split("(");
        final String dir = parts[0];
        final String value = parts[1].substring(0, parts[1].length - 1);
        children.add(TextSpan(
          children: <TextSpan>[
            TextSpan(text: dir, style: TextStyle(color: blendColors(getDirectionColor(dir), Colors.grey, .35))),
            const TextSpan(text: '(', style: TextStyle(color: Colors.grey)),
            TextSpan(text: value, style: const TextStyle(fontWeight: FontWeight.bold)),
            const TextSpan(text: ") ", style: TextStyle(color: Colors.grey)),
          ],
        ));
      }
      return RichText(text: TextSpan(children: children), softWrap: false);
    }
    if (columnName == header_direction) {
      Direction a = value as Direction;
      return Text(a.name, style: TextStyle(color: blendColors(getDirectionColor(a.name), Colors.grey, .35)));
    }
    return null;
  }

  List<DataGridRow> _personas = [];

  @override
  List<DataGridRow> get rows => _personas;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    final int rowIndex = _personas.indexOf(row);
    final Color backgroundColor = rowIndex % 2 == 1 ? theme.colorScheme.onInverseSurface.withOpacity(.4) : Colors.transparent;

    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((dataGridCell) {
      return Container(
        alignment: _getAlignment(dataGridCell),
        padding: const EdgeInsets.all(16.0),
        color: backgroundColor,
        child: _getCustomWidget(dataGridCell) ?? Text(_getTextToDisplay(dataGridCell), style: _getStyleToDisplay(dataGridCell)),
      );
    }).toList());
  }
}

Widget getEnergyIcon(Materials material, [double size = 20]) {
  Widget a;
  switch (material) {
    case Materials.Wood:
      a = Svg('assets/icons/materials/wood.svg', width: size);
      break;
    case Materials.Fire:
      a = Svg('assets/icons/materials/fire.svg', width: size);
      break;
    case Materials.Earth:
      a = Svg('assets/icons/materials/earth.svg', width: size);
      break;
    case Materials.Metal:
      a = Svg('assets/icons/materials/metal.svg', width: size);
      break;
    case Materials.Water:
      a = Svg('assets/icons/materials/water.svg', width: size);
      break;
  }
  return a;
}

Color getGenderColor(Gender gender) {
  switch (gender) {
    case Gender.M:
      return maleBlue;
    case Gender.F:
      return femalePink;
    default:
      return Colors.grey;
  }
}

Color getDirectionColor(String dir) {
  switch (dir) {
    case "N":
      return Colors.blue;
    case "NE":
      return Colors.indigo;
    case "E":
      return Colors.green;
    case "SE":
      return Colors.orange;
    case "S":
      return Colors.red;
    case "SW":
      return Colors.pink;
    case "W":
      return Colors.purple;
    case "NW":
      return Colors.yellow;
    default:
      return Colors.black;
  }
}
