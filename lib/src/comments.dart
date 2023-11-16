// ignore_for_file: implementation_imports
// ignore: depend_on_referenced_packages
import 'package:_fe_analyzer_shared/src/scanner/token.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

extension on Token {
  Iterable<Token> selfAndAllNextTokens() sync* {
    Token? token = this;
    while (token != null) {
      yield token;
      token = token.next;
    }
  }
}

// This class is the one that will analyze Dart files and return lints
Set<CommentToken> checkForComment(AstNode node) {
  final associatedTokens = <Token>{};

  final begin = node.beginToken;
  final end = node.endToken;
  associatedTokens
    ..addAll(begin.selfAndAllNextTokens().takeWhile((value) => value != end))
    ..add(end);

  print('All tokens in file: ${associatedTokens.length}');

  final tokensIncludingComments = associatedTokens.expand((element) sync* {
    yield element;
    final comment = element.precedingComments;
    if (comment != null) {
      yield* comment.selfAndAllNextTokens();
    }
  }).toSet();

  print('All tokens including comments: ${tokensIncludingComments.length}');

  final comments = tokensIncludingComments.whereType<CommentToken>().toSet();

  return comments;

  // print('Found ${comments.length} comments in ${library.source.shortName}');

  // for (final comment in comments) {
  //   final thirdChar = comment.lexeme.characters.skip(2).take(1);
  //   final fourthChar = comment.lexeme.characters.skip(3).take(1);
  //   if ((thirdChar.string == '/' && fourthChar.string == ' ') || thirdChar.string == ' ') {
  //     // Correct comment
  //   } else {
  //     yield Lint(
  //       code: 'comment_without_space',
  //       message: 'Comments should have a leading space',
  //       location: resolvedUnitResult.lintLocationFromOffset(comment.offset, length: 3),
  //     );
  //   }
  // }
}

class AnyAstNodeVisitor extends GeneralizingAstVisitor<void> {
  AnyAstNodeVisitor({
    required this.onVisitNode,
  });

  void Function(AstNode node) onVisitNode;

  @override
  void visitNode(AstNode node) {
    onVisitNode(node);
    super.visitNode(node);
  }
}
