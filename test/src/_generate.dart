library test.generate;

import 'dart:async';
import 'dart:io';
import 'package:unittest/unittest.dart';
import 'package:bot_io/bot_io.dart';
import 'package:path/path.dart' as pathos;
import 'package:discovery_api_client_generator/generator.dart';

const _testLibName = 'discovery';
const _testLibVer = 'v1';

Function _testWithTempDir(Future func(TempDir dir)) {
  return () {
    TempDir tmpDir;

    return TempDir.create()
        .then((value) {
          tmpDir = value;

          return func(tmpDir);
        })
        .whenComplete(() {
          if(tmpDir != null) {
            tmpDir.dispose();
          }
        });
  };
}

void main() {
  group('generate', () {
    test('no args', () {
      return _runGenerate([])
          .then((ProcessResult pr) {
            expect(pr.exitCode, 1);
            expect(pr.stdout, startsWith('Missing arguments'));
            expect(pr, _hasUsageInStdOut);
          });
    });

    test('help', () {
      return _runGenerate(['--help'])
          .then((ProcessResult pr) {
            expect(pr.exitCode, 0);
            expect(pr, _hasUsageInStdOut);
          });
    });

    test('generate library via API and analyze', _testWithTempDir(_testSingleLibraryGeneration));

    test('generate library via CLI', _testWithTempDir(_testSingleLibraryGenerationViaCLI));

    test('"rest" args should throw', _testWithTempDir((tmpDir) {
      return _runGenerate(['--api', _testLibName, '-v', _testLibVer, '-o', tmpDir.path, 'silly_extra_arg'])
          .then((ProcessResult pr) {
            expect(pr.exitCode, 1);
            expect(pr, _hasUsageInStdOut);
          });
    }));

    test('missing output directory should throw', _testWithTempDir((tmpDir) {
        return _runGenerate(['--api', _testLibName, '-v', _testLibVer])
          .then((ProcessResult pr) {
            expect(pr.exitCode, 1);
            expect(pr, _hasUsageInStdOut);
          });
    }));
  });
}

Future _testSingleLibraryGeneration(TempDir tmpDir) {
  return generateLibrary(_testLibName, _testLibVer, tmpDir.path)
      .then((bool success) {
        expect(success, isTrue);

        return _validateDirectory(tmpDir.path, _testLibName, _testLibVer);
      })
      .then((_) => _analyzePackage(tmpDir.path, _testLibName, _testLibVer));
}

Future _testSingleLibraryGenerationViaCLI(TempDir tmpDir) {
  return _runGenerate(['--api', _testLibName, '-v', _testLibVer, '-o', tmpDir.path])
      .then((ProcessResult pr) {
        expect(pr.exitCode, 0);

        return _validateDirectory(tmpDir.path, _testLibName, _testLibVer);
      });
}

Future _validateDirectory(String packageDir, String libName, String libVer) {
  var libraryPaths = _getLibraryPaths(packageDir, libName, libVer);

  expect(libraryPaths, hasLength(6));

  return _validateFilesExist(libraryPaths);
}

Future _validateFilesExist(List<String> files) {
  return Future.forEach(files, (filePath) {
    var file = new File(filePath);
    return file.exists()
        .then((bool exists) {
          expect(exists, isTrue, reason: '$filePath should exist');
        });
  });
}

List<String> _getLibraryPaths(String rootDir, String libName, String libVersion) {
  final name = '${libName}_${libVersion}_api';
  final libDir = 'dart_${name}_client/lib';

  var files = [];

  files.addAll(['', '_browser', '_console']
    .map((k) => 'src/cloud_api${k}.dart'));

  files.addAll(['console', 'browser', 'client']
    .map((k) => '${name}_${k}.dart'));

  return files
      .map((f) => pathos.join(rootDir, libDir, f))
      .toList(growable: false);
}

final Matcher _hasUsageInStdOut = predicate((ProcessResult pr) => pr.stdout.contains("""Usage:
   generate.dart"""));

Future<ProcessResult> _runGenerate(Iterable<String> args) {

  var theArgs = ['--checked', './bin/generate.dart']
    ..addAll(args);

  return Process.run('dart', theArgs);
}

Future _analyzePackage(String rootDir, String libName, String libVer) {

  var libraryPaths = _getLibraryPaths(rootDir, libName, libVer);

  expect(libraryPaths, hasLength(6));

  final packageDir = pathos.join(rootDir, 'dart_${libName}_${libVer}_api_client');

  logMessage('installing packages at $packageDir');

  return Process.run('pub', ['install'], workingDirectory: packageDir)
      .then((ProcessResult pr) {
        logMessage('pub install worked');

        final packagesDir = pathos.join(packageDir, 'packages');

        return Future.forEach(libraryPaths, (path) {
          return _analyzeLib(packagesDir, path);
        });
      });
}

Future _analyzeLib(String packageDir, String libPath) {
  logMessage('analyzing $libPath');

  var args = ['--package-root', packageDir, libPath];

  return Process.run('dartanalyzer', args)
      .then((ProcessResult pr) {
        expect(pr.exitCode, 0);
        logMessage('analyze completed');
      });
}
