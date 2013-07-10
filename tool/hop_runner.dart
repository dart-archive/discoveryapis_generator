library generator.hop;

import 'package:hop/hop.dart';
import 'package:hop/hop_tasks.dart';

import '../test/harness_console.dart' as test_console;

void main() {

  addTask('test', createUnitTestTask(test_console.testCore));

  addTask('docs', createDartDocTask(
      ['lib/generator.dart', 'lib/schemas.dart'],
      linkApi: true));

  //
  // Analyzer
  //
  addTask('analyze', createAnalyzerTask(
      [
       'lib/generator.dart',
       'lib/schemas.dart',
       'bin/generate.dart',
       'tool/update.dart']));
  runHop();
}
