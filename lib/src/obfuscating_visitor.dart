// ignore: implementation_imports
import 'package:_fe_analyzer_shared/src/scanner/token.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:codemod_core/codemod_core.dart';

import '../lib/src/comments.dart';
import 'project_context.dart';
import 'replacer.dart';

typedef Replace = String Function(String existing);

/// Suggestor that renames a class
class ObfuscatingVisitor extends GeneralizingAstVisitor<void>
    with AstVisitingSuggestor {
  ObfuscatingVisitor(this.projectContext);

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

        createPatch(
            Replacement(
                existing: comment.lexeme,
                replacement: replacement,
                patch: true),
            comment.offset,
            comment.end);
      } else {
        createPatch(
            Replacement(existing: comment.lexeme, replacement: '', patch: true),
            comment.offset,
            comment.end);
      }
    }
    super.visitNode(node);
  }

  Element? ifPrefixIdentifier(SimpleIdentifier node) {
    if (node.parent case final PrefixedIdentifier prefix) {
      return prefix.prefix.staticElement;
    }
    return null;
  }

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    var libraryElement = node.staticElement;

    if (libraryElement?.source == null) {
      libraryElement = null;
    }

    libraryElement ??= ifPrefixIdentifier(node);
    libraryElement ??= ifAssignment(node);
    libraryElement ??= ifMethodInvocation(node);

    // given most code is internal we set the default to true
    var obfuscate = true;
    if (libraryElement != null) {
      if (_isProjectElement(libraryElement)) {
        /// if node is a method invocation.
        final method = getMethodInvocation(node);
        if (method != null) {
          obfuscate = !shouldRenameMethodFromIdentifier(method);
        }

        if (_isEnum(libraryElement)) {
          obfuscate = false;
        }
      } else {
        obfuscate = false;
      }
    } else {
      logger.warning('libraryElement not found for: ${node.toSource()}');
    }

    if (obfuscate) {
      final name = node.name;
      if (name.isNotEmpty) {
        final replacement = projectContext.replace(name);

        createPatch(replacement, node.offset, node.end);
      }
    }

    super.visitSimpleIdentifier(node);
  }

  bool _isEnum(Element? element) {
    if (element == null) {
      /// we really don't know.
      return false;
    }
    if (element.kind == ElementKind.ENUM) {
      return true;
    }
    if (element.enclosingElement?.kind == ElementKind.ENUM) {
      return true;
    }
    return false;
  }

  @override
  void visitConstructorDeclaration(ConstructorDeclaration node) {
    if (node.name != null) {
      final replacement = projectContext.replace(node.name!.lexeme);
      createPatch(replacement, node.name!.offset, node.name!.end);
    }

    super.visitConstructorDeclaration(node);
  }

  @override
  void visitCatchClauseParameter(CatchClauseParameter node) {
    final replacement = projectContext.replace(node.name.lexeme);
    createPatch(replacement, node.name.offset, node.name.end);

    super.visitCatchClauseParameter(node);
  }
  // @override
  // void visitReturnStatement(ReturnStatement node) {
  //   //final replacement = projectContext.replace(node.name);
  //   //  createPatch(replacement, node.offset, node.end);
  //   super.visitReturnStatement(node);
  // }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    final name = node.name.lexeme;

    /// main is an external refeference method so don't rename it.
    if (name != 'main') {
      final replacement = projectContext.replace(name);
      createPatch(replacement, node.name.offset, node.name.end);
    }

    super.visitFunctionDeclaration(node);
  }

  // @override
  // void visitFunctionExpression(FunctionExpression node) {
  //   final replacement = projectContext.replace(node.function.toString());
  //   createPatch(replacement, node.function.offset, node.function.end);

  //   super.visitFunctionReference(node);
  // }

  @override
  void visitFunctionReference(FunctionReference node) {
    final replacement = projectContext.replace(node.function.toString());
    createPatch(replacement, node.function.offset, node.function.end);

    super.visitFunctionReference(node);
  }

  // The actual class declaration
  @override
  void visitClassDeclaration(ClassDeclaration node) {
    final replacement = projectContext.replace(node.name.lexeme);
    createPatch(replacement, node.name.offset, node.name.end);

    // if (node.sup)
    super.visitClassDeclaration(node);
  }

  // The actual class declaration
  @override
  void visitDeclaredIdentifier(DeclaredIdentifier node) {
    final replacement = projectContext.replace(node.name.lexeme);
    createPatch(replacement, node.name.offset, node.name.end);

    super.visitDeclaredIdentifier(node);
  }

