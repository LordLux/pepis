import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pepis/src/datasource.dart';
import 'package:pepis/src/classes.dart';
import 'package:pepis/vars.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:rxdart/rxdart.dart';

import 'columns.dart';
import 'config/config.dart';
import 'src/db.dart';
import 'src/selected.dart';
import 'src/services/core_functions.dart';
import 'src/widgets/dialogs.dart';
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
  State<MyHomePage> createState() => MyHomePageState();
}

GlobalKey<MyHomePageState> homepageDialogKey = GlobalKey<MyHomePageState>();

class MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  late Future<PersonaDataSource> _peopleDataSource;
  final DataGridController _dataGridController = DataGridController();
  final MultiSplitViewController _multiViewController = MultiSplitViewController();

  late AnimationController _animationController;
  late Animation<double> _sizeAnimation;
  final double _summaryMinSize = 16;
  final double _summaryDefMaxSize = 250;

  final bool _pushDividers = true;

  void _addPersonDialog() => showDialog(
        context: context,
        builder: (_) => const AddPersonDialog(),
      ).then(
        (_) => refreshTable(),
      );

  void _handleTap(DataGridCellTapDetails details) async {
    // -1 to account for header row
    final int rowIndex = details.rowColumnIndex.rowIndex > 0 ? details.rowColumnIndex.rowIndex - 1 : details.rowColumnIndex.rowIndex;
    // get id from first cell of row
    final int id = await _peopleDataSource.then((dataSource) => dataSource.rows[rowIndex].getCells().first.value);
    // get person from db
    final SelectionModel newP = await DatabaseHelper().getSelectionById(id);

    if (SelectionHandler.isSelected(newP)) {
      // deselect person if already selected
      _deselect();
    } else {
      // select new person if not already selected
      await _selectPerson(details);
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
      _dataGridController.selectedRow = await _peopleDataSource.then((dataSource) => //
          dataSource.rows.firstWhere((row) => row.getCells().first.value == person.id));
      setState(() {});
      return person;
    });
  }

//TODO
  void _checkLastItem() async {
    final int? id = SelectionHandler.get!.id;
    final int lastId = await _peopleDataSource.then((dataSource) => dataSource.rows.last.getCells().first.value);
    if (id == lastId) {
      await Future.delayed(const Duration(milliseconds: 100));
      _dataGridController.scrollToRow(2000);
    }
  }

  void refreshTable() {
    _peopleDataSource = getDataSource();
    setState(() {});
  }

  void _rebuild() {
    setState(() {
      // rebuild to update empty text and buttons
    });
  }

  void _onSelectionChanged() {
    if (Settings.multiselection.value) {
      _animationController.forward().whenComplete(() {
        if (Settings.multiselection.value) {
          _multiViewController.areas = [
            Area(id: 0, data: "table", flex: 1),
            Area(id: 1, data: "summary", size: Settings.summarySize, min: _summaryDefMaxSize),
          ];
        }
      });
    } else {
      _animationController.reverse().whenComplete(() {
        if (!Settings.multiselection.value) {
          _multiViewController.areas = [
            Area(id: 0, data: "table", flex: 1),
          ];
        }
      });
    }
  }

  void _updateSummaryAreaSize(double size) {
    final updatedAreas = _multiViewController.areas.map((area) {
      if (area.id == 1) {
        return area.copyWith(size: () => size, min: () => _summaryMinSize);
      }
      return area;
    }).toList();

    _multiViewController.areas = updatedAreas;
  }

  _onDividerDragUpdate(int index) {
    if (kDebugMode) {
      // print('drag update: $index');
    }
  }

  _onDividerDragEnd(int index) {
    setState(() {
      Settings.summarySize = _sizeAnimation.value;
    });
  }

  _onDividerTap(int dividerIndex) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(seconds: 1),
      content: Text("Tap on divider: $dividerIndex"),
    ));
  }

  _onDividerDoubleTap(int dividerIndex) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(seconds: 1),
      content: Text("Double tap on divider: $dividerIndex"),
    ));
  }

  @override
  void initState() {
    super.initState();
    refreshTable();

    // multi split view
    _multiViewController.areas = [
      Area(id: 0, data: "table", flex: 1),
    ];

    // animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 170), // Adjust the duration as needed
    );

    // animation for resizing the summary area
    _sizeAnimation = Tween<double>(
      begin: _summaryMinSize,
      end: Settings.summarySize,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // LISTENERS
    SelectionHandler.selected.addListener(_checkLastItem);

    Settings.multiselection.addListener(() {
      setState(() {
        if (Settings.multiselection.value) {
          _multiViewController.areas = [
            Area(id: 0, data: "table", flex: 1),//TODO get ID + Nombre header width dynamically and set area 0 min size to that
            Area(id: 1, data: "summary", size: _summaryMinSize, min: _summaryMinSize), // Expanded size
          ];
        }
      });
    });

    Settings.multiselection.addListener(_onSelectionChanged);

    _sizeAnimation.addListener(() {
      setState(() {
        _updateSummaryAreaSize(_sizeAnimation.value);
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    lang = AppLocalizations.of(context)!;
    theme = Theme.of(context);
    palette = theme.colorScheme;
  }

  @override
  void dispose() {
    super.dispose();
    _multiViewController.removeListener(_rebuild);
    _animationController.dispose();
    SelectionHandler.selected.removeListener(_checkLastItem);
    Settings.multiselection.removeListener(_onSelectionChanged);
    _sizeAnimation.removeListener(() {});
  }

  @override
  Widget build(BuildContext context) {
    MultiSplitView multiSplitView = MultiSplitView(
        onDividerDragUpdate: _onDividerDragUpdate,
        onDividerTap: _onDividerTap,
        onDividerDoubleTap: _onDividerDoubleTap,
        controller: _multiViewController,
        pushDividers: _pushDividers,
        onDividerDragEnd: _onDividerDragEnd,
        builder: (BuildContext context, Area area) {
          switch (area.data) {
            case "table":
              return Column(
                children: [
                  Expanded(
                    child: Scaffold(
                      body: Container(
                        width: AppConfig.screenWidth,
                        height: AppConfig.screenHeight,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade800),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: FutureBuilder(
                            future: _peopleDataSource,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) //
                                return const Center(
                                  child: SizedBox(width: 40, height: 40, child: CircularProgressIndicator()),
                                );

                              if (snapshot.hasError) return Text("${lang.error_loadingPeople}:\n${snapshot.error}", textAlign: TextAlign.center);

                              final ds = snapshot.data as PersonaDataSource;
                              return SfDataGridTheme(
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
                              );
                            },
                          ),
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
                    ),
                  ),
                  //TODO
                  //when last item is selected, scroll to bottom of table to compensate
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
              );
            case "summary":
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade800),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 170),
                        opacity: Settings.multiselection.value ? 1 : 0,
                        curve: Settings.chosenCurve,
                        child: const Column(
                          children: [
                            Text("Summary"),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            default:
              return const SizedBox.shrink();
          }
        });

    Widget content = MultiSplitViewTheme(
      data: MultiSplitViewThemeData(
        dividerPainter: DividerPainters.grooved1(
          color: palette.secondary,
          size: 35,
          thickness: 5,
          highlightedColor: Colors.white,
          highlightedSize: 55,
          highlightedThickness: 6,
        ),
        dividerThickness: 25,
      ),
      child: multiSplitView,
    );

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
          ElevatedButton(
            onPressed: () async {
              await showDialog(context: context, builder: (_) => CurveSelectionDialog());
              setState(() {});
            },
            child: const Text("Curves"),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16.0, top: 8.0, right: 16.0),
        child: content,
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
