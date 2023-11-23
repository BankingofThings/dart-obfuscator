import 'package:strings/strings.dart';

import 'name_generator.dart';

class Replacer {
  factory Replacer() => _self;

  Replacer._internal();
  static final Replacer _self = Replacer._internal();
  final IdentifierNameGenerator _gen = IdentifierNameGenerator();

  final Map<String, String> _replacementMap = <String, String>{};

  Replacement replace(String existing) {
    Replacement replacement;

    final value = _replacementMap[existing];
    if (value == null) {
      replacement = _generateName(existing);

      /// The patching system doesn't like it if we replace
      /// a variable with the name 'a' with a variable of the
      /// same name.
      if (replacement.replacement == existing) {
        replacement = _generateName(existing);
      }
      _replacementMap[existing] = replacement.replacement;
    } else {
      replacement =
          Replacement(existing: existing, replacement: value, patch: true);
    }
    return replacement;
  }

  /// Generates a obfuscated name.
  /// We preserve private vars by retaining the _
  /// and we preserve capitialise first letters so
  /// that class names still look like class names.
  /// TODO: is this a good idea since we are trying to obfuscate the code?
  Replacement _generateName(String existing) {
    if (existing.isEmpty) {
      return Replacement(
          existing: existing, replacement: existing, patch: false);
    }
    var prefix = '';

    var useUpper = false;

    /// retain the private nature of declarations
    if (existing.startsWith('_')) {
      prefix = '_';
      if (existing.length > 1) {
        useUpper = existing.substring(1, 2).isUpperCase();
      }
    } else {
      useUpper = existing.substring(0, 1).isUpperCase();
    }

    var name = _gen.next();

    /// If the existing name starts with a capital letter (e.g. a class name)
    /// then we preserve the upper case first letter.
    if (useUpper) {
      name = '${name.substring(0, 1).toUpperCase()}${name.substring(1)}';
    }

    return Replacement(
        existing: existing, replacement: '$prefix$name', patch: true);
  }
}

class Replacement {
  Replacement(
      {required this.existing, required this.replacement, required this.patch});
  String existing;
  String replacement;
  bool patch;
}


// class Replacement {
//   Replacement(this.replaced, this.replacement);
//   //TODO: will be redundent when we get to obfuscation as we always replace.
//   bool replaced;
//   String replacement;
// }
