import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:dcli/dcli.dart';

Future<void> visitCommentsInFile(String filePath) async {
  final resourceProvider = PhysicalResourceProvider.INSTANCE;
  final analysisContextCollection = AnalysisContextCollection(
    includedPaths: [filePath],
    resourceProvider: resourceProvider,
  );

  for (final analysisContext in analysisContextCollection.contexts) {
    final analysisSession = analysisContext.currentSession;
    final result = await analysisSession.getResolvedLibrary(filePath)
        as ResolvedLibraryResult?;

    if (result != null) {
      // Iterate over the compilation unit and find comments
      for (final unit in result.units) {
        unit.unit.accept(_CommentVisitor());
      }
    }
  }
}

class _CommentVisitor extends RecursiveAstVisitor<void> {
  @override
  void visitComment(Comment node) {
    // Print the content of the comment
    print('Comment: $node');
  }
}

void main() async {
  // Replace 'path/to/your/file.dart' with the actual path to your Dart source file
  await visitCommentsInFile(truepath('test/fixtures/input/lib/comments.dart'));
}
