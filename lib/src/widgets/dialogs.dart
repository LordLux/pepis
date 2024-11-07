import 'package:flutter/material.dart';

import '../../vars.dart';
import '../db.dart';
import '../enums.dart';
import '../models.dart';
import '../services/functions.dart';
import '../services/input_formatters.dart';
import '../services/random.dart';

GlobalKey<PersonDialogStatefulState> addPersonaDialogKey = GlobalKey<PersonDialogStatefulState>();

class AddPersonDialog extends StatelessWidget {
  const AddPersonDialog({super.key});

  @override
  Widget build(BuildContext context) => PersonDialogStateful(key: addPersonaDialogKey);
}

class PersonDialogStateful extends StatefulWidget {
  const PersonDialogStateful({super.key});

  @override
  // ignore: library_private_types_in_public_api
  PersonDialogStatefulState createState() => PersonDialogStatefulState();
}

GlobalKey<FormState> formKey = GlobalKey<FormState>();

class PersonDialogStatefulState extends State<PersonDialogStateful> {
  final TextEditingController nameController = TextEditingController();
  Gender gender = Gender.inv;
  final TextEditingController birthDateController = TextEditingController();

  bool _submitForm() => formKey.currentState!.validate() && extraValidate();

  bool extraValidate() {
    return (gender != Gender.inv) && isValidDate(birthDateController.text);
  }

  _setGender(Gender? value) {
    if (value != null) setState(() => gender = value);
  }

  Future<void> _addPerson() async {
    final String name = nameController.text;
    final DateTime? birthDate = stringToDate(birthDateController.text);

    if (name.isNotEmpty && gender != Gender.inv && birthDate != null) {
      final person = FengShuiModel(name: name, gender: gender, birthDate: birthDate);

      await DatabaseHelper().insertPerson(person);

      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(child: Text(lang.warningDialogFillAllFields, style: TextStyle(color: Theme.of(context).colorScheme.primary))),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35.0)),
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
      );
    }
  }

  void random() {
    fillRandom();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: SizedBox(
        width: 500,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(flex: 2, child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person_add),
                const SizedBox(width: 10),
                Text(lang.addPerson),
              ],
            )),
            SizedBox(
              child: ElevatedButton(
                onPressed: random,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.casino_outlined, color: Colors.amber),
                      const SizedBox(width: 10),
                      Text(lang.random),
                      const SizedBox(width: 10),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: lang.name),
                controller: nameController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null) return null;
                  if (value.trim().isEmpty) return lang.warningDialogEmpty_name;
                  return null;
                },
              ),
              const SizedBox(height: 10),
              Text(lang.gender, style: const TextStyle(fontSize: 17)),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: RadioListTile<Gender>(
                      title: Text(lang.gender_Fshort, style: const TextStyle(color: femalePink)),
                      activeColor: femalePink,
                      tileColor: femalePink.withOpacity(gender == Gender.F ? .3 : .1),
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                      value: Gender.F,
                      onChanged: (Gender? g) => _setGender(g),
                      groupValue: gender,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<Gender>(
                      title: Text(lang.gender_Mshort, style: const TextStyle(color: maleBlue)),
                      activeColor: maleBlue,
                      tileColor: maleBlue.withOpacity(gender == Gender.M ? .3 : .1),
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                      value: Gender.M,
                      onChanged: (Gender? g) => _setGender(g),
                      groupValue: gender,
                    ),
                  )
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                inputFormatters: [DateFormatInputFormatter()],
                decoration: InputDecoration(
                    labelText: lang.date_birth,
                    suffix: InkWell(
                      child: const Icon(Icons.calendar_month),
                      onTap: () async {
                        DateTime? date = await selectDate(context, lastDate: now);
                        if (date != null) {
                          birthDateController.text = dateToString(date);
                          setState(() {});
                        }
                      },
                    )),
                controller: birthDateController,
                keyboardType: TextInputType.datetime,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null) return null;
                  if (value.trim().isEmpty) return lang.warningDialogEmpty_date;
                  if (!isValidDate(birthDateController.text)) return lang.warningDialogFormat_date;
                  if (stringToDate(birthDateController.text)!.isAfter(now)) return lang.warningDialog_dateFuture;
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (_submitForm()) {
              _addPerson();
              Navigator.of(context).pop(true);
            }
          },
          child: Text(lang.save),
        ),
      ],
    );
  }
}

class ViewPersonDialog extends StatelessWidget {
  final FengShuiModel person;
  
  const ViewPersonDialog({super.key, required this.person});

  @override
  Widget build(BuildContext context) => ViewPersonDialogStateful(key: addPersonaDialogKey, person: person);
}

class ViewPersonDialogStateful extends StatefulWidget {
  final FengShuiModel person;
  
  const ViewPersonDialogStateful({super.key, required this.person});

  @override
  // ignore: library_private_types_in_public_api
  ViewPersonDialogStatefulState createState() => ViewPersonDialogStatefulState();
}

class ViewPersonDialogStatefulState extends State<ViewPersonDialogStateful> {
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: SizedBox(
        width: 500,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person),
            const SizedBox(width: 10),
            Text(lang.viewPerson),
          ],
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: lang.name),
              initialValue: widget.person.name,
              readOnly: true,
            ),
            const SizedBox(height: 10),
            TextFormField(
              decoration: InputDecoration(labelText: lang.gender),
              initialValue: widget.person.gender.name,
              readOnly: true,
            ),
            const SizedBox(height: 10),
            TextFormField(
              decoration: InputDecoration(labelText: lang.date_birth),
              initialValue: dateToString(widget.person.birthDate),
              readOnly: true,
            ),
          ],
        ),
      ),
    );
  }
}
