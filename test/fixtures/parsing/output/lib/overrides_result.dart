import 'package:meta/meta.dart';

class A extends ArgumentError {
  @override
  @visibleForTesting
  String toString() => 'hi';

  void b() {

  }
}

class C extends A {
  @override
  String toString() => 'hi';
  
  @override
  void b() {
    
  }
}

class D extends A {
  @override
  void b() {}
}
