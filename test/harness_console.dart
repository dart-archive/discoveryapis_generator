library generator.test;

import 'package:unittest/unittest.dart' as unittest;

import 'src/_generate.dart' as generate;

void main() {
  unittest.groupSep = ' - ';

  generate.main();
}
