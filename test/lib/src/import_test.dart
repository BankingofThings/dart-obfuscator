import 'package:test/test.dart';

import 'common.dart';

void main() {
  group('import', () {
    test('all', () async {
      await runTest('import.dart', 'import_result.dart');
    });
  });
}
