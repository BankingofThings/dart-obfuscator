// ignore_for_file: prefer_expression_function_bodies
// ignore_for_file:  join_return_with_assignment

import 'package:dcli/dcli.dart' as dcli;
import 'package:dcli/dcli.dart';

void simple(
  String arg1, {
  required String arg2,
  FetchMethod fetchMethod = FetchMethod.get,
}) {}

void simple2() {
  simple('one', arg2: 'two');
  dcli.withFileProtection([], () {}, workingDirectory: 'path');
}
