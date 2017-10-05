// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library discoveryapis_generator;

import "dart:convert";
import "dart:io";

import 'src/apis_files_generator.dart';
import 'src/apis_package_generator.dart';
import 'src/generated_googleapis/discovery/v1.dart';
import 'src/utils.dart';

export 'src/generated_googleapis/discovery/v1.dart';
export 'src/utils.dart' show GenerateResult;

/**
 * Specification of the pubspec.yaml for a generated package.
 */
class Pubspec {
  final String name;
  final String version;
  final String description;
  final String author;
  final String homepage;

  Pubspec(this.name, this.version, this.description,
      {this.author, this.homepage});

  String get sdkConstraint => '>=1.22.0 <2.0.0';

  static Map<String, Object> get dependencies => const {
        'http': '\'>=0.11.1 <0.12.0\'',
        '_discoveryapis_commons': '\'>=0.1.0 <0.2.0\'',
      };

  static Map<String, Object> get devDependencies => const {
        'test': '\'>=0.12.0 <0.13.0\'',
      };
}

List<GenerateResult> generateApiPackage(List<RestDescription> descriptions,
    String outputDirectory, Pubspec pubspec) {
  var apisPackageGenerator =
      new ApisPackageGenerator(descriptions, pubspec, outputDirectory);

  return apisPackageGenerator.generateApiPackage();
}

List<GenerateResult> generateAllLibraries(
    String inputDirectory, String outputDirectory, Pubspec pubspec) {
  var apiDescriptions = new Directory(inputDirectory)
      .listSync()
      .where((fse) => fse is File && fse.path.endsWith('.json'))
      .map((FileSystemEntity entity) {
    return new RestDescription.fromJson(
        JSON.decode((entity as File).readAsStringSync()));
  }).toList();
  return generateApiPackage(apiDescriptions, outputDirectory, pubspec);
}

List<GenerateResult> generateApiFiles(
    String inputDirectory, String outputDirectory,
    {bool updatePubspec: false, bool useCorePrefixes: true}) {
  var descriptions = [];
  new Directory(inputDirectory)
      .listSync()
      .where((fse) => fse is File && fse.path.endsWith('.json'))
      .forEach((FileSystemEntity entity) {
    var diPair =
        new DescriptionImportPair((entity as File).readAsStringSync(), null);
    descriptions.add(diPair);
  });
  var clientFileGenerator = new ApisFilesGenerator(
      descriptions, outputDirectory,
      updatePubspec: updatePubspec, useCorePrefixes: useCorePrefixes);
  return clientFileGenerator.generate();
}
