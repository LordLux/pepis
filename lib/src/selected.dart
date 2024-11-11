import 'package:flutter/material.dart';
import 'package:pepis/src/models.dart';

class SelectionHandler {
  static SelectionModel? _selected;

  static SelectionModel? get get => _selected;

  static ValueNotifier<bool> get selected => ValueNotifier(_selected != null);
  
  static void select(SelectionModel value) {
    deselect();
    _selected = value;
  }

  static void deselect() {
    _selected = null;
  }

  static bool isSelected(SelectionModel value) => _selected == value;
}
