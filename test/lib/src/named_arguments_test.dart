import 'package:test/test.dart';

import 'common.dart';

void main() {
  group('named_arguments', () {
    test('all', () async {
      await runTest('named_arguments.dart', 'named_arguments_result.dart');
    });
  });
}
