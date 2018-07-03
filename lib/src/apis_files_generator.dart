// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library discoveryapis_generator.apis_files_generator;

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

import '../discoveryapis_generator.dart' show Pubspec;
import 'client/client_api_library.dart';
import 'dart_api_library.dart';
import 'generated_googleapis/discovery/v1.dart';
import 'utils.dart';

class DescriptionImportPair {
  final String apiDescription;
  final Map<String, String> importMap;

  DescriptionImportPair(this.apiDescription, this.importMap);
}

/// Generates one or more API files based on the given descriptions.
class ApisFilesGenerator {
  final List<DescriptionImportPair> descriptions;
  final String clientFolderPath;
  final bool updatePubspec;
  final bool useCorePrefixes;
  String packageRoot;
  File pubspecFile;

  /// [descriptions] is a list of API descriptions we want to generate code for.
  /// [clientFolderPath] is the output directory for the generated client stub
  /// code.
  ApisFilesGenerator(this.descriptions, this.clientFolderPath,
      {this.updatePubspec: false, this.useCorePrefixes: true}) {
    // Create the output directory.
    var clientDirectory = new Directory(clientFolderPath);
    packageRoot = findPackageRoot(path.absolute(clientDirectory.path));
    if (packageRoot == null) {
      throw new Exception(
          'Client folder: \'$clientFolderPath\' must be in a package.');
    }
    if (!clientDirectory.existsSync()) {
      clientDirectory.createSync(recursive: true);
    }
    pubspecFile = new File(path.join(packageRoot, 'pubspec.yaml'));
    assert(pubspecFile.existsSync());
  }

  /// Generates the client stub code with all the APIs given in the constructor.
  List<GenerateResult> generate() {
    // Get the package name.
    var pubspec = loadYaml(pubspecFile.readAsStringSync());
    String packageName = pubspec != null ? pubspec['name'] : null;
    if (packageName == null) {
      throw new Exception('Invalid pubspec.yaml for package $packageRoot');
    }

    bool processPubspec = false;
    var results = <GenerateResult>[];
    descriptions.forEach((diPair) {
      var description =
          new RestDescription.fromJson(json.decode(diPair.apiDescription));
      String name = description.name.toLowerCase();
      String version = description.version.toLowerCase();
      String apiFile = path.join(clientFolderPath, '${name}.dart');
      try {
        var lib;
        if (diPair.importMap == null) {
          // Build a normal client stub file without using the same message
          // classes.
          lib = new DartApiLibrary.build(description, packageName,
              useCorePrefixes: useCorePrefixes);
        } else {
          // Build a client stub api using common message classes.
          lib = new ClientApiLibrary.build(
              description, diPair.importMap, packageName, packageRoot);
        }
        writeDartSource(apiFile, lib.librarySource);
        final result = new GenerateResult(name, version, clientFolderPath);
        results.add(result);
        processPubspec = true;
      } catch (error, stack) {
        var errorMessage = '';
        if (error is GeneratorError) {
          errorMessage = '$error';
        } else {
          errorMessage = '$error\nstack: $stack';
        }
        results.add(new GenerateResult.error(
            name, version, clientFolderPath, errorMessage));
      }
    });

    // Print or add required dependencies to the pubspec.yaml file.
    if (processPubspec) {
      var msg = _processPubspec();
      results.add(new GenerateResult.fromMessage(msg));
    }

    return results;
  }

  String _processPubspec() {
    void writeValue(StringSink sink, String key, dynamic value, String indent) {
      if (value is String) {
        // Encapsulate constraints with ''
        if (value.contains(new RegExp('<|>')) &&
            !value.startsWith(new RegExp('\''))) {
          value = '\'$value\'';
        }
        sink.writeln("$indent$key: $value");
      } else if (value is Map) {
        sink.writeln("$indent$key:");
        value.forEach((key, value) {
          writeValue(sink, key, value, '$indent  ');
        });
      }
    }

    const List<String> pubspecKeys = const [
      'name',
      'version',
      'description',
      'author',
      'authors',
      'homepage',
      'documentation',
      'environment',
      'dependencies',
      'dev_dependencies',
      'dependency_overrides',
      'executables',
      'transformers'
    ];

    // Process pubspec and either print the dependencies that has to be added
    // or if the updatePubspec flag is set add the required dependencies to the
    // existing pubspec.yaml file.
    YamlMap pubspec = loadYaml(pubspecFile.readAsStringSync());
    if (updatePubspec) {
      var sink = new StringBuffer();
      pubspecKeys.forEach((key) {
        var value;
        if (key == 'dependencies') {
          // patch up dependencies.
          value = pubspec[key];
          value = value != null ? value = new Map.from(value) : {};
          value.addAll(_computeNewDependencies(value));
        } else {
          value = pubspec[key];
        }
        writeValue(sink, key, value, '');
      });
      pubspecFile.writeAsStringSync(sink.toString());
      return 'Updated pubspec.yaml file with required dependencies.';
    } else {
      var newDeps = _computeNewDependencies(pubspec['dependencies']);
      var sink = new StringBuffer();
      if (newDeps.isNotEmpty) {
        sink.writeln('Please update your pubspec.yaml file with the following '
            'dependencies:');
        newDeps.forEach((k, v) => sink.writeln('  $k: $v'));
      }
      return sink.toString();
    }
  }

  Map<String, dynamic> _computeNewDependencies(YamlMap current) {
    final result = <String, dynamic>{};
    Pubspec.dependencies.forEach((String k, Object v) {
      if (current == null || !current.containsKey(k)) {
        result[k] = v;
      }
    });
    return result;
  }
}
