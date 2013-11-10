library generator.test;

import 'package:unittest/unittest.dart' as unittest;
import 'package:unittest/vm_config.dart';

import 'src/_generate.dart' as generate;

main() {
  testCore(new VMConfiguration());
}

void testCore(unittest.Configuration config) {
  unittest.unittestConfiguration = config;
  unittest.groupSep = ' - ';

  generate.main();
}
