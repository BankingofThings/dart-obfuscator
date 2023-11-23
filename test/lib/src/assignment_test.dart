import 'package:test/test.dart';

import 'common.dart';

void main() {
  group('assignment', () {
    test('all', () async {
      await runTest('assignment.dart', 'assignment_result.dart');
    });
  });
}
