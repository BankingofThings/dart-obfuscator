import 'replacer.dart';

abstract interface class ProjectContext {
  Replacement replace(String name);

  bool isLocalLibrary(String pathToLibrary);

  /// Returns the list of libraries that are being obfuscated.
  Set<String> get libraries;
}
