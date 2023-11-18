


class A {
  static String _b = '';

  static String get c => _b;

  static set c(String c) {
    _b = c;
  }
}

class D implements Exception {
  D(this.e);
  String e;
}


class F extends D {
  F(super.e);
}
