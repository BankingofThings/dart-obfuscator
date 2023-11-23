import 'package:meta/meta.dart';

class Test extends ArgumentError {
  @override
  @visibleForTesting
  String toString() => 'hi';

  void doSomething() {
    // no op
  }
}

class Test2 extends Test {
  @override
  String toString() => 'hi';

  @override
  void doSomething() {
    print(toString());
  }
}

class Test3 extends Test {
  @override
  void doSomething() {}
}
