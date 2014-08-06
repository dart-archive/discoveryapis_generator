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
  Identifier httpBase;

  /**
   * A symbol for the prefix import of the shared internal library.
   */
  Identifier internal;

  /**
   * A symbol for the prefix import of the shared externally visible library.
   */
  Identifier external;

  DartApiImports.fromNamer(this.namer) {
    core = namer.import('core');
    collection = namer.import('collection');
    crypto = namer.import('crypto');
    async = namer.import('async');
    convert = namer.import('convert');
    httpBase = namer.import('http_base');
    internal = namer.import('common_internal');
    external = namer.import('common');
  }
}

/**
 * Generates a API library based on a [RestDescription].
 */
class DartApiLibrary {
  final ApiLibraryNamer namer = new ApiLibraryNamer();

  final RestDescription description;
  final String internalSharedLibraryUri;
  final String externalSharedLibraryUri;

  String libraryName;
  DartApiImports imports;
  DartSchemaTypeDB schemaDB;
  DartApiClass apiClass;

  /**
   * Generates a API library for [description].
   *
   * [internalSharedLibraryUri] is a URI for an internal library which is
   * shared between all generated APIs but should not be exposed.
   *
   * [externalSharedLibraryUri] is a URI for a library which is shared between
   * all generatedAPIs and is publicly visible.
   */
  DartApiLibrary.build(this.description,
                       this.internalSharedLibraryUri,
                       this.externalSharedLibraryUri) {
    libraryName = namer.libraryName(
        'googleapis', description.name, description.version);
    imports = new DartApiImports.fromNamer(namer);
    schemaDB = parseSchemas(imports, description);
    apiClass = parseResources(imports, schemaDB, description);
    namer.nameAllIdentifiers();
  }

  String get librarySource {
    var sink = new StringBuffer();
    var schemas = generateSchemas(schemaDB);
    var resources = generateResources(apiClass);
    sink.write(libraryHeader);
    if (!resources.isEmpty) {
      sink.write('$resources\n$schemas');
    } else {
      sink.write('$schemas');
    }
    return '$sink';
  }

  String get libraryHeader {
    return
"""
library $libraryName;

import "dart:core" as ${imports.core};
import "dart:collection" as ${imports.collection};
import "dart:async" as ${imports.async};
import "dart:convert" as ${imports.convert};

import "package:crypto/crypto.dart" as ${imports.crypto};
import 'package:http_base/http_base.dart' as ${imports.httpBase};
import '$internalSharedLibraryUri' as ${imports.internal};
import '$externalSharedLibraryUri' as ${imports.external};

export '$externalSharedLibraryUri' show ApiRequestError;
export '$externalSharedLibraryUri' show DetailedApiRequestError;

""";
  }
}
