library hop_runner;

import 'package:hop/hop.dart';
import 'package:hop/hop_tasks.dart';

void main() {

  addTask('docs', createDartDocTask(['lib/generator.dart'], linkApi: true));

  //
  // Analyzer
  //
  addTask('analyze', createAnalyzerTask(['lib/generator.dart',
                                             'bin/generate.dart',
                                             'tool/update.dart'
                                             ]));
  runHop();
}
