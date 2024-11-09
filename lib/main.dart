import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pepis/src/datasource.dart';
import 'package:pepis/vars.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:rxdart/rxdart.dart';

import 'columns.dart';
import 'config/config.dart';
import 'src/db.dart';
import 'src/services/core_functions.dart';
import 'src/widgets/dialogs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //await deleteDatabaseFile();
  //printFormattedList(dataTable());
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  final BehaviorSubject<Locale?> _notifierLocale = BehaviorSubject<Locale?>();
  Future? _futureFun;
  Locale _currentLocale = const Locale(AppConfig.defaultLanguage, '');

  @override
  void initState() {
    super.initState();

    _futureFun = _initData();

    _notifierLocale.stream.listen((Locale? locale) async {
      if (locale != null && (locale.languageCode != _currentLocale.languageCode)) {
        final prefs = await SharedPreferences.getInstance();
        String newLocale = locale.languageCode;
        await prefs.setString('appLocale', newLocale);
        setState(() {
          _currentLocale = locale;
        });
      }
    });
  }

  @override
  void dispose() {
    _notifierLocale.close();
    super.dispose();
  }

  Future<bool>? _initData() async {
    final prefs = await SharedPreferences.getInstance();
    String? lastAppLocaleCode = prefs.getString('appLocale');
    if (lastAppLocaleCode != null) {
      _currentLocale = Locale(lastAppLocaleCode, '');
    }
    return true;
  }

  List<Locale> getSupportedLocales() {
    List<Locale> locales = [];
    for (var element in AppConfig.supportedLanguage) {
      locales.add(Locale(element, ''));
    }
    return locales;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _futureFun,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Feng Shui',
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
            locale: _currentLocale,
            routes: <String, WidgetBuilder>{
              MyHomePage.routeName: (BuildContext context) => MyHomePage(notifierLocale: _notifierLocale),
            },
            initialRoute: MyHomePage.routeName,
          );
        }
        if (snapshot.hasError) return Container(); // here return your ErrorScreen widget

        return const CircularProgressIndicator();
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  static const String routeName = '/home';
  final BehaviorSubject<Locale?> notifierLocale;

  const MyHomePage({super.key, required this.notifierLocale});

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
      
      showDialog(
        context: context,
        builder: (_) => ViewPersonDialog(person: person),
      );
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
              widget.notifierLocale.add(const Locale("es", ""));
            },
            child: const Text("ES"),
          ),
          ElevatedButton(
            onPressed: () {
              widget.notifierLocale.add(const Locale("en", ""));
            },
            child: const Text("EN"),
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

// ignore: unused_element, prefer_typing_uninitialized_variables
var _;
