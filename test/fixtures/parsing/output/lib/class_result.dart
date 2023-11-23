


class A {
  A._b();
  static String _c = '';

  static String get d => _c;

  static set d(String d) {
    _c = d;
  }
}

class E implements Exception {
  E(this.f);
  String f;
}


class G extends E {
  G(super.f);
}

class H extends E {
  H() : super('CleanCommand');
}
