class A extends ArgumentError {
  @overrides
  String toString() => 'hi';

  void b() {
    
  }
}

class C extends A {
  @overrides
  String toString() => 'hi';

  void b() {
    
  }
}

class D implements A {}
