// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:discoveryapis_generator/clientstub_generator.dart';
import 'package:discoveryapis_generator/discoveryapis_generator.dart';
import 'package:discoveryapis_generator/src/utils.dart';
import 'package:path/path.dart' as path;
import 'package:unittest/unittest.dart';

class GeneratorTestConfiguration extends SimpleConfiguration {

  Directory tmpDir;

  GeneratorTestConfiguration(this.tmpDir);

  void onDone(bool success) {
    tmpDir.deleteSync(recursive: true);
    super.onDone(success);
  }
}

main() {
  // We create our own tmp dir to make it easy to cleanup once the tests are
  // done, independent of whether they failed or not.
  var tmpDir = Directory.systemTemp.createTempSync();
  print(tmpDir.path);
  unittestConfiguration = new GeneratorTestConfiguration(tmpDir);
  // Common path to the necessary test data.
  var dataPath = path.join(findPackageRoot('.'), 'test/src/data');

  group('files', () {
    test('non-identical-messages', () {
      var inputPath = path.join(dataPath, 'rest');
      var outputDir = tmpDir.createTempSync();
      // Make sure there is a pubspec.yaml file in the directory.
      var pubspecFile = new File(path.join(dataPath, 'pubspec.yaml'));
      pubspecFile.copySync(path.join(outputDir.path, 'pubspec.yaml'));
      // Generate the client stubs.
      var results = generateApiFiles(inputPath, outputDir.path);
      expect(results.length, 2);
      expect(results[0].success, isTrue);
      expect(results[1].info, isTrue);
      // The generated client stub file is named toyapi.dart.
      var stubFile = new File(path.join(outputDir.path, 'toyapi.dart'));
      var expectedStubFile =
          new File(path.join(dataPath, 'expected_nonidentical.dart'));
      expect(stubFile.readAsStringSync(), expectedStubFile.readAsStringSync());
    });
    test('identical-messages', () {
      var outputDir = tmpDir.createTempSync();
      // Make sure there is a pubspec.yaml file in the directory.
      var pubspecFile = new File(path.join(dataPath, 'pubspec.yaml'));
      pubspecFile.copySync(path.join(outputDir.path, 'pubspec.yaml'));
      // Make sure we have a dart file with the message classes
      var messageFile = new File(path.join(dataPath, 'toyapi_messages.dart'));
      var libDir = new Directory(path.join(outputDir.path, 'lib'))
          ..createSync();
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
          new File(path.join(dataPath, 'rest/toyapi.json')).readAsStringSync();
      var diPair = new DescriptionImportPair(description, importMap);
      // Generate the client stubs.
      var results = generateClientStubs([diPair], outputDir.path);
      expect(results.length, 2);
      expect(results[0].success, isTrue);
      expect(results[1].info, isTrue);
      // The generated client stub file is named toyapi.dart.
      var stubFile = new File(path.join(outputDir.path, 'toyapi.dart'));
      var expectedStubFile =
          new File(path.join(dataPath, 'expected_identical.dart'));
      expect(stubFile.readAsStringSync(), expectedStubFile.readAsStringSync());
    });
  });
}
