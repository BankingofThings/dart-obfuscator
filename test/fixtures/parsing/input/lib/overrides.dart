class Test extends ArgumentError {
  @overrides
  String toString() => 'hi';

  void doSomething() {
    // no op
  }
}

class Test2 extends Test {
  @overrides
  String toString() => 'hi';

  void doSomething() {
    // no op
  }
}

class Test3 implements Test {}