import 'package:codemod_core/codemod_core.dart';
import 'package:dcli/dcli.dart';
import 'package:meta/meta.dart';
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

  final String pathToSourceProject;
  final String pathToTargetProject;

  /// List of dart libraries that are part of the project.
  /// We use this to identify internal and external calls
  /// as we can't obfuscate calls to external libraries.
  Set<Path> _libraries = <Path>{};

  ///
  /// Prepare the code for obfuscation by copying it
  /// across to the output directory and selecting
  /// the files to obfuscate.
  ///
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

    _libraries =
        find('*.dart', workingDirectory: join(pathToTargetProject, 'lib'))
            .toList()
            .toSet();
  }

  ///
  /// Run the actual obfuscation process.
  ///
  Future<void> obfuscate() async => obfuscateList(
      context: this,
      paths: _libraries,
      pathToSourceParent: pathToSourceProject,
      pathToTargetParent: pathToTargetProject);

  @visibleForTesting
  static Future<void> obfuscateList(
      {required ProjectContext context,
      required Set<String> paths,
      required String pathToSourceParent,
      required String pathToTargetParent}) async {
    final pg = PatchGenerator([
      Visitor(context).call,
    ]);

    /// do we need to pass a stream to the generator given how big our list
    /// of paths could end up being.
    final changeSetStream = pg.generate(paths: paths);

    await for (final changeSet in changeSetStream) {
      final targetPath = truepath(pathToTargetParent,
          relative(changeSet.sourceFile.url!.path, from: pathToSourceParent));
      changeSet.applyAndSave(destPath: targetPath);
    }
  }

  ///
  /// Run post obfuscation tasks such as copying any files
  /// or directories that didn't need to be obfuscated.
  ///
  void processProcessing() {
    _copyDir('android');
    _copyDir('example');
    _copyDir('ios');
    _copyDir('linux');
    _copyDir('macos');
    _copyDir('windows');
    _copyFile('plugin.iml');
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
    _copyDir('lib', optional: false);
    _copyDir('test');
  }

  /// Copies [projectRelativePathToFile] which is relative
  /// to [pathToSourceProject] into the same location with
  /// the same filename in the [pathToTargetProject]
  void _copyFile(String projectRelativePathToFile, {bool optional = true}) {
    final pathToSrc = truepath(pathToSourceProject, projectRelativePathToFile);
    if (optional && !exists(pathToSrc)) {
      return;
    }
    copy(pathToSrc, truepath(pathToTargetProject, projectRelativePathToFile));
    print('copied: $projectRelativePathToFile');
  }

  void _copyDir(String pathToDir, {bool optional = true}) {
    final srcDir = truepath(pathToSourceProject, pathToDir);

    if (optional && !exists(srcDir)) {
      return;
    }

    final targetDir = truepath(pathToTargetProject, pathToDir);

    createDir(targetDir, recursive: true);
    copyTree(srcDir, targetDir);

    print('copied: $srcDir');
  }

  @override
  bool isLocalLibrary(String pathToLibrary) =>
      _libraries.contains(pathToLibrary);

  @override
  String replace(String name) => Replacer().replace(name);
}

abstract interface class ProjectContext {
  String replace(String name);

  bool isLocalLibrary(String pathToLibrary);
}
