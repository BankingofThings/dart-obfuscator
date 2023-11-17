// ignore_for_file: prefer_expression_function_bodies
// ignore_for_file:  join_return_with_assignment

void simple() {}

void simple2() {
  simple();
}

int value() => 1;

int value2() => value();

String value3() {
  var str = 'hi';
  const i = 10;
  str = "$str + ${'' * i}";
  return str;
}

String value4(int count) {
  return ' ' * count;
}

String instance(int instance) {
  return ' ' * instance;
}
