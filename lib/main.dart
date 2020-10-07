import 'dart:io';

import 'package:dart_obfuscator/log_level.dart';

// 1. Read file structure
// 2. Define exported files that should not be modified
// 3. Define files that should be modified

// final logLevel = LogLevel.DEBUG;
final logLevel = LogLevel.VERBOSE;

void main(List<String> args) async {
  final sourceDirPath = "/Users/denisvolyntsev/dev/Finn/Dart-Mobile-SDK";
  final libDir = Directory("$sourceDirPath/lib");

  if (!libDir.existsSync()) {
    throw "Directory $sourceDirPath does not exists or does not contain /lib dir";
  }

  final rootFiles = libDir.listSync(recursive: false).where((element) => element is File).toList();
  final exportedFiles = findExportedFiles(rootFiles);
  final rawFiles = rootFiles + exportedFiles;

  if (logLevel == LogLevel.VERBOSE) print("Files to obfuscate");
  List filesToObfuscate = findFilesToObfuscate(libDir, rawFiles);
  filesToObfuscate.forEach((element) {
    if (logLevel == LogLevel.VERBOSE) print("${element.path}");
  });

}

List<File> findFilesToObfuscate(Directory libDir, List<FileSystemEntity> rawFiles) {
  return libDir.listSync(recursive: true)
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
  if (line.startsWith('import ')) {
    return line.replaceAll('import \'', '').replaceAll("\'", "").replaceAll('\;', "");
  } else if (line.startsWith('export ')) {
    var clear = line.replaceAll('export \'', '').replaceAll("\'", "").replaceAll('\;', "");
    return clear;
  } else {
    throw "This is neither import nor export line";
  }
}
