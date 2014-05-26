part of discovery_api_client_generator;


class Generator {
  final RestDescription _description;
  final String _prefix;
  final Config _config;

  Generator(this._description, this._prefix, [this._config = const Config()]) {
    assert(this._description != null);
    assert(this._description.name != null);
    assert(this._prefix != null);
  }

  String get _libraryPubspecName {
    var prefix = (_prefix.isEmpty) ? '' : _prefix + "_";
    prefix = cleanName(prefix).toLowerCase();
    return "${prefix}${_shortName}_api";
  }

  String get _name => _description.name;
  String get _version => _description.version;

  String get _shortName => cleanName("${_name}_${_version}").toLowerCase();

  String get _libraryName => "${_shortName}_api_client";
  String get _gitName => "dart_${_libraryName}";

  GenerateResult generateClient(String outputDirectory, {bool check: false, bool force: false, int forceVersion}) {
    var mainFolder = "$outputDirectory/$_gitName";
    var libFolder = "$mainFolder/lib";

    int clientVersionBuild = 0;
    var clientVersion = _config.clientVersion;
    if (check) {
      var versionFile = new File("$mainFolder/VERSION");
      var pubFile = new File("$mainFolder/pubspec.yaml");
      if (versionFile.existsSync() && pubFile.existsSync()) {
        var etag = versionFile.readAsStringSync();
        var pub = pubFile.readAsLinesSync();
        var version = "";
        pub.forEach((String line) {
          if (line.startsWith("version: ")) {
            version = line.substring(9);
          }
        });
        if (force) {
          print("Forced rebuild");
          print("Regenerating library $_libraryName");
          if (version.startsWith(clientVersion)) {
            // TODO(adam): does not support semantic versioning,
            // what happens if 0.1.0-dev.0 has been manually pushed?
            // http://semver.org/
            clientVersionBuild = (forceVersion != null) ? forceVersion : int.parse(version.substring(clientVersion.length + 1)) + 1;
          } else {
            clientVersionBuild = (forceVersion != null) ? forceVersion : 0;
          }
        } else {
          if (version.startsWith(clientVersion)) {
            if (etag == _description.etag) {
              var msg = "Nothing changed for $_libraryName";
              print(msg);
              return new GenerateResult._(_name, _version, mainFolder, msg);
            } else {
              print("Changes for $_libraryName");
              print("Regenerating library $_libraryName");
              clientVersionBuild = (forceVersion != null) ? forceVersion : int.parse(version.substring(clientVersion.length + 1)) + 1;
            }
          } else {
            print("Generator version changed.");
            print("Regenerating library $_libraryName");
            clientVersionBuild = (forceVersion != null) ? forceVersion : 0;
          }
        }
      } else {
        print("Library $_libraryName does not exist yet.");
        print("Generating library $_libraryName");
        clientVersionBuild = (forceVersion != null) ? forceVersion : 0;
      }
    }

    // Clean contents of directory (except for .git folder)
    var tmpDir = new Directory(mainFolder);
    if (tmpDir.existsSync()) {
      print("Emptying folder before library generation.");
      tmpDir.listSync().forEach((f) {
        if (f is File) {
          f.deleteSync();
        } else if (f is Directory) {
          if (!f.path.endsWith(".git")) {
            f.deleteSync(recursive: true);
          }
        }
      });
    }

    (new Directory("$libFolder/src/client")).createSync(recursive: true);

    _writeFile("$mainFolder/pubspec.yaml", (sink) => _writePubspec(sink, clientVersionBuild));

    _writeString("$mainFolder/LICENSE", _license);

    _writeFile("$mainFolder/README.md", (sink) => _writeReadme(sink, clientVersionBuild));

    _writeString("$mainFolder/.gitignore", _gitIgnore);

    _writeString("$mainFolder/VERSION", _description.etag);

    // Create cloud api files
    _writeString("$libFolder/src/client_base.dart", _CLOUD_API_SOURCE);

    // Create common library files

    _writeString("$libFolder/$_libraryName.dart", _createLibrary);

    _writeFile("$libFolder/src/client/schemas.dart", _writeSchemas);

    _writeFile("$libFolder/src/client/resources.dart", _writeResources);

    _writeFile("$libFolder/src/client/utils.dart", _writeUtils);

    print("Library $_libraryName generated successfully.");
    return new GenerateResult._(_name, _version, mainFolder);
  }

