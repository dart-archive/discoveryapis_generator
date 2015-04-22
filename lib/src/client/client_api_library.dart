// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library discoveryapis_generator.client_api_library;

import 'package:path/path.dart' as path;

import 'client_schemas.dart' as client;
import '../dart_api_library.dart';
import '../dart_resources.dart';
import '../dart_schemas.dart';
import '../utils.dart';
import '../generated_googleapis/discovery/v1.dart';

/**
 * Generates a client API library based on a [RestDescription] and an import
 * map. This generator is used to generate a client inside the same package
 * as the server API. It will use the existing definitions of the API message
 * classes instead of generating new client message classes.
 */
class ClientApiLibrary extends BaseApiLibrary {
  DartSchemaTypeDB schemaDB;
  DartApiClass apiClass;
  bool exposeMedia;
  String schemaImports;
  String libraryName;
  String packageName;
  String packageRoot;

  /**
   * Generates a API library for [description].
   */
  ClientApiLibrary.build(RestDescription description,
                         Map<String, String> importMap,
                         this.packageName,
                         this.packageRoot)
      : super(description, '') {
    libraryName = namer.clientLibraryName(packageName, description.name);
    schemaDB = client.parseSchemas(imports, description);
    apiClass = parseResources(imports, schemaDB, description);
    exposeMedia = parseMediaUse(apiClass);
    schemaImports = _parseImports(importMap).join('\n');
    namer.nameAllIdentifiers();
  }

  List<String> _parseImports(Map<String, String> importsMap) {
    // Remove duplicate imports.
    var imports = new Set<String>();
    schemaDB.dartClassTypes.forEach((schema) {
      assert(importsMap.containsKey(schema.className.preferredName));
      var path = importsMap[schema.className.preferredName];
      if (path.startsWith('dart:')) {
        return;
      }
      imports.add(path);
    });
    // Make import paths relative to the package's lib directory and write them
    // out.
    var parsedImports = [];
    imports.forEach((importPath) {
      if (!importPath.startsWith('package:$packageName')) {
        var pathPrefix = path.toUri(packageRoot).toString() + '/lib';
        if (!importPath.startsWith(pathPrefix)) {
          throw new GeneratorError(description.name, description.version,
              'RPC message classes must reside in the package\'s lib '
              'directory.');
        }
        importPath =
            importPath.replaceFirst(pathPrefix, 'package:$packageName');
      }
      parsedImports.add('import \'$importPath\';');
    });
    return parsedImports;
  }

  String get librarySource {
    var sink = new StringBuffer();
    var schemas = generateSchemas(schemaDB);
    var resources = generateResources(apiClass);
    sink.write(libraryHeader());
    if (!resources.isEmpty) {
      sink.writeln('$resources');
    }
    sink.write('$schemas');
    return '$sink';
  }

  String libraryHeader() {
    var exportedMediaClasses = '';
    if (exposeMedia) {
      exportedMediaClasses = ', Media, UploadOptions,\n'
          '    ResumableUploadOptions, DownloadOptions, '
          'PartialDownloadOptions,\n'
          '    ByteRange';
    }
    return
"""
library $libraryName;

import 'dart:core' as ${imports.core};
import 'dart:collection' as ${imports.collection};
import 'dart:async' as ${imports.async};
import 'dart:convert' as ${imports.convert};

import 'package:_discoveryapis_commons/_discoveryapis_commons.dart' as ${imports.commons};
import 'package:crypto/crypto.dart' as ${imports.crypto};
import 'package:http/http.dart' as ${imports.http};
$schemaImports
export 'package:_discoveryapis_commons/_discoveryapis_commons.dart' show
    ApiRequestError, DetailedApiRequestError${exportedMediaClasses};

const ${imports.core}.String USER_AGENT = 'dart-api-client ${description.name}/${description.version}';

""";
  }
}
