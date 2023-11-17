class A extends ArgumentError {
  @overrides
  @visibleForTesting
  String toString() => 'hi';

  void b() {}
}

class C extends A {
  @overrides
  String toString() => 'hi';

  void b() {}
}

class D extends A {
  void b() {}
}
