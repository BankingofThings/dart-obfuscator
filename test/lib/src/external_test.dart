import 'package:test/test.dart';

import 'common.dart';

void main() {
  group('external', () {
    test('all', () async {
      await runTest('external.dart', 'external_result.dart');
    });
  });
}
