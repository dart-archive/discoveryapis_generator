library generator.hop;

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
<<<<<<< HEAD
  addTask('analyze', createDartAnalyzerTask(['lib/generator.dart', 
                                             'bin/generate.dart',
                                             'tool/update.dart'
                                             ]));
  
  addTask('apidocs', createDartDocTask(_getLibs(), linkApi: true));
  
  runHop();
}

void _assertKnownPath() {
  // since there is no way to determine the path of 'this' file
  // assume that Directory.current() is the root of the project.
  // So check for existance of /bin/hop_runner.dart
  final thisFile = new File('tool/hop_runner.dart');
  assert(thisFile.existsSync());
}

Future<List<String>> _getLibs() {
  return new Directory('output/lib').list()
      .where((FileSystemEntity fse) => fse is File)
      .map((File file) => file.path)
      .toList();
}
=======
  addTask('analyze', createAnalyzerTask(
      [
       'lib/generator.dart',
       'lib/schemas.dart',
       'bin/generate.dart',
       'tool/update.dart']));
  runHop();
}
>>>>>>> cbd0cad2287fae0fb2260078fa261caf4060fc68
