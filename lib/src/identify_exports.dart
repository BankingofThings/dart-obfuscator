import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:codemod_core/codemod_core.dart';

import 'project_context.dart';

/// Suggestor that renames a class
class IdentifyImportsVisitor extends GeneralizingAstVisitor<void>
    with AstVisitingSuggestor {
  IdentifyImportsVisitor(this.projectContext);

  /// We need a full resolves AST so that we can determine if
  /// identifiers are local to the project.
  @override
  bool shouldResolveAst(FileContext context) => true;

  ProjectContext projectContext;

  /// comments aren't fully supported as ast nodes so
  /// we need to process every node to find the associated
  /// comments.
  ///
  /// Debugging:
  /// Place a break point on this visitor to see every element
  /// that is visited.
  @override
  void visitNode(AstNode node) {
    /// Left here to help with debugging.
    /// Set a break point here to see every node being visited.
    super.visitNode(node);
  }

  final exported = <String>{};

  void run() {
    final collection = AnalysisContextCollection(
        includedPaths: projectContext.libraries.toList());

    // collection.
  }

  @override
  void visitExportDirective(ExportDirective node) {
    exported.add(node.uri.stringValue ?? '');

    node.visitChildren(this);
  }
}
