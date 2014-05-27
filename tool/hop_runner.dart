library generator.hop;

import 'package:hop/hop.dart';
import 'package:hop/hop_tasks.dart';

import 'util.dart';
import '../test/harness_console.dart' as test_console;

void main(List<String> args) {
  addTask('test', createUnitTestTask(test_console.main,
      timeout: const Duration(seconds: 60)));

  //
  // Generate and analyze all libraries
  //
  addTask('generate_and_analyze', new Task(generateAnalyzeAll,
      description: 'Generate all apis. Run the analyzer against them.'));

  //
  // Analyzer
  //
  addTask('analyze',
          createAnalyzerTask(['bin/generate.dart', 'tool/util.dart']));

  runHop(args);
}
