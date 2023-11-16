import 'package:_fe_analyzer_shared/src/scanner/token.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:codemod_core/codemod_core.dart';

import 'comments.dart';
import 'obfuscated_project.dart';

typedef Replace = String Function(String existing);

/// Suggestor that renames a class
class Visitor extends GeneralizingAstVisitor<void> with AstVisitingSuggestor {
  Visitor(this.projectContext);

  ProjectContext projectContext;

  /// comments aren't fully supported as ast nodes so
  /// we need to process every node to find the associated
  /// comments.
  @override
  void visitNode(AstNode node) {
    final comments = checkForComment(node);
    for (final comment in comments) {
      if (comment.type.index == TokenType.MULTI_LINE_COMMENT.index) {
        /// we want to keep the line count consistent with the
        /// original text.
        final lines = comment.lexeme.split('\n').length - 1;
        final replacement = '\n' * lines;

        yieldPatch(replacement, comment.offset, comment.end);
      } else {
        yieldPatch('', comment.offset, comment.end);
      }
    }
  }

  //   @override
  // void visitComment(Comment node) {
  //   yieldPatch('' * node.length, node.offset, node.end);
  // }

  // The actual class declaration
  @override
  void visitClassDeclaration(ClassDeclaration node) {
    final replacement = projectContext.replace(node.name.lexeme);
    yieldPatch(replacement, node.name.offset, node.name.end);
    super.visitClassDeclaration(node);
  }

  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    final replacement = projectContext.replace(node.name.lexeme);
    yieldPatch(replacement, node.name.offset, node.name.end);
    super.visitVariableDeclaration(node);
  }

  /// assign a value to a variable.
  @override
  void visitAssignedVariablePattern(AssignedVariablePattern node) {
    final replacement = projectContext.replace(node.name.lexeme);
    yieldPatch(replacement, node.name.offset, node.name.end);
    super.visitAssignedVariablePattern(node);
  }

  //   @override
  // void visitAssignmentExpression(AssignmentExpression node) {
  //   final replacement = projectContext.replace(node.leftHandSide.lexeme);
  //   yieldPatch(replacement, node.name.offset, node.name.end);
  //   super.visitAssignmentExpression(node);
  // }

  // generic types
  @override
  void visitTypeArgumentList(TypeArgumentList node) {
    for (final argument in node.arguments) {
      if (!_isBuiltInType(argument.beginToken.lexeme)) {
        final replacement = projectContext.replace(argument.beginToken.lexeme);
        yieldPatch(replacement, argument.offset, argument.end);
      }
    }
    super.visitTypeArgumentList(node);
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    final replacement = projectContext.replace(node.name.lexeme);
    yieldPatch(replacement, node.name.offset, node.name.end);
    super.visitMethodDeclaration(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (_isProjectElement(node.methodName.staticElement)) {
      final replacement = projectContext.replace(node.methodName.name);
      yieldPatch(replacement, node.methodName.offset, node.methodName.end);
    }
    super.visitMethodInvocation(node);
  }

  /// Checks if the element belongs to this project or
  /// if it comes from a dependent package.
  bool _isProjectElement(Element? libraryElement) {
    if (libraryElement == null) {
      return false;
    }
    return projectContext.isLocalLibrary(libraryElement.source!.fullName);
  }

  bool _isBuiltInType(String typeName) =>
      ['int', 'double', 'String', 'bool'].contains(typeName);
}
