import 'package:dcli/dcli.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

final pathToInputLib = join('test', 'fixtures', 'input', 'lib');
final pathToOutputLib = join('test', 'fixtures', 'output', 'lib');

void compareFiles(String pathToActual, String pathToExpected) {
  expect(read(pathToActual).toParagraph(), read(pathToExpected).toParagraph());
}
