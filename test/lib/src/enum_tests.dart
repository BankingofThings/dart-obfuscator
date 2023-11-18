import 'package:test/test.dart';

import 'common.dart';

void main() {
  group('enum', () {
    test('all', () async {
      await runTest('enum.dart', 'enum_result.dart');
    });
  });
}
