class NameGenerator {
  static String nextLetter = 'a';
  static String currentBase = '';

  String next() {
    final generated = '$currentBase$nextLetter';

    if (nextLetter == 'z') {
      nextLetter = 'a';
      currentBase = generated;
    } else {
      nextLetter = String.fromCharCode(nextLetter.codeUnitAt(0) + 1);
    }
    return generated;
  }
}

class IdentifierNameGenerator {
  int _counter = 0;

  String next() {
    ++_counter;
    final identifierName = _generateIdentifier(_counter);
    return identifierName;
  }

  String _generateIdentifier(int index) {
    const base = 26; // Number of letters in the alphabet
    var identifierName = '';

    do {
      final remainder = index % base;
      identifierName =
          String.fromCharCode('a'.codeUnitAt(0) + remainder) + identifierName;
      index = (index ~/ base) - 1;
    } while (index >= 0);

    if (reservedWords.contains(identifierName)) {
      return next();
    }
    return identifierName;
  }

  static const reservedWords = [
    'abstract',
    'as',
    'assert',
    'async',
    'await',
    'base',
    'break',
    'case',
    'catch',
    'class',
    'const',
    'continue',
    'covariant',
    'default',
    'deferred',
    'do',
    'dynamic',
    'else',
    'enum',
    'export',
    'extends',
    'extension',
    'external',
    'factory',
    'false',
    'final',
    'final',
    'finally',
    'for',
    'function',
    'get',
    'hide',
    'if',
    'implements',
    'import',
    'in',
    'interface',
    'is',
    'late',
    'library',
    'mixin',
    'new',
    'null',
    'on',
    'operator',
    'part',
    'required',
    'rethrow',
    'return',
    'sealed',
    'set',
    'show',
    'static',
    'super',
    'switch',
    'sync',
    'this',
    'throw',
    'true',
    'try',
    'typedef',
    'var',
    'void',
    'when',
    'while',
    'with',
    'yield',
  ];
}
