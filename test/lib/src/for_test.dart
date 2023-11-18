import 'package:test/test.dart';

import 'common.dart';

void main() {
  group('for', () {
    test('all', () async {
      await runTest('for.dart', 'for_result.dart');
    });
  });
}
