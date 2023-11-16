// import 'dart:io';

// import 'package:dcli/dcli.dart';
// import 'package:path/path.dart';
// import 'package:pubspec_manager/pubspec_manager.dart';

// import '../main.dart';
// import 'exceptions.dart';
// import 'log_level.dart';
// import 'structure.dart';

// String? _packageName;

// String get packageName => _packageName ??= PubSpec.load().name.value;

// String outputFileName = 'xx.dart';

// //region Files processing
// Structure determineStructure(Path libDir) {
//   if (!exists(libDir)) {
//     throw StructureException('The expected ${truepath(libDir)} was not found.');
//   }

//   final rootFiles = find('*.dart")', workingDirectory: libDir).toList();

//   final exportedFiles = findExportedFiles(rootFiles);
//   final rawFiles = rootFiles
//     ..addAll(exportedFiles)
//     ..removeWhere((dartLibrary) => dartLibrary == join(libDir, outputFileName));

//   if (logLevel == LogLevel.VERBOSE) {
//     print('Files to obfuscate');
//   }
//   final filesToObfuscate = findFilesToObfuscate(libDir, rawFiles);
//   for (final dartLibrary in filesToObfuscate) {
//     if (logLevel == LogLevel.VERBOSE) {
//       print(dartLibrary);
//     }
//   }
//   return Structure(rawFiles, filesToObfuscate);
// }

// List<Path> findFilesToObfuscate(Path libDir, List<Path> rawFiles) =>
//     find('*.dart', workingDirectory: libDir)
//         .toList()
//         .where((element) => !rawFiles.map((e) => e).contains(element))
//         .toList();

// /// Returns all sources from all files that have to be obfuscated as string
// String scrapCodeToObfuscate(
//     List<Path> filesToObfuscate, Path libDir, Path outputFileName) {
//   final allImports = <String>{};
//   final nonImportLines = <String>[];
//   for (final theFile in filesToObfuscate) {
//     read(theFile).forEach((line) {
//       if (isLineImport(line)) {
//         final absoluteImport = updateImportToAbsoluteIfNeeded(line, theFile);
//         if (!isImportOfFileToBeDeleted(absoluteImport, filesToObfuscate)) {
//           allImports.add(absoluteImport);
//         }
//       } else if (!isLinePart(line) && !isLineComment(line)) {
//         nonImportLines.add(line);
//       }
//     });
//   }

//   final allLines = (allImports.toList() + nonImportLines)
//       .reduce((value, element) => '$value$element\n');
//   return allLines;
// }

// //endregion

// //region imports
// bool isImportOfFileToBeDeleted(
//     String absoluteImport, List<Path> filesToObfuscate) {
//   final knownPaths = filesToObfuscate.map((e) => e.split('/lib/').last);
//   final strippedImport =
//       absoluteImport.replaceAll(RegExp('^(.*?)/'), '').split("'").first;
//   return knownPaths.contains(strippedImport);
// }

// String updateImportToAbsoluteIfNeeded(String line, String sourceFilePath) {
//   if (isLineRelativeImport(line)) {
//     final relativePath = sourceFilePath
//         .replaceAll(basename(sourceFilePath), '')
//         .split('/lib/')
//         .last;
//     final newLine = line.replaceAll(
//         "import '", "import 'package:$packageName/$relativePath");
//     // print("Replace relative $line\nto: $newLine");
//     return newLine;
//   } else {
//     return line;
//   }
// }

// /// Receives import or export line and returns cleared path.
// String clearImportSymbols(String line) {
//   if (isLineImport(line)) {
//     return line
//         .replaceAll("import '", '')
//         .replaceAll("'", '')
//         .replaceAll(';', '');
//   } else if (isLineExport(line)) {
//     final clear =
//         line.replaceAll("export '", '').replaceAll("'", '').replaceAll(';', '');
//     return clear;
//   } else {
//     throw CodeFormatException('This is neither import nor export line');
//   }
// }

// void updateImportsInNonObfuscatedFiles(
//     Structure structure, Path outputFileName) {
//   for (final file in structure.rawFiles) {
//     final lines = read(file).toList();

//     final outputFileImport = "import 'package:$packageName/$outputFileName';";
//     var updatedLines = lines
//         .where((element) =>
//             !isLineImport(element) ||
//             !isImportOfFileToBeDeleted(element, structure.filesToObfuscate))
//         .toList();
//     if (updatedLines.length < lines.length) {
//       updatedLines = [outputFileImport] + updatedLines;
//     }

//     final outputFilePath = basename(file);
//     if (logLevel == LogLevel.VERBOSE) {
//       print('Update ${lines.length - updatedLines.length} '
//           'imports for file: $outputFilePath');
//     }
//     file.write(updatedLines.reduce((value, element) => '$value\n$element'));
//   }
// }

