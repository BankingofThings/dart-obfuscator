import 'package:codemod_core/codemod_core.dart';
import 'package:dcli/dcli.dart';
import 'package:path/path.dart';

import 'exceptions.dart';
import 'replacer.dart';
import 'visitor.dart';

/// Used to create the obfuscated version of the project.

class ObfuscatedProject implements ProjectContext {
  /// The obfuscated version of the project is saved to
  /// [pathToTargetProject]
  ObfuscatedProject(
      {required this.pathToSourceProject, required this.pathToTargetProject});

  String pathToSourceProject;
  String pathToTargetProject;

  /// List of dart libraries that are part of the project.
  /// We use this to identify internal and external calls
  /// as we can't obfuscate calls to external libraries.
  Set<Path> libraries = <Path>{};

  void prepare({required bool overwrite}) {
    // Preparation
    if (exists(pathToTargetProject)) {
      if (!overwrite) {
        throw StructureException(
            '''The target directory $pathToTargetProject exists. Delete it or use the --overwrite option.''');
      }

      deleteDir(pathToTargetProject);
    }
    createDir(pathToTargetProject, recursive: true);
    _copyCoreStructure();

    libraries =
        find('*.dart', workingDirectory: pathToTargetProject).toList().toSet();
  }

  void processProcessing() {
    _copyDir('example');
  }

  /// Copies the core structure of the dart package to the target directory
  void _copyCoreStructure() {
    _copyFile('CHANGELOG.md');
    _copyFile('LICENSE');
    _copyFile('LICENSE.md');
    _copyFile('pubspec.yaml', optional: false);
    _copyFile('pubspec.lock', optional: false);
    _copyFile('pubspec_overrides.yaml');
    _copyFile('README');
    _copyFile('README.md');
    _copyDir('lib');
  }

  /// Copies [projectRelativePathToFile] which is relative
  /// to [pathToSourceProject] into the same location with
  /// the same filename in the [pathToTargetProject]
  void _copyFile(String projectRelativePathToFile, {bool optional = true}) {
    final pathToSrc = join(pathToSourceProject, projectRelativePathToFile);
    if (optional && !exists(pathToSrc)) {
      return;
    }
    copy(pathToSrc, join(pathToTargetProject, projectRelativePathToFile));
    print('copied: $projectRelativePathToFile');
  }

  void _copyDir(String pathToDir) {
    final targetLib = join(pathToTargetProject, 'lib');
    createDir(targetLib, recursive: true);
    copyTree(join(pathToSourceProject, 'lib'), targetLib);
  }

  Future<void> obfuscate() async {
    final pg = PatchGenerator([
      Visitor(this).call,
    ]);

    /// do we need to pass a stream to the generator given how big our list
    /// of paths could end up being.
    final paths =
        find('*.dart', workingDirectory: pathToSourceProject).toList();
    final changeSetStream = pg.generate(paths: paths);

    await for (final changeSet in changeSetStream) {
      final targetPath = join(pathToTargetProject,
          relative(changeSet.sourceFile.url!.path, from: pathToSourceProject));
      changeSet.applyAndSave(destPath: targetPath);
    }
  }

  @override
  bool isLocalLibrary(String pathToLibrary) =>
      libraries.contains(pathToLibrary);

  @override
  String replace(String name) => Replacer().replace(name);
}

abstract interface class ProjectContext {
  String replace(String name);

  bool isLocalLibrary(String pathToLibrary);
}
