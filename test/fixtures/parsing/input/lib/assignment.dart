// ignore_for_file: unused_local_variable, omit_local_variable_types

import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:pubspec_manager/pubspec_manager.dart';

void test() {
  Directory.current = Directory.current.path;

  final path = Directory('some/path')..path;
  final pubspec = PubSpec.load()..name.value = 'fred';
  final pValue = Test()..value = 1;

  exitCode = -1;

  const FetchMethod method = FetchMethod.get;
}

class Test {
  int? value;
}
