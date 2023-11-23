import 'package:test/test.dart';

import 'common.dart';

void main() {
  group('class', () {
    test('all', () async {
      await runTest('typedef.dart', 'typedef_result.dart');
    });
  });
}
