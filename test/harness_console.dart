library generator.test;

import 'package:unittest/unittest.dart';
import 'package:unittest/vm_config.dart';

import 'src/_generate.dart' as generate;

main() {
  testCore(new VMConfiguration());
}

void testCore(Configuration config) {
  unittestConfiguration = config;
  groupSep = ' - ';

  generate.main();
}
