

import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:pubspec_manager/pubspec_manager.dart';

void a() {
  Directory.current = Directory.current.path;

  final b = Directory('some/path')..path;
  final c = PubSpec.load()..name.value = 'fred';
  final d = E()..f = 1;

  exitCode = -1;

  const FetchMethod g = FetchMethod.get;
}

class E {
  int? f;
}
