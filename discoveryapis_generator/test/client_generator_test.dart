import 'dart:convert';

// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:discoveryapis_generator/clientstub_generator.dart';
import 'package:discoveryapis_generator/discoveryapis_generator.dart';
import 'package:discoveryapis_generator/src/dart_api_library.dart';
import 'package:discoveryapis_generator/src/utils.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  Directory tmpDir;

  setUpAll(() {
    tmpDir = Directory.systemTemp.createTempSync();
  });

  tearDownAll(() {
    tmpDir.deleteSync(recursive: true);
  });

  // Common path to the necessary test data.
  var dataPath = p.normalize(p.join(findPackageRoot('.'), '..', '_test'));

  group('files', () {
    test('non-identical-messages', () {
      var inputPath = p.join(dataPath, 'rest');
      var outputDir = tmpDir.createTempSync();
      // Make sure there is a pubspec.yaml file in the directory.
      var pubspecFile = File(p.join(dataPath, 'pubspec.yaml'));
      pubspecFile.copySync(p.join(outputDir.path, 'pubspec.yaml'));
      // Generate the client stubs.
      var results = generateApiFiles(inputPath, outputDir.path);
      expect(results.length, 2);
      expect(results[0].success, isTrue);
      expect(results[1].info, isTrue);
      // The generated client stub file is named toyapi.dart.
      var stubFile = File(p.join(outputDir.path, 'toyapi.dart'));
      _expectFilesMatch(
        p.join(dataPath, 'expected_nonidentical.dart'),
        stubFile.readAsStringSync(),
      );
    });

    test('identical-messages', () {
      var outputDir = tmpDir.createTempSync();
      // Make sure there is a pubspec.yaml file in the directory.
      var pubspecFile = File(p.join(dataPath, 'pubspec.yaml'));
      pubspecFile.copySync(p.join(outputDir.path, 'pubspec.yaml'));
      // Make sure we have a dart file with the message classes
      var libDir = Directory(p.join(outputDir.path, 'lib'))..createSync();
      var messageFile = File(p.join(libDir.path, 'messages.dart'));
      // Build import map
      var importUri = p.toUri(messageFile.path);
      var importMap = {
        'ToyResponse': importUri.toString(),
        'ToyResourceResponse': importUri.toString(),
        'NestedResponse': importUri.toString(),
        'ToyMapResponse': importUri.toString(),
        'ToyRequest': importUri.toString(),
        'ToyAgeRequest': importUri.toString()
      };
      var description =
          File(p.join(dataPath, 'rest', 'toyapi.json')).readAsStringSync();
      var diPair = DescriptionImportPair(description, importMap);
      // Generate the client stubs.
      var results = generateClientStubs([diPair], outputDir.path);
      expect(results.length, 2);
      expect(results[0].success, isTrue);
      expect(results[1].info, isTrue);
      // The generated client stub file is named toyapi.dart.
      var stubFile = File(p.join(outputDir.path, 'toyapi.dart'));
      _expectFilesMatch(
        p.join(dataPath, 'expected_identical.dart'),
        stubFile.readAsStringSync(),
      );
    });
  });

  group('features', () {
    test('dataWrapper', () {
      final descriptionJson =
          File(p.join(dataPath, 'wrapapi.json')).readAsStringSync();
      final description = RestDescription.fromJson(jsonDecode(descriptionJson));
      final generatedLib =
          DartApiLibrary.build(description, 'wrapapi', useCorePrefixes: true);

      _expectFilesMatch(
        p.join(dataPath, 'wrapapi.dart'),
        generatedLib.librarySource,
      );
    });
  });
}

void _expectFilesMatch(String expectedFilePath, String actualValue) {
  var expectedStubFile = File(expectedFilePath);
  if (!expectedStubFile.existsSync()) {
    expectedStubFile.create(recursive: true);
    expectedStubFile.writeAsStringSync(actualValue);
    fail('`$expectedFilePath` did not exist. Created!');
  } else {
    expect(
      actualValue,
      expectedStubFile.readAsStringSync(),
    );
  }
}
