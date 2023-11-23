// ignore_for_file: file_names
// ignore_for_file: flutter_style_todos

import 'dart:io';

import 'package:dart_obfuscator/src/exceptions.dart';
import 'package:dart_obfuscator/src/log_level.dart';
import 'package:dart_obfuscator/src/obfuscated_project.dart';
import 'package:dcli/dcli.dart';
import 'package:path/path.dart';

import 'args.dart';

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
  final parsed = Args(args);

  final project = DartProject.findProject(parsed.inputPath);
  if (project == null) {
    printerr(red('The current directory does not contain a Dart project.'));
    exit(1);
  }

  final projectRoot = project.pathToProjectRoot;
  if (!equals(projectRoot, parsed.inputPath)) {
    /// warn the user that we are processing a project located in an anscestor
    /// input path.
    print(orange('Processing project found at: $projectRoot'));
  }

  if (isWithin(projectRoot, parsed.pathToObfuscatedProject)) {
    printerr(red(
        """The 'output' path ${parsed.pathToObfuscatedProject} must NOT be within the 'input' path $projectRoot"""));
    exit(1);
  }
  final programStartTime = DateTime.now().millisecondsSinceEpoch;

  print(green('preparing ${parsed.pathToObfuscatedProject}'));

  // lets run the obfuscator.
  await _obfuscate(projectRoot, parsed);

  print('_' * 80);
  final executionTime = DateTime.fromMillisecondsSinceEpoch(
      DateTime.now().millisecondsSinceEpoch - programStartTime);
  print(
      """Obfuscation completed in ${executionTime.toIso8601String().split(':').last}""");
  print('Result is written to ${parsed.pathToObfuscatedProject}');
}

/// obfuscate the project.
Future<void> _obfuscate(String projectRoot, Args args) async {
  try {
    final obfuscatedProject = ObfuscatedProject(
        pathToSourceProject: projectRoot,
        includes: args.include,
        excludes: args.exclude,
        pathToTargetProject: args.pathToObfuscatedProject)
      ..prepare(overwrite: args.overwrite);

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
