// ignore_for_file: flutter_style_todos

import 'dart:io';

import 'package:args/args.dart';
import 'package:dcli/dcli.dart';

import 'src/exceptions.dart';
import 'src/log_level.dart';
import 'src/obfuscated_project.dart';

//Improvements
//1. Inside every class variables and methods can have same names

//todo when moving class to output rename it to something path relative,
// so it does not clash with files with same name from other dirs,
// same for upper level constants and functions
// 3. rename methods (static and not)
// 4. rename variables (static and not)
// 5. store mapping

// ignore: unreachable_from_main
const logLevel = LogLevel.DEBUG;

//todo delete empty directories
//todo delete not needed imports in output file
//todo update imports for non-obfuscated files (for every file that contains
//   ref to deleted file replace it with output file import)
//todo import import 'package:finn_dart_sdk/src/services/../shared_prefs.dart';
//    is not deleted

void main(List<String> args) async {
  final parser = ArgParser()
    ..addOption('output',
        abbr: 'o',
        help: 'Path to store the obfuscated project',
        mandatory: true)
    ..addOption(
      'input',
      abbr: 'i',
      help:
          '''Path to the location of the project to obfuscate. Defaults to the current directory''',
    )
    ..addFlag('overwrite', abbr: 'w', help: '''
If the output path exist then it will be overwritten. 
Basic checks are peformed to ensure that the target directory was created by
the obfuscator.''');

  late String pathToProject;
  late String pathToObfuscatedProject;
  late bool overwrite;
  try {
    final parsed = parser.parse(args);
    pathToObfuscatedProject = parsed['output'] as String;
    pathToProject = parsed['input'] as String? ?? pwd;
    overwrite = parsed['overwrite'] as bool;
  } on FormatException catch (e) {
    printerr(e.message);
  }

  final project = DartProject.findProject(pathToProject);
  if (project == null) {
    printerr(red('The current directory does not contain a Dart project.'));
    exit(1);
  }

  final projectRoot = project.pathToProjectRoot;

  final programStartTime = DateTime.now().millisecondsSinceEpoch;

  print(green('preparing $pathToObfuscatedProject'));

  await _obfuscate(projectRoot, pathToObfuscatedProject, overwrite);

  print('_' * 80);
  final executionTime = DateTime.fromMillisecondsSinceEpoch(
      DateTime.now().millisecondsSinceEpoch - programStartTime);
  print(
      """Obfuscation completed in ${executionTime.toIso8601String().split(':').last}""");
  print('Result is written to $pathToObfuscatedProject');
}

Future<void> _obfuscate(
    String projectRoot, String pathToObfuscatedProject, bool overwrite) async {
  try {
    final obfuscatedProject = ObfuscatedProject(
        pathToSourceProject: projectRoot,
        pathToTargetProject: pathToObfuscatedProject)
      ..prepare(overwrite: overwrite);

    print(green('obfuscating $projectRoot'));
    await obfuscatedProject.obfuscate();

    print(green('obfuscation - complete'));
    print(green('running post processing'));
    obfuscatedProject.postProcessing();
    print(green('post processing - complete'));
  } on StructureException catch (e) {
    printerr(red(e.message));
    exit(1);
  }
}
