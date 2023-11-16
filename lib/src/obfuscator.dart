import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:dcli/dcli.dart';

class Obfuscator {
  void run() {
    final dartLibraries = find('*.dart').toList();
    final collection = AnalysisContextCollection(includedPaths: dartLibraries);


    
  }
}
