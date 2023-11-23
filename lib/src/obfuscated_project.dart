import 'dart:io';

import 'package:codemod_core/codemod_core.dart';
import 'package:dcli/dcli.dart';
import 'package:glob/glob.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart';

import 'exceptions.dart';
import 'obfuscating_visitor.dart';
import 'project_context.dart';
import 'replacer.dart';

/// Used to create the obfuscated version of the project.

class ObfuscatedProject implements ProjectContext {
  /// The obfuscated version of the project is saved to
  /// [pathToTargetProject]
  /// You can limit the set of dart files by passing in a set of filters
  /// in the forms of globs that files must match at least one of to be
  /// included.  If [includes] is empty then all files in match.
  ObfuscatedProject(
      {required this.pathToSourceProject,
      required this.pathToTargetProject,
      required this.includes,
      required this.excludes});

  final String pathToSourceProject;
  final List<String> includes;
  final List<String> excludes;
  final String pathToTargetProject;

  /// List of dart libraries that are part of the project.
  /// We use this to identify internal and external calls
  /// as we can't obfuscate calls to external libraries.
  final Set<Path> _libraries = <Path>{};

  ///
  /// Prepare the code for obfuscation by copying it
  /// across to the output directory and selecting
  /// the files to obfuscate.
  ///
  void prepare({required bool overwrite}) {
    // Preparation
    _prepareDirectory(overwrite);

    /// Run pub get to ensure the AST is fully resolved.
    print('running dart pub get');
    DartSdk().runPubGet(pathToTargetProject);

    final paths =
        find('*.dart', workingDirectory: pathToTargetProject).toList().toSet();

    if (includes.isEmpty && excludes.isEmpty) {
      _libraries.addAll(paths);
    } else {
      _libraries.addAll(paths.where(_allowed));
    }
  }

  /// Create the output directory and copy the core project
  /// files into it.
  void _prepareDirectory(bool overwrite) {
    // validate that the output directory is sensible.
    if (equals(pathToTargetProject, rootPath)) {
      printerr(red('The output directory may not be $rootPath'));
      exit(1);
    }
    if (split(pathToTargetProject).length < 2) {
      printerr(red('The output directory may not be in $pathToTargetProject'));
      exit(1);
    }

    if (exists(pathToTargetProject)) {
      if (!overwrite) {
        throw StructureException(
            '''The target directory $pathToTargetProject exists. Delete it or use the --overwrite option.''');
      }

      _deleteOutputDir(pathToTargetProject);
    }
    createDir(pathToTargetProject, recursive: true);
    _copyCoreStructure();
  }

  /// [path] will be obfuscated providing it matches at least
  /// one of the [includes]s.
  bool _allowed(String path) {
    /// Globs are relative to the target project root
    final relativePath = relative(path, from: pathToTargetProject);
    if (relativePath.contains('bin')) {
      print('hi');
    }

    for (final exclude in excludes) {
      if (Glob(exclude).matches(relativePath)) {
        return false;
      }
    }

    /// If there are no includes then everything not excluded
    /// is included.
    if (includes.isEmpty) {
      return true;
    }

    for (final include in includes) {
      if (Glob(include).matches(relativePath)) {
        return true;
      }
    }
    return false;
  }

  ///
  /// Run the actual obfuscation process.
  ///
  Future<void> obfuscate() async => obfuscateList(
      context: this,
      paths: _libraries,
      pathToSourceParent: pathToSourceProject,
      pathToTargetParent: pathToTargetProject);

  /// [paths] must be absolute paths.
  @visibleForTesting
  static Future<void> obfuscateList(
      {required ProjectContext context,
      required Set<String> paths,
      required String pathToSourceParent,
      required String pathToTargetParent}) async {
    final pg = PatchGenerator([
      ObfuscatingVisitor(context).call,
    ]);

    /// do we need to pass a stream to the generator given how big our list
    /// of paths could end up being.
    final changeSetStream = pg.generate(paths: paths);

    /// We need to keep track of which libraries didn't
    /// need to be modified as we will need to manually
    /// copy these to the target.
    final _unpatchedLibraries = <Path>{...paths};

    await for (final changeSet in changeSetStream) {
      final pathToSourceLibrary = changeSet.sourceFile.url!.path;
      final relativePathToSourceLibrary =
          relative(pathToSourceLibrary, from: pathToSourceParent);
      final targetPath =
          truepath(pathToTargetParent, relativePathToSourceLibrary);
      changeSet.applyAndSave(destPath: targetPath, skipOverlapping: true);
      _unpatchedLibraries.remove(pathToSourceLibrary);
    }

    /// check for any files that were not included in any [ChangeSet]
    /// and manually copy them across
    for (final library in _unpatchedLibraries) {
      final targetPath = truepath(
          pathToTargetParent, relative(library, from: pathToSourceParent));

      copy(library, targetPath);
    }
  }

  ///
  /// Run post obfuscation tasks such as copying any files
  /// or directories that didn't need to be obfuscated.
  ///
  void postProcessing() {
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
    // _copyFile('pubspec_overrides.yaml');
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
  Replacement replace(String name) => Replacer().replace(name);

  /// Returns the list of libraries that are being obfuscated.
  @override
  Set<String> get libraries => _libraries;

  /// Delete the contents of the output director.
  /// We retain the root directory as it make it easier to
  /// have an editor open in the root of the output directory
  /// to monitor results.
  void _deleteOutputDir(String pathToTargetProject) {
    final children = find('*', includeHidden: true).toList();

    for (final child in children) {
      if (isDirectory(child)) {
        deleteDir(child);
      } else if (isLink(child)) {
        deleteSymlink(child);
      } else {
        delete(child);
      }
    }
  }
}
