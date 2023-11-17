import 'package:test/test.dart';

import 'common.dart';

void main() {
  group('class', () {
    test('all', () async {
      await runTest('class.dart', 'class_result.dart');
    });
  });
}
