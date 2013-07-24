library generator.hop;

import 'dart:async';
import 'package:hop/hop.dart';
import 'package:hop/hop_tasks.dart';

import 'util.dart';

import '../test/harness_console.dart' as test_console;

void main() {

  addTask('test', createUnitTestTask(test_console.testCore));

  addTask('docs', createDartDocTask(
      ['lib/generator.dart', 'lib/schemas.dart'],
      linkApi: true));

  //
  // Generate and analyze all libraries
  //
  addTask('generate_and_analyze', new Task.async(generateAnalyzeAll,
      description: 'Generate all of the apis and run the analyzer against them'));

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
