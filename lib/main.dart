import 'dart:io';

import 'package:dart_obfuscator/implementation.dart';
import 'package:dart_obfuscator/log_level.dart';

//todo when moving class to output rename it to something path relative, so it does not clash with files with same name from other dirs, same for upper level constants and functions
// 1. Create mapping list with cryptic names
// 2. rename classes
// 3. rename methods (static and not)
// 4. rename variables (static and not)
// 5. store mapping

final logLevel = LogLevel.DEBUG;
// final logLevel = LogLevel.VERBOSE;
final obfuscationMap = Map<String, String>();
final packageName = 'finn_dart_sdk';
final sourceDirPath = "/Users/denisvolyntsev/dev/Finn/Dart-Mobile-SDK";
final outputFileName = "finn_obfuscated.dart";
final libDir = Directory("$sourceDirPath/lib");

void main(List<String> args) async {
  final programStartTime = DateTime.now().millisecondsSinceEpoch;
  // determineStructure(args);

  print("args: $args");

  final structure = determineStructure(libDir, sourceDirPath);
  final codeToObfuscate = scrapCodeToObfuscate(structure.filesToObfuscate, libDir, outputFileName);
  deleteScrappedSourceFiles(structure.filesToObfuscate);
  deleteEmptyDirectories(libDir);

  //todo delete empty directories
  //todo delete not needed imports in output file
  //todo update imports for non-obfuscated files (for every file that contains ref to deleted file replace it with output file import)
  //todo import import 'package:finn_dart_sdk/src/services/../shared_prefs.dart'; is not deleted

  final mappingSymbols = generateMappingsList();
  final codeWithRenamedClasses = renameClasses(codeToObfuscate, mappingSymbols);
  writeToOutput(codeWithRenamedClasses);

  updateImportsInNonObfuscatedFiles(structure, outputFileName);

  final executionTime = DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch - programStartTime);
  print("Obfuscation completed in ${executionTime.toIso8601String().split(':').last}");
  print("Result is written to $outputFileName");
}

//todo only works for hightes level leaves, not for root folder (services folder is not deleted)
void deleteEmptyDirectories(Directory libDir) {
  libDir.listSync(recursive: true).whereType<Directory>().where((element) => element.listSync(recursive: true).isEmpty).forEach((emptyDir) {
    emptyDir.deleteSync();
  });
}

String renameClasses(String codeToObfuscate, List<String> mappingSymbols) {
  return codeToObfuscate;
}