// For supertypes
  @override
  void visitNamedType(NamedType node) {
    // We don't rename built-in types.
    if (!_isBuiltInType(node.name2.lexeme)) {
      if (_isProjectElement(node.element)) {
        if (!_isEnum(node.element)) {
          final replacement = projectContext.replace(node.name2.lexeme);
          createPatch(replacement, node.name2.offset, node.name2.end);
        }
      }
    }
    super.visitNamedType(node);
  }

  // For generis class Mine<T>
  @override
  void visitTypeParameter(TypeParameter node) {
    if (_isProjectElement(node.declaredElement)) {
      final replacement = projectContext.replace(node.name.lexeme);
      createPatch(replacement, node.name.offset, node.name.end);
    }
    super.visitTypeParameter(node);
  }

  /// method/function args
  @override
  void visitSimpleFormalParameter(SimpleFormalParameter node) {
    /// Function types don't have parameter names
    /// e.g.
    /// void Function(String)
    if (node.name != null) {
      if (_isProjectElement(node.declaredElement)) {
        if (!_isEnum(node.declaredElement)) {
          final replacement = projectContext.replace(node.name!.lexeme);
          createPatch(replacement, node.name!.offset, node.name!.end);
        }
      }
    }
    super.visitSimpleFormalParameter(node);
  }

  @override
  void visitSuperFormalParameter(SuperFormalParameter node) {
    if (_isProjectElement(node.declaredElement)) {
      final replacement = projectContext.replace(node.name.lexeme);
      createPatch(replacement, node.name.offset, node.name.end);
    }
    super.visitSuperFormalParameter(node);
  }

  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    final replacement = projectContext.replace(node.name.lexeme);
    createPatch(replacement, node.name.offset, node.name.end);
    super.visitVariableDeclaration(node);
  }

  @override
  void visitFieldFormalParameter(FieldFormalParameter node) {
    final replacement = projectContext.replace(node.name.lexeme);
    createPatch(replacement, node.name.offset, node.name.end);
    super.visitFieldFormalParameter(node);
  }

  /// assign a value to a variable.
  @override
  void visitAssignedVariablePattern(AssignedVariablePattern node) {
    final replacement = projectContext.replace(node.name.lexeme);
    createPatch(replacement, node.name.offset, node.name.end);
    super.visitAssignedVariablePattern(node);
  }

  // @override
  // void visitAssignmentExpression(AssignmentExpression node) {
  //   var lhs = node.leftHandSide;
  //   var rhs = node.rightHandSide;

  //   node.writeElement

  //   final replacement = projectContext.replace(lhs.staticParameterElement);
  //   createPatch(replacement, node.name.offset, node.name.end);
  //   super.visitAssignmentExpression(node);
  // }

  // generic types
  @override
  void visitTypeArgumentList(TypeArgumentList node) {
    for (final argument in node.arguments) {
      if (!_isBuiltInType(argument.beginToken.lexeme) &&
          !externalType(argument)) {
        final replacement = projectContext.replace(argument.beginToken.lexeme);
        createPatch(replacement, argument.offset, argument.end);
      }
    }
    super.visitTypeArgumentList(node);
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    if (shouldRenameMethod(node.name.lexeme, node.declaredElement!.metadata,
        node.declaredElement!.enclosingElement)) {
      final replacement = projectContext.replace(node.name.lexeme);
      createPatch(replacement, node.name.offset, node.name.end);
    }
    super.visitMethodDeclaration(node);
  }

  @override
  void visitImportPrefixReference(ImportPrefixReference node) {
    final replacement = projectContext.replace(node.name.lexeme);
    createPatch(replacement, node.name.offset, node.name.end);
    super.visitImportPrefixReference(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (_isProjectElement(node.methodName.staticElement)) {
      if (shouldRenameMethod(
          node.methodName.name,
          node.methodName.staticElement!.metadata,
          node.methodName.staticElement!.enclosingElement!)) {
        //         .map((annotation) => annotation.elementAnnotation)
        //         .toList())) {
        final replacement = projectContext.replace(node.methodName.name);
        createPatch(replacement, node.methodName.offset, node.methodName.end);
      }
    }
    super.visitMethodInvocation(node);
  }

  @override
  void visitGenericTypeAlias(GenericTypeAlias node) {
    /// a typedef which can only be a local
    final replacement = projectContext.replace(node.name.lexeme);
    createPatch(replacement, node.name.offset, node.name.end);
    super.visitGenericTypeAlias(node);
  }

  /// Checks if the element belongs to this project or
  /// if it comes from a dependent package.
  bool _isProjectElement(Element? libraryElement) {
    if (libraryElement == null) {
      return false;
    }
    if (libraryElement.source == null) {
      logger.warning(
          '''Assuming ${libraryElement.getDisplayString(withNullability: true)} is local as no source found''');
      return true;
    }

    return projectContext.isLocalLibrary(libraryElement.source!.fullName);
  }

  bool _isBuiltInType(String typeName) =>
      ['void', 'int', 'double', 'String', 'bool', 'dynamic'].contains(typeName);

  /// Methods shouldn't be renamed for a number of reasons
  /// * override of external class
  bool shouldRenameMethod(String methodName, List<ElementAnnotation> metadata,
      Element enclosingElement) {
    if (enclosingElement case final InterfaceElement interfaceElement) {
      if (isOverride(metadata) &&
          hasExternalSuperTypeWithMethod(methodName, interfaceElement)) {
        return false;
      }
    }

    return true;
  }

  bool shouldRenameMethodFromIdentifier(MethodInvocation method) =>
      !(isOverride(method.methodName.staticElement!.metadata) &&
          hasExternalSuperTypeWithMethod(
              method.methodName.name,
              method.methodName.staticElement!.enclosingElement!
                  as InterfaceElement));

  bool isOverride(List<ElementAnnotation?> metadata) {
    for (final element in metadata) {
      if (element == null) {
        continue;
      }
      if (element.isOverride) {
        return true;
      }
    }
    return false;
  }

  bool hasExternalSuperTypeWithMethod(
      String methodName, InterfaceElement enclosingElement) {
    final allSuperTypes = enclosingElement.allSupertypes;

    for (final superType in allSuperTypes) {
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
  bool externalType(TypeAnnotation node) {
    switch (node) {
      case (final NamedType named):
        final element = named.element;
        if (element != null) {
          final type = element as TypeDefiningElement;
          return !_isProjectElement(type.library);
        }
        logger.severe(
            '''Missing element for node: ${node.toSource()} ${node.parent?.toSource()}''');
        break;
      case (final GenericFunctionType generic):
        final library = generic.type?.element?.library;
        if (library == null) {
          logger.severe(
              '''Missing element type for node: ${node.toSource()} ${node.parent?.toSource()}''');
        } else {
          return !_isProjectElement(library);
        }

        break;
      case (final RecordTypeAnnotation record):
        final library = record.type?.element?.library;
        if (library == null) {
          logger.severe(
              '''Missing element type for node: ${node.toSource()} ${node.parent?.toSource()}''');
        } else {
          return !_isProjectElement(library);
        }
        break;
    }
    logger.warning(
        '''Assuming element is internal to the package: ${node.toSource()} ${node.parent?.toSource()}''');

    return false;
  }

  void createPatch(Replacement replacement, int offset, int end) {
    if (replacement.patch) {
      yieldPatch(replacement.replacement, offset, end);
    }
  }

  /// If [node] is part of an assignment then we return
  /// the library it belongs to.
  Element? ifAssignment(SimpleIdentifier node) {
    var parent = node.parent;
    while (parent != null) {
      if (parent case final AssignmentExpression assignment) {
        if (node == assignment.leftHandSide ||
            node.parent == assignment.leftHandSide) {
          return assignment.writeElement?.library;
        }
        // TODO: apparently readElement has nothing to do with rhs
        if (node.parent == assignment.rightHandSide) {
          return assignment.readElement?.library;
        }
      }
      parent = parent.parent;
    }
    return null;
  }

  Element? ifMethodInvocation(SimpleIdentifier node) {
    final element = getMethodInvocation(node);
    if (element != null) {
      return (element.function as SimpleIdentifier).staticElement;
    }
    return null;
  }

  /// If [node] represents a methodInvocation then we return
  /// a [MethodInvocation] otherwise null
  MethodInvocation? getMethodInvocation(SimpleIdentifier node) {
    var parent = node.parent;
    while (parent != null) {
      if (parent case final MethodInvocation method) {
        return method;
      }
      parent = parent.parent;
    }
    return null;
  }

  bool isMethodInvocation(SimpleIdentifier node) =>
      getMethodInvocation(node) != null;
}
