import '../enums.dart';
import '../widgets/dialogs.dart';
import 'dart:math';

void fillRandom() {
  var res = generateRandom();
  PersonDialogStatefulState state = addPersonaDialogKey.currentState!;

  state.nameController.text = res.$1;
  state.birthDateController.text = res.$2;
  state.gender = res.$3;
}

dynamic generateRandom() {
  Random rng = Random();

  String name = generateString(rng.nextInt(16) + 8);
  String birthday = '${rng.nextInt(31) + 1}/${rng.nextInt(12) + 1}/${rng.nextInt(94) + 1930}';
  Gender gender = Gender.values[rng.nextBool() ? 1 : 0];
  return (name, birthday, gender);
}

String generateString(int length) {
  Random rng = Random();
  const String chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
  return String.fromCharCodes(Iterable.generate(length, (_) => chars.codeUnitAt(rng.nextInt(chars.length))));
}
