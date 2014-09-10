library discovery_api_client_generator.util;

import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as pathos;

import "package:discovery_api_client_generator/generator.dart";

Future<AnalyzerResult> analyzePackage(String dir,
                                      List<GenerateResult> results) {
  Future runPub() {
    return Process.run('pub', ['--trace', 'install'], workingDirectory: dir)
        .then((ProcessResult process) {
       if(process.exitCode != 0) {
         throw new Exception('Pub install failed iniside $dir\n'
                            'stdout: ${process.stdout}\n'
                            'stderr: ${process.stderr}\n');
       }
    });
  }
  Future<AnalyzerResult> runAnalyzer(String packageDir, String libPath) {
    var args = ['--package-root', packageDir, libPath];
    return Process.run('dartanalyzer', args).then((ProcessResult process) {
      return new AnalyzerResult(
          libPath, process.stdout, process.stderr, process.exitCode == 0);
    });
  }

  var packagesDir = pathos.join(dir, 'packages');
  var libraryPaths = results.map((GenerateResult result) {
    return '$dir/lib/${result.apiName}/${result.apiVersion}.dart';
  });

  var analyzerResults = <AnalyzerResult>[];
  return runPub().then((_) {
    return Future.forEach(libraryPaths, (path) {
      return runAnalyzer(packagesDir, path).then(analyzerResults.add);
    }).then((_) {
      bool successfull = true;

      for (var result in analyzerResults) {
        if (!result.success) {
          successfull = false;
          print("Analyzer produced warning/serrors on ${result.file}:");
          print("${result.stdout}");
          print("${result.stderr}\n");
        }
      }

      return successfull;
    });
  });
}

class AnalyzerResult {
  final String file;
  final String stdout;
  final String stderr;
  final bool success;

  AnalyzerResult(this.file, this.stdout, this.stderr, this.success);
}
