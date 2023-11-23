import 'package:dcli/dcli.dart' as dcli;

void test() {
  dcli.cat('some/path');
}

dcli.Env environment() => dcli.env;
