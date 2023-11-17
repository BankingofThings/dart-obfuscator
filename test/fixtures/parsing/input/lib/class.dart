// ignore_for_file: unnecessary_getters_setters
// ignore_for_file: avoid_classes_with_only_static_members

class Test {
  static String _instance = '';

  static String get instance => _instance;

  static set instance(String instance) {
    _instance = instance;
  }
}
