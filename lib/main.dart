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

  List<File> filesToObfuscate = determineStructure(libDir, sourceDirPath);
  final codeToObfuscate = scrapCodeToObfuscate(filesToObfuscate, libDir, outputFileName);
  deleteScrappedSourceFiles(filesToObfuscate);

  //todo delete empty directories
  //todo delete not needed imports in output file
  //todo update imports for non-obfuscated files (for every file that contains ref to deleted file replace it with output file import)

  final mappingSymbols = generateMappingsList();
  final codeWithRenamedClasses = renameClasses(codeToObfuscate, mappingSymbols);
  writeToOutput(codeWithRenamedClasses);

  final executionTime = DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch - programStartTime);
  print("Obfuscation completed in ${executionTime.toIso8601String().split(':').last}");
  print("Result is written to $outputFileName");
}

String renameClasses(String codeToObfuscate, List<String> mappingSymbols) {
  return codeToObfuscate;
}
