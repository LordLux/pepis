import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pepis/src/datasource.dart';
import 'package:pepis/src/models.dart';
import 'package:pepis/vars.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'columns.dart';
import 'src/db.dart';
import 'src/services/core_functions.dart';
import 'src/services/functions.dart';
import 'src/widgets/dialogs.dart';
import 'src/widgets/persona.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //await deleteDatabaseFile();
  //printFormattedList(dataTable());
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('es'); // Default to English

  // Function to update the locale
  void _changeLocale(String languageCode) {
    setState(() {
      _locale = Locale(languageCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(useMaterial3: true),
      themeMode: ThemeMode.dark,
      supportedLocales: const [
        Locale('en'), // English
        Locale('es'), // Spanish
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: _locale,
      home: MyHomePage(onLocaleChange: _changeLocale),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final void Function(String) onLocaleChange;
  const MyHomePage({super.key, required this.onLocaleChange});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<PersonaDataSource> _peopleDataSource;

  void _addPersonDialog() => showDialog(
        context: context,
        builder: (_) => const AddPersonDialog(),
      ).then(
        (_) => refreshTable(),
      );

  void _handleTap(DataGridCellTapDetails details) => logInfo('Cell tapped');

  void _handleDoubleTap(DataGridCellDoubleTapDetails details) {
    logInfo('Cell double tapped');
    final int rowIndex = details.rowColumnIndex.rowIndex > 0 ? details.rowColumnIndex.rowIndex - 1 : details.rowColumnIndex.rowIndex;
    _peopleDataSource.then((dataSource) async {
      final row = dataSource.rows[rowIndex];
      final int id = row.getCells().firstWhere((cell) => cell.columnName == 'id').value;
      final person = await DatabaseHelper().getPersonById(id);
      showDialog(context: context, builder: (_) => ViewPersonDialog(person: person));
    });
  }

  void refreshTable() => _peopleDataSource = getDataSource();

  @override
  void initState() {
    super.initState();
    refreshTable();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    lang = AppLocalizations.of(context)!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(lang.fengShui),
        actions: [
          ElevatedButton(
            onPressed: () {
              // Switch between English and Spanish
              final currentLocale = Localizations.localeOf(context).languageCode;
              widget.onLocaleChange(currentLocale == 'en' ? 'es' : 'en');
            },
            child: Text(AppLocalizations.of(context)!.localeName),
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder(
          future: _peopleDataSource,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const SizedBox(width: 50, height: 50, child: CircularProgressIndicator());

            if (snapshot.hasError) return Text("${lang.error_loadingPeople}:\n${snapshot.error}", textAlign: TextAlign.center);

            return SfDataGrid(
              source: snapshot.data as PersonaDataSource,
              columnWidthMode: ColumnWidthMode.auto,
              columns: peopleColumns,
              selectionMode: SelectionMode.singleDeselect,
              allowPullToRefresh: true,
              onCellTap: _handleTap,
              onCellDoubleTap: _handleDoubleTap,
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            mini: true,
            onPressed: () async => await DatabaseHelper().clearDatabase(),
            tooltip: lang.addPerson,
            child: const Icon(Icons.delete_forever_rounded, color: Colors.red),
          ),
          FloatingActionButton(
            onPressed: _addPersonDialog,
            tooltip: lang.addPerson,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

/*
  TODO:
  - setstate after adding person
  - fix language not updating
*/

var _;
