class ObfuscatorException implements Exception {
  ObfuscatorException(this.message);
  String message;
}

/// Thrown when we identify a problem with the projects layout.
class StructureException extends ObfuscatorException {
  StructureException(super.message);
}

class CodeFormatException extends ObfuscatorException {
  CodeFormatException(super.message);
}
