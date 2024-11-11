import 'package:flutter/material.dart';
import 'package:pepis/config/config.dart';

import '../../vars.dart';
import '../services/core_functions.dart';

class Tabs extends StatelessWidget {
  const Tabs({super.key});

  @override
  Widget build(BuildContext context) => const TabsStateful();
}

class TabsStateful extends StatefulWidget {
  const TabsStateful({super.key});

  @override
  TabsStatefulState createState() => TabsStatefulState();
}

class TabsStatefulState extends State<TabsStateful> {
  TextEditingController tabNameController = TextEditingController();
  Icon? pickedIcon;

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void iconPick() {}

  //TODO make into stateful widget with submitform and checks
  void _showAddTabDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lang.newTab),
        content: Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: InputDecoration(labelText: lang.name),
                controller: tabNameController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null) return null;
                  if (value.trim().isEmpty) return lang.warningDialogEmpty_name;
                  return null;
                },
              ),
            ),
            ElevatedButton.icon(
              onPressed: iconPick,
              label: const Icon(Icons.category),
            )
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(null);
            },
            child: Text(lang.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop({
                tabNameController.text: pickedIcon,
              });
            },
            child: Text(lang.addTab),
          ),
        ],
      ),
    ).then((newTab) {
      if (newTab != null) {
        TabManager.addTab(newTab);
        setState(() {});
      }
    });
  }

  List<Widget> buildTabs(List<Map<String, Icon?>> list) {
    return List.generate(
      list.length,
      (i) => Tab(
        onTap: () => _onItemTapped(i),
        title: list[i].entries.first.key,
        widget: list[i].entries.first.value,
        index: i,
        selected: i == _selectedIndex,
      ),
    );
  }

  Widget get plus => Padding(
        padding: const EdgeInsets.all(10.0),
        child: SizedBox.square(
          dimension: 30,
          child: InkWell(
            onTap: () => _showAddTabDialog(),
            borderRadius: const BorderRadius.all(Radius.circular(5)),
            child: Ink(
                decoration: BoxDecoration(
                  color: palette.onSecondary,
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                ),
                child: const Icon(Icons.add)),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = buildTabs(TabManager.tabs);
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 50,
            width: AppConfig.screenWidth,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: tabs + [plus],
            ),
          ),
        ),
        SizedBox(
          width: 144,
          child: Transform.translate(
            offset: const Offset(0, 1),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(lang.multiselection),
                Switch(
                  value: Settings.multiselection,
                  onChanged: (bool? value) => setState(() {
                    Settings.multiselection = value!;
                  }),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class Tab extends StatelessWidget {
  final String title;
  final Icon? widget;
  final void Function() onTap;
  final int index;
  final bool selected;

  const Tab({
    required this.title,
    required this.widget,
    required this.onTap,
    required this.index,
    required this.selected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ElevatedButton(
          style: ButtonStyle(
            elevation: WidgetStateProperty.all<double>(0),
            backgroundColor: WidgetStateProperty.all<Color>(selected ? theme.colorScheme.onInverseSurface : Colors.transparent),
            shape: WidgetStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.5))),
          ),
          onPressed: onTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget?.icon != null) Icon(widget!.icon, color: selected ? theme.colorScheme.onSurface : null),
                    const SizedBox(width: 10),
                    if (widget?.icon == null) const SizedBox(width: 10),
                    Text(title, style: selected ? TextStyle(color: theme.colorScheme.onSurface) : null),
                    if (widget?.icon == null) const SizedBox(width: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
        /*if (selected)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 1.5,
              color: theme.colorScheme.onSurface,
            ),
          ),*/
      ],
    );
  }
}
