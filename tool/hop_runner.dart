#!/usr/bin/env dart

// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library generator.hop;

import 'dart:async';
import 'dart:io';

import 'package:hop/hop.dart';

void main(List<String> args) {
  var tests = findFiles('test');

  addTask('generate_example', commandlineTasks([
    commandRunner('dart', [
      'bin/generate.dart',
      'files',
      '--input-dir=example',
      '--output-dir=example',
      '--no-core-prefix'
    ])
  ]));

  addTask('generator_tests', commandlineTasks(tests.map((test) {
    return commandRunner('dart', ['--checked', test]);
  }).toList()));

  addTask('generator_tests_analyze', commandlineTasks([
      commandRunner('dartanalyzer', tests)
  ]));

  // We are running everything on drone.io.
  addChainedTask('test', ['generator_tests',
                          'generator_tests_analyze']);

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
