import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pepis/src/datasource.dart';
import 'package:pepis/src/models.dart';
import 'package:pepis/vars.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:rxdart/rxdart.dart';

import 'columns.dart';
import 'config/config.dart';
import 'src/db.dart';
import 'src/selected.dart';
import 'src/services/core_functions.dart';
import 'src/widgets/dialogs.dart';
import 'src/widgets/svg.dart';
import 'src/widgets/tabs.dart';

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
        //homepageDialogKey.currentState!.refreshTable();
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
              MyHomePage.routeName: (BuildContext context) => MyHomePage(notifierLocale: _notifierLocale, key: homepageDialogKey),
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

GlobalKey<_MyHomePageState> homepageDialogKey = GlobalKey<_MyHomePageState>();
class _MyHomePageState extends State<MyHomePage> {
  late Future<PersonaDataSource> _peopleDataSource;
  final DataGridController _dataGridController = DataGridController();

  void _addPersonDialog() => showDialog(
        context: context,
        builder: (_) => const AddPersonDialog(),
      ).then(
        (_) => refreshTable(),
      );
  
  //TODO fix changing selection
  void _handleTap(DataGridCellTapDetails details) async {
    //logInfo('Cell tapped: ${SelectionHandler.selected.value ? 'deselecting' : 'selecting'}');
    final int? prevId = SelectionHandler.selected.value ? SelectionHandler.get!.id : null;
    final int? newId = _dataGridController.selectedRow?.getCells()[0].value;
    print('prevId: $prevId, newId: $newId');

    if (prevId == newId) {
      // deselecting
      _deselect();
      print('deselected');
    } else {
      // selecting
      await _selectPerson(details);
      print(SelectionHandler.get!.name);
    }
  }

  void _handleLongTap(dynamic details) async {
    logInfo('Cell double tapped');

    await _selectPerson(details);

    showDialog(
      context: context,
      builder: (_) => ViewPersonDialog(person: SelectionHandler.get!),
    );
  }

  void _deselect() {
    SelectionHandler.deselect();
    setState(() {});
  }

  Future<SelectionModel> _selectPerson(dynamic details) async {
    final int rowIndex = details.rowColumnIndex.rowIndex > 0 ? details.rowColumnIndex.rowIndex - 1 : details.rowColumnIndex.rowIndex;
    return await _peopleDataSource.then((dataSource) async {
      final DataGridRow row = dataSource.rows[rowIndex];
      final int id = row.getCells().firstWhere((cell) => cell.columnName == 'id').value;
      final SelectionModel person = await DatabaseHelper().getSelectionById(id);

      SelectionHandler.select(person);
      _dataGridController.selectedRow = await _peopleDataSource.then((dataSource) => dataSource.rows.firstWhere((row) => row.getCells().first.value == person.id));
      setState(() {});
      return person;
    });
  }

  void refreshTable() {
    _peopleDataSource = getDataSource();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    refreshTable();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    lang = AppLocalizations.of(context)!;
    theme = Theme.of(context);
    palette = theme.colorScheme;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(lang.fengShui),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Tabs(),
          ),
        ),
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
      body: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: FutureBuilder(
                  future: _peopleDataSource,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) return const SizedBox(width: 50, height: 50, child: CircularProgressIndicator());

                    if (snapshot.hasError) return Text("${lang.error_loadingPeople}:\n${snapshot.error}", textAlign: TextAlign.center);

                    final ds = snapshot.data as PersonaDataSource;
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade800),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SfDataGridTheme(
                          data: SfDataGridThemeData(
                            headerColor: theme.colorScheme.onInverseSurface,
                            gridLineColor: Colors.transparent,
                          ),
                          child: SfDataGrid(
                            source: ds,
                            columnWidthMode: ds.rows.isEmpty ? ColumnWidthMode.fill : ColumnWidthMode.auto,
                            columns: peopleColumns,
                            selectionMode: SelectionMode.singleDeselect,
                            allowPullToRefresh: true,
                            onCellTap: _handleTap,
                            onCellLongPress: _handleLongTap,
                            frozenColumnsCount: 2,
                            controller: _dataGridController,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            ValueListenableBuilder(
              valueListenable: SelectionHandler.selected,
              builder: (context, selected, _) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  height: selected ? 36 : 16,
                  child: selected
                      ? Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 2.0),
                            child: Text(SelectionHandler.get!.name),
                          ),
                        )
                      : const SizedBox.shrink(),
                );
              },
            ),
          ],
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
