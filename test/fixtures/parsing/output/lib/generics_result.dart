


import 'package:codemod_core/codemod_core.dart';
import 'package:dcli/dcli.dart';
import 'package:test/test.dart';

class A<B> {
  B? _c;

  B get d => _c!;

  set d(B d) {
    _c = d;
  }
}

extension on String {
  Iterable<String> e() => split(',');
}

extension on DartProject {
  String f() => DartProject.self.pathToProjectRoot;

  List<DartProject> g() => [DartProject.self];
}

Set<Path> _h = <Path>{};

void i<B>() => isA<A<String>>();

class J {}
