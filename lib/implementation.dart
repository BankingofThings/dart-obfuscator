import 'dart:io';

import 'package:dart_obfuscator/log_level.dart';
import 'package:dart_obfuscator/main.dart';
import 'package:dart_obfuscator/models.dart';
import 'package:path/path.dart';

Structure determineStructure(Directory libDir, String sourceDirPath) {
  if (!libDir.existsSync()) {
    throw "Directory $sourceDirPath does not exists or does not contain /lib dir";
  }

  final rootFiles = libDir.listSync(recursive: false).where((element) => element is File).whereType<File>().toList();
  final exportedFiles = findExportedFiles(rootFiles);
  final List<File> rawFiles = rootFiles + exportedFiles;
  rawFiles.removeWhere((element) => element.path == "${libDir.path}/$outputFileName");

  if (logLevel == LogLevel.VERBOSE) print("Files to obfuscate");
  List<File> filesToObfuscate = findFilesToObfuscate(libDir, rawFiles);
  filesToObfuscate.forEach((element) {
    if (logLevel == LogLevel.VERBOSE) print("${element.path}");
  });
  return Structure(rawFiles, filesToObfuscate);
}

/// Returns all sources that have to be obfuscated as string
String scrapCodeToObfuscate(List<File> filesToObfuscate, Directory libDir, String outputFileName) {
  final allImports = Set<String>();
  final nonImportLines = List<String>();
  filesToObfuscate.forEach((theFile) {
    theFile.readAsLinesSync().forEach((line) {
      if (isLineImport(line)) {
        var absoluteImport = updateImportToAbsoluteIfNeeded(line, theFile.path);
        if (!isImportOfFileToBeDeleted(absoluteImport, filesToObfuscate)) {
          allImports.add(absoluteImport);
        }
      } else if (!isLinePart(line) && !isLineComment(line)) {
        nonImportLines.add(line);
      }
    });
  });

  final allLines = (allImports.toList() + nonImportLines).reduce((value, element) => value + "$element\n");
  return allLines;
}

//region imports
bool isImportOfFileToBeDeleted(String absoluteImport, List<File> filesToObfuscate) {
  final knownPaths = filesToObfuscate.map((e) => e.path.split('/lib/').last);
  final strippedImport = absoluteImport.replaceAll(RegExp("^(.*?)/"), '').split("'").first;
  return knownPaths.contains(strippedImport);
}

String updateImportToAbsoluteIfNeeded(String line, String sourceFilePath) {
  if (isLineRelativeImport(line)) {
    final relativePath = sourceFilePath.replaceAll(basename(sourceFilePath), "").split("/lib/").last;
    final newLine = line.replaceAll("import '", "import 'package:$packageName/$relativePath");
    // print("Replace relative $line\nto: $newLine");
    return newLine;
  } else {
    return line;
  }
}

/// Receives import or export line and returns cleared path.
String clearImportSymbols(String line) {
  if (isLineImport(line)) {
    return line.replaceAll('import \'', '').replaceAll("\'", "").replaceAll('\;', "");
  } else if (isLineExport(line)) {
    var clear = line.replaceAll('export \'', '').replaceAll("\'", "").replaceAll('\;', "");
    return clear;
  } else {
    throw "This is neither import nor export line";
  }
}

void updateImportsInNonObfuscatedFiles(Structure structure, String outputFileName) {
  structure.rawFiles.forEach((file) {
    final lines = file.readAsLinesSync();

    final outputFileImport = "import 'package:$packageName/$outputFileName';";
    var updatedLines =
        lines.where((element) => !isLineImport(element) || !isImportOfFileToBeDeleted(element, structure.filesToObfuscate)).toList();
    if (updatedLines.length < lines.length) {
      updatedLines = ["$outputFileImport"] + updatedLines;
    }

    var outputFilePath = basename(file.path);
    if (logLevel == LogLevel.VERBOSE) print("Update ${lines.length - updatedLines.length} imports for file: ${outputFilePath}");
    file.writeAsStringSync(updatedLines.reduce((value, element) => "$value\n$element"));
  });
}

//endregion

List<File> findFilesToObfuscate(Directory libDir, List<FileSystemEntity> rawFiles) {
  return libDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((element) => element.path.split(".").last == "dart")
      .where((element) => !rawFiles.map((e) => e.path).contains(element.path))
      .toList();
}

List<File> findExportedFiles(List<FileSystemEntity> rootFiles) {
  List<File> allExportedFiles = [];

  if (logLevel == LogLevel.VERBOSE) print("Root files found:");
  rootFiles.forEach((element) {
    if (logLevel == LogLevel.VERBOSE) print("${element.path}");
    if (logLevel == LogLevel.VERBOSE) print("Export files declared in this root:");
    final exportFiles = checkExports(element);
    if (logLevel == LogLevel.VERBOSE) {
      exportFiles.forEach((element) {
        print("${element.path}");
      });
    }
    allExportedFiles.addAll(exportFiles);
  });

  return allExportedFiles;
}

/// Reads `export` and returns list of files under it
List<File> checkExports(File file) {
  final List<File> exportFiles = [];
  file.readAsLinesSync().forEach((line) {
    if (line.startsWith("export ")) {
      final relativePath = clearImportSymbols(line);
      final absolutePath = "${file.parent.path}/$relativePath";
      var exportFile = File(absolutePath);
      if (exportFile.existsSync()) {
        exportFiles.add(exportFile);
      } else {
        print(
            "[WARNING] Export file does not exist: $absolutePath\nPlease make sure your project is compiling before proceeding"); //todo shall I exit with error here?
      }
    }
  });

  return exportFiles;
}

bool isLineComment(String line) => line.startsWith("//");

bool isLinePart(String line) => line.startsWith("part ");

bool isLineExport(String line) => line.startsWith('export ');

bool isLineImport(String line) => line.startsWith('import ');

bool isLineRelativeImport(String line) => isLineImport(line) && !line.contains("'package:") && !line.startsWith("import 'dart:");

//todo what if there's not enough mappings?
/// Generates mappings that later will
List<String> generateMappingsList() {
  final mappingSymbols = List<String>();
  final alphabet = List<String>();
  var letterCode = 'A'.codeUnitAt(0);
  for (var i = 0; i < (26 * 2); i++) {
    if (i == 26) {
      letterCode += 6; //skip symbols in between Upper case letters and lower case letters
    }
    alphabet.add(String.fromCharCode(letterCode++));
    // print("$i ${String.fromCharCode(letter++)} ");
  }

  alphabet.forEach((letterOne) {
    alphabet.forEach((letterTwo) {
      // print("$letterOne$letterTwo");
      mappingSymbols.add("$letterOne$letterTwo");
    });
  });

  // print("And we have ${mappingSymbols.length} mappings");
  return mappingSymbols;
}

/// Delete files that are scrabbed and code from which will be written to single file and obfuscated
void deleteScrappedSourceFiles(List<File> filesToObfuscate) {
  filesToObfuscate.forEach((element) {
    if (element.existsSync()) {
      element.deleteSync();
    }
  });
}

void writeToOutput(String text) {
  final outputFile = File("${libDir.path}/$outputFileName");

  if (outputFile.existsSync()) outputFile.deleteSync();
  outputFile.createSync();
  outputFile.writeAsStringSync(text);
}
