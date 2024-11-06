import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pepis/src/models.dart';
import 'package:pepis/src/services/functions.dart';
import 'package:pepis/vars.dart';

import 'src/db.dart';
import 'src/enums.dart';
import 'src/services/input_formatters.dart';
import 'src/widgets/persona.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(useMaterial3: true),
      themeMode: ThemeMode.dark,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController nameController = TextEditingController();
  Gender gender = Gender.inv;
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController kiController = TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late Future<List<FengShuiModel>> _updatePeople;

  _setGender(Gender? value, void Function(void Function()) state) {
    if (value != null) state(() => gender = value);
  }

  Future<void> _addPerson() async {
    final String name = nameController.text;
    final DateTime? birthDate = stringToDate(birthDateController.text);
    final String ki = kiController.text;

    if (name.isNotEmpty && gender != Gender.inv && birthDate != null && ki.isNotEmpty) {
      final person = FengShuiModel(
        name: name,
        gender: gender,
        birthDate: birthDate,
        ki: ki,
      );

      await DatabaseHelper().insertPerson(person);

      setState(() {});
      refreshTable();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(child: Text("Por favor, llena todos los campos", style: TextStyle(color: Theme.of(context).colorScheme.primary))),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35.0)),
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
      );
    }
  }

  bool _submitForm() => formKey.currentState!.validate() && extraValidate();

  bool extraValidate() {
    return (gender != Gender.inv) && isValidDate(birthDateController.text);
  }

  void _addPersonDialog() {
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (BuildContext context, void Function(void Function()) state) => AlertDialog(
          title: const Text("Agregar Persona"),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: "Nombre"),
                    controller: nameController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null) return null;
                      if (value.trim().isEmpty) return "Llena el campo del nombre!";
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  const Text("Género", style: TextStyle(fontSize: 17)),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: RadioListTile<Gender>(
                          title: const Text("F", style: TextStyle(color: femalePink)),
                          activeColor: femalePink,
                          tileColor: femalePink.withOpacity(gender == Gender.F ? .3 : .1),
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                          value: Gender.F,
                          onChanged: (Gender? g) => _setGender(g, state),
                          groupValue: gender,
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<Gender>(
                          title: const Text("M", style: TextStyle(color: maleBlue)),
                          activeColor: maleBlue,
                          tileColor: maleBlue.withOpacity(gender == Gender.M ? .3 : .1),
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                          value: Gender.M,
                          onChanged: (Gender? g) => _setGender(g, state),
                          groupValue: gender,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    inputFormatters: [DateFormatInputFormatter()],
                    decoration: InputDecoration(
                        labelText: "Fecha de Nacimiento",
                        suffix: InkWell(
                          child: const Icon(Icons.calendar_month),
                          onTap: () async {
                            DateTime? date = await selectDate(context, lastDate: now);
                            if (date != null) {
                              birthDateController.text = dateToString(date);
                              state(() {});
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
                  TextFormField(
                    inputFormatters: [KIInputFormatter()],
                    decoration: const InputDecoration(labelText: "KI"),
                    controller: kiController,
                    keyboardType: TextInputType.number,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null) return null;
                      if (value.trim().isEmpty) return lang.warningDialogEmpty_ki;
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
        ),
      ),
    ).then((_) {
      gender = Gender.inv;
      nameController.clear();
      birthDateController.clear();
    });
  }

  Future<List<FengShuiModel>> _fetchPeople() async {
    return await DatabaseHelper().getPeople();
  }

  void refreshTable() {
    _updatePeople = _fetchPeople();
  }

  @override
  void initState() {
    super.initState();
    refreshTable();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      lang = AppLocalizations.of(context)!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(lang.fengShui),
      ),
      body: Center(
        child: FutureBuilder(
          future: _updatePeople,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const SizedBox(width: 50, height: 50, child: CircularProgressIndicator());

            if (snapshot.hasError) return Text(lang.errorLoadingPeople);

            final List<FengShuiModel> people = snapshot.data as List<FengShuiModel>;
            return ListView.builder(
              itemCount: people.length,
              itemBuilder: (context, index) => PersonaTile(person: people[index]),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPersonDialog,
        tooltip: lang.addPerson,
        child: const Icon(Icons.add),
      ),
    );
  }
}
