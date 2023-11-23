import 'package:codemod_core/codemod_core.dart';
import 'package:dart_obfuscator/src/project_context.dart';
import 'package:dart_obfuscator/src/replacer.dart';
import 'package:dcli/dcli.dart';

class ProjectContextMock implements ProjectContext {
  ProjectContextMock(String pathToSource) {
    _libraries =
        find('*.dart', workingDirectory: pathToSource).toList().toSet();
  }

  Set<Path> _libraries = <Path>{};
  @override
  bool isLocalLibrary(String pathToLibrary) =>
      _libraries.contains(pathToLibrary);

  @override
  Replacement replace(String name) => Replacer().replace(name);

  @override
  Set<String> get libraries => _libraries;
}
