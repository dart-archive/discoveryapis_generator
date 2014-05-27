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
    _writeApiClass(sink);
    _writeSchemas(sink);
    _writeResources(sink);

    return '$sink';
  }

  void _writeHeader(StringSink sink) {
    sink.write("""
library $libraryName;

import "dart:core" as core;
import "dart:async" as async;
import "dart:convert" show JSON;
import 'dart:collection' as dart_collection;

import 'package:http_base/http_base.dart' as http_base;
import '$internalLibraryUri' as common_internal;
import '$externalLibraryUri' as common_external;

export '$internalLibraryUri' show APIRequestError;

""");
  }

  void _writeApiClass(StringSink sink) {
    sink.write("""
class ${capitalize(_name)} {
  core.String basePath = \"${_description.basePath}\";
  core.String rootUrl = \"${_rootUriOrigin}/\";
  core.Map<core.String, core.Object> _parms = <core.String, core.Object>{};
  common_internal.ApiRequester _httpClient;

  ${capitalize(_name)}(http_base.Client client) {
    _httpClient =
        new common_internal.ApiRequester(client, _parms, rootUrl, basePath);
  }


""");

    if (_description.resources != null) {
      sink.writeln("""
  //
  // Resources
  //
""");
      _description.resources.forEach((key, resource) {
        var subClassName = "${capitalize(key)}Resource_";
        sink.writeln(
            "  $subClassName get $key => new $subClassName(_httpClient);");
      });
    }
    sink.writeln();

    if (_description.parameters!= null) {
      sink.writeln("""
  //
  // Parameters
  //""");
      _description.parameters.forEach((String key, JsonSchema param) {
        var type = _getDartType(param);
        sink.writeln();
        sink.writeln('  /**');
        if (param.description != null) {
          sink.writeln('   * ${escapeComment(param.description)}');
        }
        sink.writeln('   * Added as queryParameter for each request.');
        sink.writeln('   */');
        sink.writeln('  $type get $key => _parms[\"$key\"];');
        sink.writeln('  set $key($type value) => _parms[\"$key\"] = value;');
      });
    }

    if (_description.methods != null) {
      sink.writeln("""

  //
  // Methods
  //""");
      _description.methods.forEach((String key, RestMethod method) {
        sink.writeln();
        _writeMethod(sink, key, method, true);
      });
    }

    sink.write("""
}
""");
  }

  void _writeSchemas(StringSink sink) {
    sink.writeln();
    if (_description.schemas != null) {
      Map<String, String> factoryTypes = {};
      _description.schemas.forEach((String key, JsonSchema schema) {
        if (schema.variant != null && schema.variant.discriminant != null &&
            schema.variant.discriminant == "type") {
          schema.variant.map.forEach((JsonSchemaVariantMap concreteType) {
            factoryTypes[concreteType.$ref] = capitalize(key);
          });
        }
      });
      _description.schemas.forEach((String key, JsonSchema schema) {
        _writeSchemaClass(sink, key, schema, factoryTypes);
      });
    }
  }

  void _writeResources(StringSink sink) {
    sink.writeln();
    if (_description.resources != null) {
      _description.resources.forEach((String key, RestResource resource) {
        _writeResourceClass(sink, key, resource);
      });
    }
  }

  void _writeScopes(StringSink sink) {
    if(_description.auth != null && _description.auth.oauth2 != null &&
       _description.auth.oauth2.scopes != null) {
       _description.auth.oauth2.scopes
           .forEach((String name, RestDescriptionAuthOauth2Scopes scopes) {
        var p = name.lastIndexOf("/");
        var scopeName = name.toUpperCase();
        if (p >= 0) scopeName = scopeName.substring(p+1);
        scopeName = cleanName(scopeName);
        sink.writeln();
        if (scopes.description != null) {
          sink.writeln(
              '  /** OAuth Scope2: ${escapeComment(scopes.description)} */');
        } else {
          sink.writeln('  /** OAuth Scope2 */');
        }
        sink.writeln('  static const String ${scopeName}_SCOPE = \"$name\";');
      });
    }
  }

  String get _rootUriOrigin => Uri.parse(_description.rootUrl).origin;
}
