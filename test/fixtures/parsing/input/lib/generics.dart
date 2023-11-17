// ignore_for_file: avoid_classes_with_only_static_members, unused_element
//  , unnecessary_getters_setters

import 'package:codemod_core/codemod_core.dart';
import 'package:dcli/dcli.dart';
import 'package:test/test.dart';

class Test<T> {
  T? _instance;

  T get instance => _instance!;

  set instance(T instance) {
    _instance = instance;
  }
}

extension on String {
  Iterable<String> asplit() => split(',');
}

extension on DartProject {
  String root() => DartProject.self.pathToProjectRoot;

  List<DartProject> all() => [DartProject.self];
}

Set<Path> _libraries = <Path>{};

void some<T>() => isA<Test<String>>();

class AType {}
