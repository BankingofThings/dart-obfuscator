// ignore: implementation_imports
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
    super.visitNode(node);
  }
  // VariableDeclarationStatement
  // StringInterploation
  // InterpolationExpress

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    final libraryElement = node.staticElement;
    // if (libraryElement == null) {
    //   if (node.root is Element) {
    //     libraryElement = (node.root as Element).enclosingElement;
    //   } else if (node.root is CompilationUnit) {
    //     libraryElement = (node.root as CompilationUnit).declaredElement;
    //   }
    // }

    if (libraryElement == null || _isProjectElement(libraryElement)) {
      if (libraryElement != null) {
        if (libraryElement.kind == ElementKind.ENUM) {
          /// We don't obfuscate enums as they are often used in a DB.
          return;
        }
        if (libraryElement.enclosingElement!.kind == ElementKind.ENUM) {
          /// We don't obfuscate enums identifiers either as
          /// they are often used in a DB.
          return;
        }
      }

      final replacement = projectContext.replace(node.name);
      yieldPatch(replacement, node.offset, node.end);
    }

    super.visitSimpleIdentifier(node);
  }

  @override
  void visitConstructorDeclaration(ConstructorDeclaration node) {
    if (node.name != null) {
      final replacement = projectContext.replace(node.name!.lexeme);
      yieldPatch(replacement, node.name!.offset, node.name!.end);
    }

    super.visitConstructorDeclaration(node);
  }

  @override
  void visitCatchClauseParameter(CatchClauseParameter node) {
    final replacement = projectContext.replace(node.name.lexeme);
    yieldPatch(replacement, node.name.offset, node.name.end);

    super.visitCatchClauseParameter(node);
  }
  // @override
  // void visitReturnStatement(ReturnStatement node) {
  //   //final replacement = projectContext.replace(node.name);
  //   //  yieldPatch(replacement, node.offset, node.end);
  //   super.visitReturnStatement(node);
  // }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    final name = node.name.lexeme;

    /// main is an external refeference method so don't rename it.
    if (name != 'main') {
      final replacement = projectContext.replace(name);
      yieldPatch(replacement, node.name.offset, node.name.end);
    }

    super.visitFunctionDeclaration(node);
  }

  // @override
  // void visitFunctionExpression(FunctionExpression node) {
  //   final replacement = projectContext.replace(node.function.toString());
  //   yieldPatch(replacement, node.function.offset, node.function.end);

  //   super.visitFunctionReference(node);
  // }

  @override
  void visitFunctionReference(FunctionReference node) {
    final replacement = projectContext.replace(node.function.toString());
    yieldPatch(replacement, node.function.offset, node.function.end);

    super.visitFunctionReference(node);
  }

  // The actual class declaration
  @override
  void visitClassDeclaration(ClassDeclaration node) {
    final replacement = projectContext.replace(node.name.lexeme);
    yieldPatch(replacement, node.name.offset, node.name.end);

    // if (node.sup)
    super.visitClassDeclaration(node);
  }

  // The actual class declaration
  @override
  void visitDeclaredIdentifier(DeclaredIdentifier node) {
    final replacement = projectContext.replace(node.name.lexeme);
    yieldPatch(replacement, node.name.offset, node.name.end);

    super.visitDeclaredIdentifier(node);
  }

// For supertypes
  @override
  void visitNamedType(NamedType node) {
    if (_isProjectElement(node.element)) {
      final replacement = projectContext.replace(node.name2.lexeme);
      yieldPatch(replacement, node.name2.offset, node.name2.end);
    }
    super.visitNamedType(node);
  }

  // For generis class Mine<T>
  @override
  void visitTypeParameter(TypeParameter node) {
    if (_isProjectElement(node.declaredElement)) {
      final replacement = projectContext.replace(node.name.lexeme);
      yieldPatch(replacement, node.name.offset, node.name.end);
    }
    super.visitTypeParameter(node);
  }

  /// method/function args
  @override
  void visitSimpleFormalParameter(SimpleFormalParameter node) {
    if (_isProjectElement(node.declaredElement)) {
      final replacement = projectContext.replace(node.name!.lexeme);
      yieldPatch(replacement, node.name!.offset, node.name!.end);
    }
    super.visitSimpleFormalParameter(node);
  }

  @override
  void visitSuperFormalParameter(SuperFormalParameter node) {
    if (_isProjectElement(node.declaredElement)) {
      final replacement = projectContext.replace(node.name.lexeme);
      yieldPatch(replacement, node.name.offset, node.name.end);
    }
    super.visitSuperFormalParameter(node);
  }

  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    final replacement = projectContext.replace(node.name.lexeme);
    yieldPatch(replacement, node.name.offset, node.name.end);
    super.visitVariableDeclaration(node);
  }

  @override
  void visitFieldFormalParameter(FieldFormalParameter node) {
    final replacement = projectContext.replace(node.name.lexeme);
    yieldPatch(replacement, node.name.offset, node.name.end);
    super.visitFieldFormalParameter(node);
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
      if (!_isBuiltInType(argument.beginToken.lexeme) &&
          !externalType(argument as NamedType)) {
        final replacement = projectContext.replace(argument.beginToken.lexeme);
        yieldPatch(replacement, argument.offset, argument.end);
      }
    }
    super.visitTypeArgumentList(node);
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    if (shouldRenameMethod(node)) {
      final replacement = projectContext.replace(node.name.lexeme);
      yieldPatch(replacement, node.name.offset, node.name.end);
    }
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
      ['void', 'int', 'double', 'String', 'bool'].contains(typeName);

  /// Methods shouldn't be renamed for a number of reasons
  /// * override of external class
  bool shouldRenameMethod(MethodDeclaration node) {
    if (isOverride(node) && hasExternalSuperTypeWithMethod(node)) {
      return false;
    }

    return true;
  }

  bool isOverride(MethodDeclaration node) {
    for (final element in node.metadata) {
      if (element.name.name == 'override') {
        return true;
      }
    }
    return false;
  }

  /// We work our way up the class tree (which can have multiple parents)
  /// to see if one of them has the same method as [node]
  bool hasExternalSuperTypeWithMethod(MethodDeclaration node) {
    final enclosingClass =
        node.declaredElement!.enclosingElement as ClassElement;

    final methodName = node.name.lexeme;
    for (final superType in enclosingClass.allSupertypes) {
      for (final method in superType.methods) {
        //  final method = child as MethodDeclaration;
        if (method.name == methodName) {
          if (!_isProjectElement(superType.element)) {
            return true;
          }
        }
      }
    }
    return false;
  }

  /// Checks if the passed type is imported from an external package.
  bool externalType(NamedType node) {
    if (node.element != null) {
      final type = node.element! as TypeDefiningElement;
      return !_isProjectElement(type.library);
    }
    // TODO: we don't actually know!
    return false;
  }
}
