import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pepis/config/config.dart';
import 'package:pepis/src/widgets/compass.dart';

import '../../vars.dart';
import '../datasource.dart';
import '../db.dart';
import '../enums.dart';
import '../classes.dart';
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

//

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
          content: Center(child: Text(lang.warningDialogFillAllFields, style: TextStyle(color: theme.colorScheme.primary))),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35.0)),
          backgroundColor: theme.colorScheme.onPrimary,
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
            Expanded(
                flex: 2,
                child: Row(
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
  final SelectionModel person;

  const ViewPersonDialog({super.key, required this.person});

  @override
  Widget build(BuildContext context) => ViewPersonDialogStateful(key: addPersonaDialogKey, person: person);
}

class ViewPersonDialogStateful extends StatefulWidget {
  final SelectionModel person;

  const ViewPersonDialogStateful({super.key, required this.person});

  @override
  // ignore: library_private_types_in_public_api
  ViewPersonDialogStatefulState createState() => ViewPersonDialogStatefulState();
}

class ViewPersonDialogStatefulState extends State<ViewPersonDialogStateful> {
  late FengShuiModel person;
  late bool star;

  @override
  void initState() {
    super.initState();
    person = FengShuiModel.fromSelection(widget.person);
    star = Settings.initialStar;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 420,
      child: AlertDialog(
        title: SizedBox(
          width: 500,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 5,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(person.gender == Gender.M ? Icons.person : Icons.person_2, size: 30),
                    const SizedBox(width: 10),
                    Text(person.name),
                  ],
                ),
              ),
              Expanded(
                flex: 4,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(lang.star, style: const TextStyle(fontSize: 17)),
                    const SizedBox(width: 10),
                    Switch(
                      value: star,
                      onChanged: (bool value) {
                        setState(() {
                          star = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        content: SizedBox(
          height: 466,
          width: 600,
          child: Row(
            children: [
              Expanded(
                flex: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: lang.gender,
                        floatingLabelAlignment: FloatingLabelAlignment.center,
                        border: const OutlineInputBorder(),
                      ),
                      initialValue: person.gender.name,
                      style: TextStyle(color: getGenderColor(person.gender)),
                      textAlign: TextAlign.center,
                      readOnly: true,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: lang.date_birth,
                        floatingLabelAlignment: FloatingLabelAlignment.center,
                        border: const OutlineInputBorder(),
                      ),
                      initialValue: dateToStringFormattedES(person.birthDate, " ", true),
                      textAlign: TextAlign.center,
                      readOnly: true,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: lang.total,
                        floatingLabelAlignment: FloatingLabelAlignment.center,
                        border: const OutlineInputBorder(),
                      ),
                      initialValue: person.total.toString(),
                      textAlign: TextAlign.center,
                      readOnly: true,
                    ),
                    const SizedBox(height: 10),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: lang.energy,
                            floatingLabelAlignment: FloatingLabelAlignment.center,
                            border: const OutlineInputBorder(),
                          ),
                          initialValue: "${person.energy}  -             ‎",
                          textAlign: TextAlign.center,
                          readOnly: true,
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(width: 94),
                              getEnergyIcon(person.material, 17),
                              const SizedBox(width: 5),
                              Text(person.material.name),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: lang.ki,
                        floatingLabelAlignment: FloatingLabelAlignment.center,
                        border: const OutlineInputBorder(),
                      ),
                      initialValue: person.ki,
                      textAlign: TextAlign.center,
                      readOnly: true,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: lang.kua,
                        floatingLabelAlignment: FloatingLabelAlignment.center,
                        border: const OutlineInputBorder(),
                      ),
                      initialValue: person.kua.toString(),
                      textAlign: TextAlign.center,
                      readOnly: true,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: lang.direction,
                        floatingLabelAlignment: FloatingLabelAlignment.center,
                        border: const OutlineInputBorder(),
                      ),
                      initialValue: person.direction.name,
                      textAlign: TextAlign.center,
                      readOnly: true,
                    ),
                  ],
                ),
              ),
              if (star)
                Expanded(
                  flex: 18,
                  child: Transform.translate(
                    offset: const Offset(10, 0),
                    child: Builder(builder: (context) {
                      final List<String> directions = person.starDistribution.list;
                      final int targetIndex = directions.indexOf("+1");
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          Transform.rotate(
                            angle: pi / (targetIndex % 2 == 0 ? .5 : 4),
                            child: Image.asset('assets/icons/compass.png', width: 250)),
                          CompassStar(directions),
                        ],
                      );
                    }),
                  ),
                ),
              if (!star)
                Expanded(
                  flex: 18,
                  child: CompassTable(person.starDistribution.list),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

//

class CurveSelectionDialog extends StatelessWidget {

  CurveSelectionDialog({super.key});

  // List of all Flutter animation curves
  final Map<String, Curve> _curves = {
    'Linear': Curves.linear,
    'Ease': Curves.ease,
    'Ease In': Curves.easeIn,
    'Ease In Back': Curves.easeInBack,
    'Ease Out': Curves.easeOut,
    'Ease In Out': Curves.easeInOut,
    'Ease In Out Back': Curves.easeInOutBack,
    'Ease In Out Circ': Curves.easeInCirc,
    'Ease In Out Cubic': Curves.easeInOutCubic,
    'Ease In Out Cubic Emphasized': Curves.easeInOutCubicEmphasized,
    'Ease In Out Expo': Curves.easeInOutExpo,
    'Fast Ease In To Slow Ease Out': Curves.fastEaseInToSlowEaseOut,
    'Ease In Circ': Curves.easeInCirc,
    'Ease In Cubic': Curves.easeInCubic,
    'Ease Out Circ': Curves.easeOutCirc,
    'Ease Out Cubic': Curves.easeOutCubic,
    'Bounce In': Curves.bounceIn,
    'Bounce Out': Curves.bounceOut,
    'Bounce In Out': Curves.bounceInOut,
    'Elastic In': Curves.elasticIn,
    'Elastic Out': Curves.elasticOut,
    'Elastic In Out': Curves.elasticInOut,
    'Fast Out Slow In': Curves.fastOutSlowIn,
    'Slow Middle': Curves.slowMiddle,
    'Decelerate': Curves.decelerate,
  };

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Choose Animation Curve'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          itemCount: _curves.length,
          itemBuilder: (context, index) {
            final curveName = _curves.keys.elementAt(index);
            final curve = _curves[curveName];
            return ListTile(
              title: Text(curveName),
              onTap: () {
                Settings.chosenCurve = curve!;
                Navigator.of(context).pop();
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
