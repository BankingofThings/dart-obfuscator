import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:codemod_core/codemod_core.dart';

import 'obfuscated_project.dart';

typedef Replace = String Function(String existing);

/// Suggestor that renames a class
class Visitor extends GeneralizingAstVisitor<void> with AstVisitingSuggestor {
  Visitor(this.projectContext);

  ProjectContext projectContext;

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

    @override
  void visitAssignmentExpression(AssignmentExpression node) {
    final replacement = projectContext.replace(node.leftHandSide.lexeme);
    yieldPatch(replacement, node.name.offset, node.name.end);
    super.visitAssignmentExpression(node);
  }

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

  @override
  void visitComment(Comment node) {
    yieldPatch('', node.offset, node.end);
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
