import 'package:test/test.dart';

import 'common.dart';

void main() {
  group('function', () {
    test('all', () async {
      await runTest('function.dart', 'function_result.dart');
    });
  });
}
