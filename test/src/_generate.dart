library test.generate;

import 'dart:async';
import 'dart:io';
import 'package:unittest/unittest.dart';
import 'package:bot_io/bot_io.dart';
import 'package:discovery_api_client_generator/generator.dart';

import '../../tool/util.dart';

const _testLibName = 'discovery';
const _testLibVer = 'v1';

String get _shortName => cleanName("${_testLibName}_${_testLibVer}_api").toLowerCase();

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

    test('generate library via API and analyze', () => TempDir.then(_testSingleLibraryGeneration));

    test('generate library via CLI', () => TempDir.then(_testSingleLibraryGenerationViaCLI));

    test('"rest" args should throw', () => TempDir.then((tmpDir) {
      return _runGenerate(['--api', _testLibName, '-v', _testLibVer, '-o', tmpDir.path, 'silly_extra_arg'])
          .then((ProcessResult pr) {
            expect(pr.exitCode, 1);
            expect(pr, _hasUsageInStdOut);
          });
    }));

    test('missing output directory should throw', () => TempDir.then((tmpDir) {
        return _runGenerate(['--api', _testLibName, '-v', _testLibVer])
          .then((ProcessResult pr) {
            expect(pr.exitCode, 1);
            expect(pr, _hasUsageInStdOut);
          });
    }));
  });
}

Future _testSingleLibraryGeneration(Directory tmpDir) {
  return generateLibrary(_testLibName, _testLibVer, tmpDir.path)
      .then((GenerateResult result) {
        expect(result.success, isTrue);

        return _validateDirectory(tmpDir.path, _shortName);
      })
      .then((_) => analyzePackage(tmpDir.path, _shortName, false));
}

Future _testSingleLibraryGenerationViaCLI(Directory tmpDir) {
  return _runGenerate(['--api', _testLibName, '-v', _testLibVer, '-o', tmpDir.path])
      .then((ProcessResult pr) {
        expect(pr.exitCode, 0);

        return _validateDirectory(tmpDir.path, _shortName);
      });
}

Future _validateDirectory(String packageDir, String shortName) {
  var libraryPaths = getLibraryPaths(packageDir, shortName);

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

final Matcher _hasUsageInStdOut = predicate((ProcessResult pr) => pr.stdout.contains("""Usage:
   generate.dart"""));

Future<ProcessResult> _runGenerate(Iterable<String> args) {

  var theArgs = ['--checked', './bin/generate.dart']
    ..addAll(args);

  return Process.run('dart', theArgs);
}
