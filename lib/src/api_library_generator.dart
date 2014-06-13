part of discovery_api_client_generator;

/// Generates a dart library for the API given in the constructor.
///
/// This class generates one dart library with the following content:
///   library $libraryName;
///   ... imports ...
///   ... main API class ...
///   ... schemas ...
///   ... resources ...
///   ... utility functions + classes ...
///
class ApiLibraryGenerator {
  final RestDescription _description;
  final String libraryName;
  final String internalLibraryUri;
  final String externalLibraryUri;

  /// [_description] is the API description we want to generate code for.
  /// [libraryName] is the name of the API library we generate.
  /// [internalLibraryUri] is the Uri of the library containing shared code
  /// between all APIs but is not public (from the perspective of the package).
  ApiLibraryGenerator(
      this._description, this.libraryName,
      this.internalLibraryUri, this.externalLibraryUri) {
    assert(this._description != null);
    assert(this._description.name != null);
  }

  String get _name => _description.name;

  /// Will generate the dart library file and write the output to [outptuFile].
  void generateClient(String outputFile) {
    _writeString(outputFile, _createLibrary());
  }

  String _createLibrary() {
    var sink = new StringBuffer();

    _writeHeader(sink);

    var db = parseSchemas(_description);
    var schemas = generateSchemas(db);
    var resources = generateResources(parseResources(db, _description));
    if (!resources.isEmpty) {
      sink.write('$resources\n$schemas');
    } else {
      sink.write('$schemas');
    }

    return '$sink';
  }

  void _writeHeader(StringSink sink) {
    sink.write("""
library $libraryName;

import "dart:core" as core;
import "dart:collection" as collection;
import "dart:async" as async;
import "dart:convert" show JSON;
import 'dart:collection' as dart_collection;

import 'package:http_base/http_base.dart' as http_base;
import '$internalLibraryUri' as common_internal;
import '$externalLibraryUri' as common_external;

export '$internalLibraryUri' show APIRequestError;

""");
  }
}
