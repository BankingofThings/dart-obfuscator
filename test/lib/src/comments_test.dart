import 'package:dart_obfuscator/src/obfuscated_project.dart';
import 'package:dcli/dcli.dart';
import 'package:path/path.dart' hide equals;
import 'package:test/test.dart';

import 'common.dart';
import 'project_context_mock.dart';

void main() {
  group('comments', () {
    test('all', () async {
      final context = ProjectContextMock(pathToInputLib);

      await withTempDir((tempDir) async {
        final paths = <String>{join(pathToInputLib, 'comments.dart')};
        await ObfuscatedProject.obfuscateList(
            context: context,
            paths: paths,
            pathToSourceParent: pathToInputLib,
            pathToTargetParent: tempDir);

        compareFiles(join(tempDir, 'comments.dart'),
            join(pathToOutputLib, 'comments_result.dart'));
      });
    });
  });
}
