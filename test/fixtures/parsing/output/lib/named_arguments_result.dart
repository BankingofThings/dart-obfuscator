


import 'package:dcli/dcli.dart' as a;
import 'package:dcli/dcli.dart';

void b(
  String c, {
  required String d,
  FetchMethod e = FetchMethod.get,
}) {}

void f() {
  b('one', d: 'two');
  a.withFileProtection([], () {}, workingDirectory: 'path');
}