  void _writePubspec(StringSink sink, int clientVersionBuild) {
    sink.writeln("name: $_libraryPubspecName");
    sink.writeln("version: ${_config.getLibraryVersion(clientVersionBuild)}");

    sink.writeln("author: Dart Team <misc@dartlang.org>");

    sink.writeln("description: Auto-generated client library for accessing the $_name $_version API");
    sink.writeln("homepage: https://github.com/dart-gde/discovery_api_dart_client_generator");
    sink.writeln("environment:");
    sink.writeln("  sdk: '${_config.dartEnvironmentVersionConstraint}'");

    _config.writeAllDependencies(sink);
  }

  void _writeReadme(StringSink sink, int clientVersionBuild) {
    sink.write("""
# $_libraryPubspecName

### Description

Auto-generated client library for accessing the $_name $_version API.

""");
    sink.write("#### ");
    if (_description.icons != null && _description.icons.x16 != null) {
      sink.write("![Logo](${_description.icons.x16}) ");
    }
    sink.writeln('${_description.title} - $_name $_version');
    sink.writeln();
    sink.writeln('${_description.description}');
    sink.writeln();
    if (_description.documentationLink != null) {
      sink.writeln('Official API documentation: ${_description.documentationLink}');
      sink.writeln();
    }
    sink.writeln('Adding dependency to pubspec.yaml\n\n```\n  dependencies:\n    $_libraryPubspecName: \'>=${_config.getLibraryVersion(clientVersionBuild)}\'\n```');
    sink.writeln();


    sink.writeln('Working without authentication the following constructor can be called:\n\n```\n  var ${cleanName(_name).toLowerCase()} = new ${cleanName(_name).toLowerCase()}client.${capitalize(_name)}();\n```');
    sink.writeln();
    sink.writeln('To use authentication create a new `GoogleOAuth2` object and pass it to the constructor:\n\n');
    sink.writeln('```\n  GoogleOAuth2 auth = new GoogleOAuth2(CLIENT_ID, SCOPES);\n  var ${cleanName(_name).toLowerCase()} = new ${cleanName(_name).toLowerCase()}client.${capitalize(_name)}(auth);\n```');
    sink.writeln();
    sink.writeln('### Licenses\n\n```');
    sink.write(_license);
    sink.writeln('```');
  }

