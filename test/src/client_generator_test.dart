import 'dart:convert';

// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:discoveryapis_generator/clientstub_generator.dart';
import 'package:discoveryapis_generator/discoveryapis_generator.dart';
import 'package:discoveryapis_generator/src/dart_api_library.dart';
import 'package:discoveryapis_generator/src/utils.dart';
import 'package:path/path.dart' as path;
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
  var dataPath = path.join(findPackageRoot('.'), 'test', 'src', 'data');

  group('files', () {
    test('non-identical-messages', () {
      var inputPath = path.join(dataPath, 'rest');
      var outputDir = tmpDir.createTempSync();
      // Make sure there is a pubspec.yaml file in the directory.
      var pubspecFile = File(path.join(dataPath, 'pubspec.yaml'));
      pubspecFile.copySync(path.join(outputDir.path, 'pubspec.yaml'));
      // Generate the client stubs.
      var results = generateApiFiles(inputPath, outputDir.path);
      expect(results.length, 2);
      expect(results[0].success, isTrue);
      expect(results[1].info, isTrue);
      // The generated client stub file is named toyapi.dart.
      var stubFile = File(path.join(outputDir.path, 'toyapi.dart'));
      _expectFilesMatch(
        path.join(dataPath, 'expected_nonidentical.dartt'),
        stubFile.readAsStringSync(),
      );
    });

    test('identical-messages', () {
      var outputDir = tmpDir.createTempSync();
      // Make sure there is a pubspec.yaml file in the directory.
      var pubspecFile = File(path.join(dataPath, 'pubspec.yaml'));
      pubspecFile.copySync(path.join(outputDir.path, 'pubspec.yaml'));
      // Make sure we have a dart file with the message classes
      var libDir = Directory(path.join(outputDir.path, 'lib'))..createSync();
      var messageFile = File(path.join(dataPath, 'toyapi_messages.dartt'));
      // Copy message dart file and point messageFile to the copy.
      messageFile =
          messageFile.copySync(path.join(libDir.path, 'messages.dart'));
      // Build import map
      var importUri = path.toUri(messageFile.path);
      var importMap = {
        'ToyResponse': importUri.toString(),
        'ToyResourceResponse': importUri.toString(),
        'NestedResponse': importUri.toString(),
        'ToyMapResponse': importUri.toString(),
        'ToyRequest': importUri.toString(),
        'ToyAgeRequest': importUri.toString()
      };
      var description =
          File(path.join(dataPath, 'rest', 'toyapi.json')).readAsStringSync();
      var diPair = DescriptionImportPair(description, importMap);
      // Generate the client stubs.
      var results = generateClientStubs([diPair], outputDir.path);
      expect(results.length, 2);
      expect(results[0].success, isTrue);
      expect(results[1].info, isTrue);
      // The generated client stub file is named toyapi.dart.
      var stubFile = File(path.join(outputDir.path, 'toyapi.dart'));
      _expectFilesMatch(
        path.join(dataPath, 'expected_identical.dartt'),
        stubFile.readAsStringSync(),
      );
    });
  });

  group('features', () {
    test('dataWrapper', () {
      final descriptionJson =
          File(path.join(dataPath, 'wrapapi.json')).readAsStringSync();
      final description = RestDescription.fromJson(jsonDecode(descriptionJson));
      final generatedLib =
          DartApiLibrary.build(description, 'wrapapi', useCorePrefixes: true);

      _expectFilesMatch(
        path.join(dataPath, 'wrapapi.dartt'),
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
      _normalizeWhiteSpace(actualValue),
      _normalizeWhiteSpace(expectedStubFile.readAsStringSync()),
    );
  }
}

final RegExp _wsRegexp = RegExp(r'\s+');

String _normalizeWhiteSpace(String str) {
  return str.replaceAll(_wsRegexp, '');
}
