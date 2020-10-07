import 'dart:io';

import 'package:dart_obfuscator/log_level.dart';
import 'package:path/path.dart';

// 1. Move file to output
// 2. keep all the package imports in the file
// 3. update all relative imports in the file
// 4. In other files update all references to moved file

final logLevel = LogLevel.DEBUG;
// final logLevel = LogLevel.VERBOSE;
final obfuscationMap = Map<String, String>();
final packageName = 'finn_dart_sdk';

void main(List<String> args) async {
  final sourceDirPath = "/Users/denisvolyntsev/dev/Finn/Dart-Mobile-SDK";
  final outputFileName = "finn_obfuscated.dart";
  final libDir = Directory("$sourceDirPath/lib");

  if (!libDir.existsSync()) {
    throw "Directory $sourceDirPath does not exists or does not contain /lib dir";
  }

  final rootFiles = libDir.listSync(recursive: false).where((element) => element is File).toList();
  final exportedFiles = findExportedFiles(rootFiles);
  final rawFiles = rootFiles + exportedFiles;

  if (logLevel == LogLevel.VERBOSE) print("Files to obfuscate");
  List<File> filesToObfuscate = findFilesToObfuscate(libDir, rawFiles);
  filesToObfuscate.forEach((element) {
    if (logLevel == LogLevel.VERBOSE) print("${element.path}");
  });

  final outputFile = File("${libDir.path}/$outputFileName");
  outputFile.createSync();

  var theFile = filesToObfuscate[0];
  final updatedFileContent = updateImportsToAbsolute(libDir, theFile);
  // 2. keep all the package imports in the file
// 3. update all relative imports in the file
  // 1. Move file to output and delete original file
  outputFile.writeAsStringSync(updatedFileContent);
  // theFile.delete(recursive: false);

// 4. In other files update all references to moved file
}

String updateImportsToAbsolute(Directory libDir, File theFile) {
  var thePath = theFile.path;
  thePath = thePath.replaceAll(basename(thePath), "");
  // print(theFile.readAsLinesSync());
  final updatedLines = theFile.readAsLinesSync().map((line) {
    if (isLineRelativeImport(line)) {
      final relativePath = thePath.split("/lib/").last;
      final newLine = line.replaceAll("import '", "import 'package:$packageName/$relativePath");

      print("Replace relative import:\n$line\nto:\n$newLine");
      return newLine;
    } else {
      return line;
    }
  }).toList();
  // print("updatedLines:\n$updatedLines");
  return updatedLines.reduce((value, element) => value + "$element\n");
}

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

bool isLineExport(String line) => line.startsWith('export ');

bool isLineImport(String line) => line.startsWith('import ');

bool isLineRelativeImport(String line) => isLineImport(line) && !line.contains("'package:") && !line.startsWith("import 'dart:");