// List<Path> findExportedFiles(List<Path> rootFiles) {
//   final allExportedFiles = <Path>[];

//   if (logLevel == LogLevel.VERBOSE) {
//     print('Root files found:');
//   }
//   for (final dartLibrary in rootFiles) {
//     if (logLevel == LogLevel.VERBOSE) {
//       print(dartLibrary);
//     }
//     if (logLevel == LogLevel.VERBOSE) {
//       print('Export files declared in this root:');
//     }
//     final exportFiles = checkExports(dartLibrary);
//     if (logLevel == LogLevel.VERBOSE) {
//       for (final element in exportFiles) {
//         print(element);
//       }
//     }
//     allExportedFiles.addAll(exportFiles);
//   }

//   return allExportedFiles;
// }

// /// Reads `export` and returns list of dart libraries
// /// that have been exported.
// List<Path> checkExports(Path pathToDartLibrary) {
//   final exportFiles = <Path>[];

//   File(pathToDartLibrary).readAsLinesSync().forEach((line) {
//     if (line.startsWith('export ')) {
//       final relativePath = clearImportSymbols(line);
//       final pathToExportedLibrary =
//           join(dirname(pathToDartLibrary), relativePath);
//       if (exists(pathToExportedLibrary)) {
//         exportFiles.add(pathToExportedLibrary);
//       } else {
//         // todo: shall I exit with error here?
//         print(
//             '''[WARNING] Exported Dart Library does not exist: $pathToExportedLibrary\nPlease make sure your project is compiling before proceeding''');
//       }
//     }
//   });

//   return exportFiles;
// }

// bool isLineComment(String line) => line.startsWith('//');

// bool isLinePart(String line) => line.startsWith('part ');

// bool isLineExport(String line) => line.startsWith('export ');

// bool isLineImport(String line) => line.startsWith('import ');

// bool isLineRelativeImport(String line) =>
//     isLineImport(line) &&
//     !line.contains("'package:") &&
//     !line.startsWith("import 'dart:");

// //endregion

// //region Obfuscation

// //todo what if there's not enough mappings?
// /// Generates mappings that later will
// List<String> generateMappingsList() {
//   final mappingSymbols = <String>[];
//   final alphabet = <String>[];
//   var letterCode = 'A'.codeUnitAt(0);
//   for (var i = 0; i < (26 * 2); i++) {
//     if (i == 26) {
//       letterCode +=
//           6; //skip symbols in between Upper case letters and lower case letters
//     }
//     alphabet.add(String.fromCharCode(letterCode++));
//     // print("$i ${String.fromCharCode(letter++)} ");
//   }

//   for (final letterOne in alphabet) {
//     for (final letterTwo in alphabet) {
//       // print("$letterOne$letterTwo");
//       mappingSymbols.add('$letterOne$letterTwo');
//     }
//   }

//   // print("And we have ${mappingSymbols.length} mappings");
//   return mappingSymbols;
// }

// void updateRawFilesWithObfuscatedClasses(
//     List<Path> rawFiles, Map<String, String> resultingMapping) {
//   for (final theFile in rawFiles) {
//     resultingMapping.forEach((theClass, theMapping) {
//       final fileText = read(theFile).toParagraph();
//       final updatedText = fileText.replaceAll(RegExp(theClass), theMapping);
//       theFile.write(updatedText);
//     });
//   }
// }

// //endregion

// //region Clean up
// /// Delete files that are scrapped and code from which will be
// /// written to single file and obfuscated
// void deleteScrappedSourceFiles(List<Path> filesToObfuscate) {
//   for (final element in filesToObfuscate) {
//     if (exists(element)) {
//       delete(element);
//     }
//   }
// }

// // Deletes all empty directories under [libDir]
// void deleteEmptyDirectories(Path libDir) {
//   find('*', types: [Find.directory], workingDirectory: libDir)
//       .forEach((directory) {
//     if (isEmpty(directory)) {
//       delete(directory);
//     }
//   });
// }

// //endregion

// //region Read-Write
// typedef Modification = String Function(String line);

// bool _updateFileLineByLine(File file, Modification modification) {
//   final lines = file.readAsLinesSync();

//   final updatedLines = <String>[];
//   for (final theLine in lines) {
//     final modifiedLine = modification(theLine);
//     updatedLines.add(modifiedLine);
//   }

//   file.writeAsStringSync(
//       updatedLines.reduce((value, element) => '$value\n$element'));
//   return updatedLines.length < lines.length;
// }

// void writeToOutput(String text) {
//   if (exists(outputFileName)) {
//     delete(outputFileName);
//   }
//   outputFileName.write(text);
// }

// //endregion
