import 'package:dart_obfuscator/src/obfuscated_project.dart';
import 'package:dcli/dcli.dart';
import 'package:path/path.dart' hide equals;
import 'package:test/test.dart';

void main() async {
  test('include/exclude matches', () async {
    withTempDir((pathToSource) {
      withTempDir((pathToTarget) {
        final paths = Paths(pathToSource);
        _buildProject(paths);
        ObfuscatedProject(
            pathToSourceProject: pathToSource,
            pathToTargetProject: pathToTarget,
            includes: [],
            excludes: []).prepare(overwrite: true);

        expect(exists(paths.pubspecYaml), equals(true));
        expect(exists(paths.oneDart), equals(true));
        expect(exists(paths.testDart), equals(true));

        expect(exists(paths.exampleDart), equals(false));
        expect(exists(paths.toolDart), equals(false));
      });
    });
  });
}

void _buildProject(Paths paths) {
  _create(join(paths.pathToSource, 'pubspec.yaml'));
  _create(join(paths.pathToLibSrc, 'one.dart'));
  _create(join(paths.pathToExample, 'example.dart'));
  _create(join(paths.pathToTool, 'tool.dart'));
  _create(join(paths.pathToTest, 'test.dart'));
}

void _create(String pathToFile) {
  if (!exists(dirname(pathToFile))) {
    createDir(dirname(pathToFile), recursive: true);
  }
  touch(pathToFile, create: true);
}

class Paths {
  Paths(this.pathToSource);
  String pathToSource;

  String get pathToExample => join(pathToSource, 'example');
  String get pathToTool => join(pathToSource, 'tool');
  String get pathToTest => join(pathToSource, 'test');
  String get pathToLib => join(pathToSource, 'lib');
  String get pathToLibSrc => join(pathToSource, 'lib', 'src');

  /// test files
  String get pubspecYaml => join(pathToSource, 'pubspec.yaml');
  String get oneDart => join(pathToLibSrc, 'one.dart');
  String get exampleDart => join(pathToExample, 'example.dart');
  String get toolDart => join(pathToTool, 'tool.dart');
  String get testDart => join(pathToTest, 'test.dart');
}
