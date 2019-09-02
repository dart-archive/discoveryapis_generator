// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library discoveryapis_generator.client_api_library;

import 'package:path/path.dart' as path;

import '../dart_api_library.dart';
import '../dart_resources.dart';
import '../dart_schemas.dart';
import '../generated_googleapis/discovery/v1.dart';
import '../utils.dart';
import 'client_schemas.dart' as client;

/// Generates a client API library based on a [RestDescription] and an import
/// map. This generator is used to generate a client inside the same package
/// as the server API. It will use the existing definitions of the API message
/// classes instead of generating new client message classes.
class ClientApiLibrary extends BaseApiLibrary {
  DartSchemaTypeDB schemaDB;
  DartApiClass apiClass;
  bool exposeMedia;
  String schemaImports;
  String libraryName;
  String packageName;
  String packageRoot;

  /// Generates a API library for [description].
  ClientApiLibrary.build(RestDescription description,
      Map<String, String> importMap, this.packageName, this.packageRoot,
      {bool useCorePrefixes: true})
      : super(description, '', useCorePrefixes: useCorePrefixes) {
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
    final parsedImports = <String>[];
    imports.forEach((importPath) {
      if (!importPath.startsWith('package:$packageName')) {
        var pathPrefix = path.toUri(packageRoot).toString() + '/lib';
        if (!importPath.startsWith(pathPrefix)) {
          throw new GeneratorError(
              description.name,
              description.version,
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
    if (resources.isNotEmpty) {
      sink.writeln('$resources');
    }
    sink.write('$schemas');
    return '$sink';
  }

  /// Create the library header. Note, this must be called after the library
  /// source string has been generated, since it relies on [Identifier] usage
  /// counts being calculated
  String libraryHeader() {
    var exportedMediaClasses = '';
    if (exposeMedia) {
      exportedMediaClasses = ', Media, UploadOptions,\n'
          '    ResumableUploadOptions, DownloadOptions, '
          'PartialDownloadOptions,\n'
          '    ByteRange';
    }

    String result = """
// This is a generated file (see the discoveryapis_generator project).

// ignore_for_file: unused_import, unnecessary_cast

library $libraryName;

""";

    if (imports.core.hasPrefix) {
      result += "import 'dart:core' as ${imports.core};\n";
    }

    if (imports.collection.wasCalled) {
      result += "import 'dart:collection' as ${imports.collection};\n";
    }

    if (imports.async.hasPrefix) {
      result += "import 'dart:async' as ${imports.async};\n";
    } else {
      result += "import 'dart:async';\n";
    }

    if (imports.convert.wasCalled) {
      result += "import 'dart:convert' as ${imports.convert};\n";
    }

    result += """

import 'package:_discoveryapis_commons/_discoveryapis_commons.dart' as ${imports.commons};
""";

    return result +
        """
import 'package:http/http.dart' as ${imports.http};
$schemaImports
export 'package:_discoveryapis_commons/_discoveryapis_commons.dart' show
    ApiRequestError, DetailedApiRequestError${exportedMediaClasses};

const ${imports.core.ref()}String USER_AGENT = 'dart-api-client ${description.name}/${description.version}';

""";
  }
}