  String get _createLibrary {
    var sink = new StringBuffer();
    sink.write("""
library ${_shortName}_api;

import "dart:core" as core;
import "dart:async" as async;
import "dart:convert" show JSON;
import 'dart:collection' as dart_collection;

import 'package:http_base/http_base.dart' as http_base;
import 'package:$_libraryPubspecName/src/client_base.dart';
export 'package:$_libraryPubspecName/src/client_base.dart' show APIRequestError;

part 'src/client/schemas.dart';
part 'src/client/resources.dart';
part 'src/client/utils.dart';

""");

    sink.write("""
class ${capitalize(_name)} {
  core.String basePath = \"${_description.basePath}\";
  core.String rootUrl = \"${_rootUriOrigin}/\";
  core.Map<core.String, core.Object> _parms = <core.String, core.Object>{};
  ApiRequester _client;

  ${capitalize(_name)}(http_base.Client client) {
    _client = new ApiRequester(client, _parms, rootUrl, basePath);
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
        sink.writeln("  $subClassName get $key => new $subClassName(_client);");
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
          sink.writeln('   * ${param.description}');
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

    return '$sink';
  }
  void _writeSchemas(StringSink sink) {
    sink.writeln("part of ${_shortName}_api;");
    sink.writeln();

    if (_description.schemas != null) {
      Map<String, String> factoryTypes = {};
      _description.schemas.forEach((String key, JsonSchema schema) {
        if (schema.variant != null && schema.variant.discriminant != null && schema.variant.discriminant == "type") {
          schema.variant.map.forEach((JsonSchemaVariantMap concreteType) {
            factoryTypes[concreteType.$ref] = capitalize(key);
          });
        }
      });
      _description.schemas.forEach((String key, JsonSchema schema) {
        _writeSchemaClass(sink, key, schema, factoryTypes);
      });

      sink.write(_mapMapFunction);
    }
  }

  void _writeResources(StringSink sink) {
    sink.writeln("part of ${_shortName}_api;");
    sink.writeln();

    if (_description.resources != null) {
      _description.resources.forEach((String key, RestResource resource) {
        _writeResourceClass(sink, key, resource);
      });
    }
  }

  void _writeUtils(StringSink sink) {
    sink.writeln("part of ${_shortName}_api;");
    sink.writeln();
    sink.writeln(_schemaArraySource);
    sink.writeln();
    sink.writeln(_schemaAnyObjectSource);
  }

  void _writeScopes(StringSink sink) {
    if(_description.auth != null && _description.auth.oauth2 != null && _description.auth.oauth2.scopes != null) {
      _description.auth.oauth2.scopes.forEach((String name, RestDescriptionAuthOauth2Scopes scopes) {
        var p = name.lastIndexOf("/");
        var scopeName = name.toUpperCase();
        if (p >= 0) scopeName = scopeName.substring(p+1);
        scopeName = cleanName(scopeName);
        sink.writeln();
        if (scopes.description != null) {
          sink.writeln('  /** OAuth Scope2: ${scopes.description} */');
        } else {
          sink.writeln('  /** OAuth Scope2 */');
        }
        sink.writeln('  static const String ${scopeName}_SCOPE = \"$name\";');
      });
    }
  }

  String get _rootUriOrigin => Uri.parse(_description.rootUrl).origin;

  static const String _mapMapFunction = """
core.Map _mapMap(core.Map source, [core.Object convert(core.Object source) = null]) {
  assert(source != null);
  var result = new dart_collection.LinkedHashMap();
  source.forEach((core.String key, value) {
    assert(key != null);
    if(convert == null) {
      result[key] = value;
    } else {
      result[key] = convert(value);
    }
  });
  return result;
}
""";


  static const _CLOUD_API_SOURCE = r"""
library cloud_api;

import "dart:async";
import "dart:convert";

import "package:http_base/http_base.dart" as http_base;

// TODO: Change these minimalistic implementations to be correct as defined
// in the interface.
class HeadersImpl implements http_base.Headers {
  final Map<String, List<String>> _m;

  HeadersImpl(this._m);

  Iterable<String> get names => _m.keys;

  bool contains(String name) =>  _m.containsKey(name);

  String operator [](String name) {
    var values = _m[name];
    if (values == null) return null;
    if (values.length == 1) return values.first;
    return values.join(',');
  }

  Iterable<String> getMultiple(String name) => _m[name];
}

class RequestImpl implements http_base.Request {
  final String method;
  final Uri url;
  final http_base.Headers headers;
  final Stream<List<int>> _body;

  Stream<List<int>> read() => _body;

  RequestImpl(this.method, this.url, this.headers, this._body);
}

class ResponseImpl implements http_base.Response {
  final int status;
  final http_base.Headers headers;
  final Stream<List<int>> _body;

  Stream<List<int>> read() => _body;

  ResponseImpl(this.status, this.headers, this._body);
}


/**
 * Base class for all API clients, offering generic methods for HTTP Requests
 * to the API.
 */
class ApiRequester {
  bool makeAuthRequests = false;

  final http_base.Client _httpClient;
  final Map<String, Object> _optionalQueryAdditions;
  final String _rootUrl;
  final String _basePath;

  ApiRequester(this._httpClient, this._optionalQueryAdditions,
               this._rootUrl, this._basePath);

  static const _boundary = "-------314159265358979323846";
  static const _delimiter = "\r\n--$_boundary\r\n";
  static const _closeDelim = "\r\n--$_boundary--";

  /**
   * Sends a HTTPRequest using [method] (usually GET or POST) to [requestUrl]
   * using the specified [urlParams] and [queryParams]. Optionally include a
   * [body] in the request.
   */
  Future<Map<String, dynamic>> request(String requestUrl, String method,
                                       {String body,
                                        String contentType:"application/json",
                                        Map urlParams, Map queryParams}) {
    var headers = new HeadersImpl({'content-type' : [contentType]});

    if (queryParams == null) queryParams = const {};
    var allQueryParameters = new Map<String,String>.from(queryParams);
   
    if (_optionalQueryAdditions != null) {
      _optionalQueryAdditions.forEach((String key, Object value) {
        if (value != null && allQueryParameters[key] == null) {
          allQueryParameters[key] = '$value';
        }
      });
    }

    var path;
    if (requestUrl.substring(0,1) == "/") {
      path ="$_rootUrl${requestUrl.substring(1)}";
    } else {
      path ="$_rootUrl${_basePath.substring(1)}$requestUrl";
    } 

    var url = new UrlPattern(path).generate(urlParams, queryParams);
    var uri = Uri.parse(url);

    var bodyController = new StreamController<List<int>>();
    if (body != null) {
      bodyController.add(UTF8.encode(body));
    }
    bodyController.close();

    var request = new RequestImpl(method, uri, headers, bodyController.stream);
    return _httpClient(request).then((http_base.Response response) {
      return response.read().transform(UTF8.decoder)
          .join('').then((String bodyString) {
        DetailedApiRequestError.validateResponse(response.status, bodyString);
        if (bodyString == '') return null;
        return JSON.decode(bodyString);
      });
    });
  }

  /**
   * Joins [content] (encoded as Base64-String) with specified [contentType]
   * and additional request [body] into one multipart-body and send a
   * HTTPRequest with [method] (usually POST) to [requestUrl]
   */
  Future<Map<String, dynamic>> upload(String requestUrl, String method,
                                      String body, String content,
                                      String contentType,
                                      {Map urlParams, Map queryParams}) {
    var multiPartBody = new StringBuffer();
    if (contentType == null || contentType.isEmpty) {
      contentType = "application/octet-stream";
    }
    multiPartBody
    ..write(_delimiter)
    ..write("Content-Type: application/json\r\n\r\n")
    ..write(body)
    ..write(_delimiter)
    ..write("Content-Type: ")
    ..write(contentType)
    ..write("\r\n")
    ..write("Content-Transfer-Encoding: base64\r\n")
    ..write("\r\n")
    ..write(content)
    ..write(_closeDelim);

    queryParams["uploadType"] = "multipart";

    return request(requestUrl, method, body: multiPartBody.toString(),
        contentType: "multipart/mixed; boundary=\"$_boundary\"",
        urlParams: urlParams, queryParams: queryParams);
  }

  static Map<String, dynamic> responseParse(int statusCode,
                                            String responseBody) {
    DetailedApiRequestError.validateResponse(statusCode, responseBody);

    if(responseBody.isEmpty) {
      return null;
    }
    return JSON.decode(responseBody);
  }
}

/**
 * Error thrown when the HTTP Request to the API failed
 */
class APIRequestError extends Error {
  final String message;
  APIRequestError([this.message]);
  String toString() {
    if (message == null) {
      return "APIRequestException";
    } else {
      return "APIRequestException: $message";
    }
  }
}

class DetailedApiRequestError extends Error {
  final int statusCode;
  final String body;

  DetailedApiRequestError._(this.statusCode, this.body);

  static void validateResponse(int statusCode, String responseBody) {
    if(statusCode >= 400) {
      throw new DetailedApiRequestError._(statusCode, responseBody);
    }
  }

  String toString() => '$statusCode - $body';
}


// NOTE NOTE NOTE NOTE NOTE NOTE NOTE:
// The following is comming from google_oauth2_client package


/** Produces part of a URL, when the template parameters are provided. */
typedef String _UrlPatternToken(Map<String, Object> params);

/** URL template with placeholders that can be filled in to produce a URL. */
class UrlPattern {
  final List<_UrlPatternToken> _tokens;

  /**
   * Creates a UrlPattern from the specification [:pattern:].
   * See http://tools.ietf.org/html/draft-gregorio-uritemplate-07
   * We only implement a very simple subset for now.
   */
  UrlPattern(String pattern) : _tokens = [] {
    var cursor = 0;
    while (cursor < pattern.length) {
      final open = pattern.indexOf("{", cursor);
      if (open < 0) {
        final rest = pattern.substring(cursor);
        _tokens.add((params) => rest);
        cursor = pattern.length;
      } else {
        if (open > cursor) {
          final intermediate = pattern.substring(cursor, open);
          _tokens.add((params) => intermediate);
        }
        final close = pattern.indexOf("}", open);
        if (close < 0) {
          throw new ArgumentError("Token meets end of text: $pattern");
        }
        String variable = pattern.substring(open + 1, close);
        _tokens.add((params) => (params[variable] == null)
            ? 'null'
            : Uri.encodeComponent(params[variable].toString()));
        cursor = close + 1;
      }
    }
  }

  /** Generate a URL with the specified list of URL and query parameters. */
  String generate(Map<String, Object> urlParams,
                  Map<String, Object> queryParams) {
    final buffer = new StringBuffer();
    _tokens.forEach((token) => buffer.write(token(urlParams)));
    var first = true;
    queryParams.forEach((key, value) {
      if (value == null) return;
      if (value is List) {
        value.forEach((listValue) {
          buffer.write(first ? '?' : '&');
          if (first) first = false;
          buffer.write(Uri.encodeComponent(key.toString()));
          buffer.write('=');
          buffer.write(Uri.encodeComponent(listValue.toString()));
        });
      } else {
        buffer.write(first ? '?' : '&');
        if (first) first = false;
        buffer.write(Uri.encodeComponent(key.toString()));
        buffer.write('=');
        buffer.write(Uri.encodeComponent(value.toString()));
      }
    });
    return buffer.toString();
  }

  static String generatePattern(String pattern, Map<String, Object> urlParams,
                                Map<String, Object> queryParams) {
    var urlPattern = new UrlPattern(pattern);
    return urlPattern.generate(urlParams, queryParams);
  }
}
""";

  static const _schemaArraySource =
r"""class SchemaArray<E> extends dart_collection.ListBase<E> {
  core.List innerList = new core.List();

  core.int get length => innerList.length;

  void set length(core.int length) {
    innerList.length = length;
  }

  void operator[]=(core.int index, E value) {
    innerList[index] = value;
  }

  E operator [](core.int index) => innerList[index];

  // Though not strictly necessary, for performance reasons
  // you should implement add and addAll.

  void add(E value) => innerList.add(value);

  void addAll(core.Iterable<E> all) => innerList.addAll(all);
}
""";

  static const _schemaAnyObjectSource =
r"""class SchemaAnyObject implements core.Map {
  core.Map innerMap = new core.Map();
  void clear() => innerMap.clear();
  core.bool containsKey(core.Object key) => innerMap.containsKey(key);
  core.bool containsValue(core.Object value) => innerMap.containsValue(value);
  void forEach(void f(key, value)) => innerMap.forEach(f);
  core.bool get isEmpty => innerMap.isEmpty;
  core.bool get isNotEmpty => innerMap.isNotEmpty;
  core.Iterable get keys => innerMap.keys;
  core.int get length => innerMap.length;
  putIfAbsent(key, ifAbsent()) => innerMap.putIfAbsent(key, ifAbsent);
  remove(core.Object key) => innerMap.remove(key);
  core.Iterable get values => innerMap.values;
  void addAll(core.Map other) => innerMap.addAll(other);
  operator [](core.Object key) => innerMap[key];
  void operator []=(key, value) { 
    innerMap[key] = value;
  }
}
""";
}
