part of discovery_api_client_generator;

/**
 * Encapsulates names of prefix-imported libraries.
 */
class DartApiImports {
  final ApiLibraryNamer namer;

  Identifier core;
  Identifier collection;
  Identifier crypto;
  Identifier async;
  Identifier convert;
  Identifier http;
  Identifier commons;

  DartApiImports.fromNamer(this.namer) {
    core = namer.import('core');
    collection = namer.import('collection');
    crypto = namer.import('crypto');
    async = namer.import('async');
    convert = namer.import('convert');
    http = namer.import('http');
    commons = namer.import('commons');
  }
}

/**
 * Generates a API library based on a [RestDescription].
 */
class DartApiLibrary {
  final ApiLibraryNamer namer = new ApiLibraryNamer();

  final RestDescription description;
  final String packageName;

  String libraryName;
  DartApiImports imports;
  DartSchemaTypeDB schemaDB;
  DartApiClass apiClass;
  bool exposeMedia;

  /**
   * Generates a API library for [description].
   */
  DartApiLibrary.build(this.description,
                       this.packageName) {
    libraryName = namer.libraryName(
        packageName, description.name, description.version);
    imports = new DartApiImports.fromNamer(namer);
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
    if (!resources.isEmpty) {
      sink.write('$resources\n$schemas');
    } else {
      sink.write('$schemas');
    }
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

export 'package:_discoveryapis_commons/_discoveryapis_commons.dart' show
    ApiRequestError, DetailedApiRequestError${exportedMediaClasses};

const ${imports.core}.String USER_AGENT = 'dart-api-client ${description.name}/${description.version}';

""";
  }
}
