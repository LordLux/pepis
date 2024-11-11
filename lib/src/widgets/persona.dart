import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pepis/src/enums.dart';

import '../models.dart';

class PersonaTile extends StatelessWidget {
  final FengShuiModel person;

  const PersonaTile({super.key, required this.person});

  @override
  Widget build(BuildContext context) => _PersonaTile(person: person);
}

class _PersonaTile extends StatefulWidget {
  final FengShuiModel person;

  const _PersonaTile({required this.person});

  @override
  State<_PersonaTile> createState() => _PersonaTileState();
}

class _PersonaTileState extends State<_PersonaTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.person.name),
      subtitle: Row(
        children: [
          Text(widget.person.gender.name),
          Text(DateFormat("dd/MMM", "es").format(widget.person.birthDate)),
          Text(DateFormat("yyyy").format(widget.person.birthDate)),
          Text(widget.person.total.toString()),
          Text(widget.person.kiA.toString()),
          Text(widget.person.kiB.toString()),
          Text(widget.person.kua.toString()),
          Text(widget.person.energy.toString()),
          Text(widget.person.ki),
          Text(widget.person.kua.toString()),
          Text(widget.person.starDistribution.string),
        ],
      ),
    );
  }
}
