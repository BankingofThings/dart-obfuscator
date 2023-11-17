import 'package:dcli/dcli.dart';
import 'package:test/test.dart';

final pathToInputLib = truepath('test', 'fixtures', 'input', 'lib');
final pathToOutputLib = truepath('test', 'fixtures', 'output', 'lib');

void compareFiles(String pathToActual, String pathToExpected) {
  expect(read(pathToActual).toParagraph(), read(pathToExpected).toParagraph());
}
