library test.generate;

import 'dart:async';
import 'dart:io';
import 'package:unittest/unittest.dart';
import 'package:bot_io/bot_io.dart';
import "package:discovery_api_client_generator/generator.dart";

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

    test('validate library', _testSingleLibraryGeneration);
  });
}

Future _testSingleLibraryGeneration() {
  TempDir tmpDir;

  const libName = 'discovery';
  const libVer = 'v1';

  return TempDir.create()
      .then((value) {
        tmpDir = value;

        return generateLibrary(libName, libVer, tmpDir.path);
      })
      .then((bool success) {
        expect(success, isTrue);

        var expectedMap = _createLibValidate(libName, libVer);

        return IoHelpers.verifyContents(tmpDir.dir, expectedMap);
      })
      .then((bool validates) {
        expect(validates, isTrue);
      })
      .whenComplete(() {
        if(tmpDir != null) {
          return tmpDir.dispose();
        }
      });
}

Map _createLibValidate(String libName, String libVersion) {
  final rootDir = 'dart_${libName}_${libVersion}_api_client';

  var expectedMap = {};
  expectedMap[rootDir] = new EntityExistsValidator(FileSystemEntityType.DIRECTORY);

  return expectedMap;
}

final Matcher _hasUsageInStdOut = predicate((ProcessResult pr) => pr.stdout.contains("""Usage:
   generate.dart"""));

Future<ProcessResult> _runGenerate(Iterable<String> args) {

  var theArgs = ['--checked', './bin/generate.dart']
    ..addAll(args);

  return Process.run('dart', theArgs);
}
