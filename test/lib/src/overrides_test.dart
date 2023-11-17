import 'package:test/test.dart';

import 'common.dart';

void main() {
  group('overrides', () {
    test('all', () async {
      await runTest('overrides.dart', 'overrides_result.dart');
    });
  });
}
