


void a() {}

void b() {
  a();
}

int c() => 1;

int d() => c();

String e() {
  var f = 'hi';
  const g = 10;
  f = "$f + ${'' * g}";
  return f;
}

String h(int i) {
  return ' ' * i;
}

String j(int j) {
  return ' ' * j;
}

void k(void Function(String) l) {}