import 'dart:io';

class Structure {

  final List<File> rawFiles;
  final List<File> filesToObfuscate;

  Structure(this.rawFiles, this.filesToObfuscate);
}
