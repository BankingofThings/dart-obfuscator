// ignore_for_file: implementation_imports
// ignore: depend_on_referenced_packages
import 'package:_fe_analyzer_shared/src/scanner/token.dart';
import 'package:analyzer/dart/ast/ast.dart';

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

  final tokensIncludingComments = associatedTokens.expand((element) sync* {
    yield element;
    final comment = element.precedingComments;
    if (comment != null) {
      yield* comment.selfAndAllNextTokens();
    }
  }).toSet();

  final comments = tokensIncludingComments.whereType<CommentToken>().toSet();

  return comments;
}
