import 'dart:math';

import 'package:dart_obfuscator/src/obfuscated_project.dart';
import 'package:dcli/dcli.dart';
import 'package:path/path.dart' hide equals;
import 'package:test/test.dart';

import 'project_context_mock.dart';

final pathToInputLib = truepath('test', 'fixtures', 'input', 'lib');
final pathToOutputLib = truepath('test', 'fixtures', 'output', 'lib');

void compareFiles(String pathToActual, String pathToExpected) {
  final actual = read(pathToActual).toList();
  final expected = read(pathToExpected).toList();

  final minlen = min(actual.length, expected.length);

  for (var i = 0; i < minlen; i++) {
    expect(actual[i], expected[i], reason: "line ${i + 1} didn't match");
  }

  expect(actual.length, equals(expected.length));
}

Future<void> runTest(String testSrcFilename, String resultsSrcFilename) async {
  final context = ProjectContextMock(pathToInputLib);

  await withTempDir((tempDir) async {
    final paths = <String>{join(pathToInputLib, testSrcFilename)};
    await ObfuscatedProject.obfuscateList(
        context: context,
        paths: paths,
        pathToSourceParent: pathToInputLib,
        pathToTargetParent: tempDir);

    compareFiles(join(tempDir, testSrcFilename),
        join(pathToOutputLib, resultsSrcFilename));
  });
}
