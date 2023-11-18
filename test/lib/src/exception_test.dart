import 'package:test/test.dart';

import 'common.dart';

void main() {
  group('exception', () {
    test('all', () async {
      await runTest('exception.dart', 'exception_result.dart');
    });
  });
}
