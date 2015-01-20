#!/usr/bin/env dart
library generator.hop;

import 'dart:async';
import 'dart:io';

import 'package:hop/hop.dart';

void main(List<String> args) {
  var tests = findFiles('test');

  addTask('generator_tests', commandlineTasks(tests.map((test) {
    return commandRunner('dart', ['--checked', test]);
  }).toList()));

  addTask('generator_tests_analyze', commandlineTasks([
      commandRunner('dartanalyzer', tests)
  ]));

  addTask('generated_api_package', commandlineTasks([
      commandRunner('dart',
          ['--checked', 'bin/generate.dart', 'download', '-o', '.docs']),
      commandRunner('dart',
          ['--checked', 'bin/generate.dart', 'generate', '-i', '.docs',
           '-o', '.apipkg']),
     commandRunner('pub', ['get'], cwd: '.apipkg'),
     apisAnalyzerAndRunner('.apipkg/test', '.apipkg/packages'),
  ]));

  // We are running everything on drone.io.
  addChainedTask('test', ['generator_tests',
                          'generator_tests_analyze',
                          'generated_api_package']);

  runHop(args);
}

Task commandlineTasks(List commandRunners) {
  return new Task((TaskContext context) {
    return Future.forEach(commandRunners, (f) => f(context));
  });
}

Function apisAnalyzerAndRunner(String dir, String pkgRoot) {
  return (_) {
    List<String> testFiles = new Directory(dir)
        .listSync(recursive: true, followLinks: false)
        .where((fse) => fse is File)
        .where((fse) => fse.path.endsWith('.dart'))
        .map((fse) => fse.path)
        .toList();

    var args = ['--no-hints', '--package-root=$pkgRoot'];

    args.addAll(testFiles);

    return commandRunner('dartanalyzer', args)(_).then((_) {
      print("RUNNING: ${testFiles.length} tests now ");
      runTest(String test) {
        return new Future.sync(() => commandRunner('dart',
            ['--checked', '--package-root=$pkgRoot', test])(_));
      }
      return Future.forEach(testFiles, runTest);
    });
  };
}

Function commandRunner(String executable, List<String> arguments, {cwd}) {
  return (_) {
    var cmd = '$executable ${arguments.join(' ')}';
    if (cmd.length > 90) {
      cmd = cmd.substring(0, 90) + '...';
    }
    print("Running '$cmd'");
    return Process.run(executable, arguments, workingDirectory: cwd)
        .then((ProcessResult result) {
      print("   Done '$cmd'");

      var code = result.exitCode;
      if (code != 0) {
        throw new Exception("Running '$executable ${arguments.join(' ')}' "
                            "resulted in non-zero exit code (was: $code).\n"
                            "Stdout was:\n${result.stdout}\n"
                            "Stderr was:\n${result.stderr}\n");
      }
    });
  };
}

List<String> findFiles(String directory) {
  return new Directory(directory)
      .listSync(recursive: true, followLinks: false)
      .where((fse) => fse is File)
      .where((fse) => fse.path.endsWith('.dart'))
      .map((fse) => fse.path)
      .toList();
}
