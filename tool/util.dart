library discovery_api_client_generator.util;

import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as pathos;
import 'package:bot_io/bot_io.dart';
import 'package:hop/hop.dart';

import "package:discovery_api_client_generator/generator.dart";

dynamic generateAnalyzeAll(TaskContext ctx) {
  return TempDir.then((Directory dir) {
    return generateAllLibraries(dir.path)
        .then((List<GenerateResult> results) {
          return _analyzeGeneratedResults(ctx, dir.path, results);
        });
  });
}

Future<bool> _analyzeGeneratedResults(TaskContext ctx, String rootPath, List<GenerateResult> results) {
  return Future.forEach(results, (GenerateResult result) {

    return analyzePackage(rootPath, result.shortName, true);

  })
  .then((_) => true);
}

List<String> getLibraryPaths(String rootDir, String shortName) {
  final libDir = 'dart_${shortName}_client/lib';

  var files = [];

  files.add('src/client_base.dart');

  files.addAll(['browser', 'console']
    .map((k) => 'src/${k}_client.dart'));

  files.addAll(['console', 'browser', 'client']
    .map((k) => '${shortName}_${k}.dart'));

  return files
      .map((f) => pathos.join(rootDir, libDir, f))
      .toList(growable: false);
}

Future analyzePackage(String rootDir, String shortName,
                      bool continueOnFail) {
  var libraryPaths = getLibraryPaths(rootDir, shortName);

  assert(libraryPaths.length == 6);

  final packageDir = pathos.join(rootDir, 'dart_${shortName}_client');

  _logMessage('installing packages at $packageDir');

  return Process.run('pub', ['--trace', 'install'], workingDirectory: packageDir)
      .then((ProcessResult pr) {
        if(pr.exitCode != 0) {
          throw new Exception('''Pub install failed.
$packageDir
${pr.stdout}
${pr.stderr}''');
        }
        _logMessage('pub install worked');

        final packagesDir = pathos.join(packageDir, 'packages');

        return Future.forEach(libraryPaths, (path) =>
            _analyzeLib(packagesDir, path, continueOnFail));
      });
}

Future _analyzeLib(String packageDir, String libPath,
    bool continueOnFail) {

  var args = ['--verbose', '--package-root', packageDir, libPath];

  return Process.run('dartanalyzer', args)
      .then((ProcessResult pr) {
        _logMessage(pr.stdout);
        _logMessage(pr.stderr);

        var success = pr.exitCode == 0;

        if(success) {
          _logMessage('analyze succeeded for $libPath');
        } else {
          var message = 'Analysis failed for $libPath';
          if(continueOnFail) {
            _logMessage(message);
          } else {
            throw new Exception(message);
          }
        }
      });
}

void _logMessage(String msg) {
  //TODO: really use logging?
  //print(msg);
}
