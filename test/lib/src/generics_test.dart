import 'package:test/test.dart';

import 'common.dart';

void main() {
  group('generics', () {
    test('all', () async {
      await runTest('generics.dart', 'generics_result.dart');
    });
  });
}
