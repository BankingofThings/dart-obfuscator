class Test {
  static String _instance = '';

  static String get instance => _instance;

  static set instance(String instance) {
    _instance = instance;
  }
}
