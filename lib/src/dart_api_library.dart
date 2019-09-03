// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library discoveryapis_generator.dart_api_library;

import 'dart_resources.dart';
import 'dart_schemas.dart';
import 'generated_googleapis/discovery/v1.dart';
import 'namer.dart';

/// Encapsulates names of prefix-imported libraries.
class DartApiImports {
  final ApiLibraryNamer namer;

  Identifier core;
  Identifier collection;
  Identifier async;
  Identifier convert;
  Identifier http;
  Identifier commons;

  DartApiImports.fromNamer(this.namer, {bool useCorePrefixes: true}) {
    core = useCorePrefixes ? namer.import('core') : namer.noPrefix();
    collection = namer.import('collection');
    async = useCorePrefixes ? namer.import('async') : namer.noPrefix();
    convert = namer.import('convert');
    http = namer.import('http');
    commons = namer.import('commons');
  }
}

abstract class BaseApiLibrary {
  final ApiLibraryNamer namer;
  final RestDescription description;

  DartApiImports imports;

  BaseApiLibrary(this.description, String apiClassSuffix,
      {bool useCorePrefixes: true})
      : namer = new ApiLibraryNamer(apiClassSuffix: apiClassSuffix) {
    imports =
        new DartApiImports.fromNamer(namer, useCorePrefixes: useCorePrefixes);
  }
}

/// Generates a API library based on a [RestDescription].
class DartApiLibrary extends BaseApiLibrary {
  DartSchemaTypeDB schemaDB;
  DartApiClass apiClass;
  bool exposeMedia;
  String libraryName;

  /// Generates a API library for [description].
  DartApiLibrary.build(RestDescription description, String packageName,
      {bool useCorePrefixes: true})
      : super(description, 'Api', useCorePrefixes: useCorePrefixes) {
    libraryName =
        namer.libraryName(packageName, description.name, description.version);
    schemaDB = parseSchemas(imports, description);
    apiClass = parseResources(imports, schemaDB, description);
    exposeMedia = parseMediaUse(apiClass);
    namer.nameAllIdentifiers();
  }

  String get librarySource {
    var sink = new StringBuffer();
    var schemas = generateSchemas(schemaDB);
    var resources = generateResources(apiClass);
    sink.write(libraryHeader());
    if (resources.isNotEmpty) {
      sink.write('$resources\n$schemas');
    } else {
      sink.write('$schemas');
    }
    return '${sink.toString().trimRight()}\n';
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

export 'package:_discoveryapis_commons/_discoveryapis_commons.dart' show
    ApiRequestError, DetailedApiRequestError${exportedMediaClasses};

const ${imports.core.ref()}String USER_AGENT = 'dart-api-client ${description.name}/${description.version}';

""";
  }
}
