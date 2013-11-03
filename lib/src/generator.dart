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

  String get _libraryBrowserName => "${_shortName}_api_browser";
  String get _libraryConsoleName => "${_shortName}_api_console";

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
          clientVersionBuild = (forceVersion != null) ? forceVersion : int.parse(version.substring(clientVersion.length + 1)) + 1;
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
    (new Directory("$mainFolder/tool")).createSync(recursive: true);

    _writeFile("$mainFolder/pubspec.yaml", (sink) => _writePubspec(sink, clientVersionBuild));

    _writeString("$mainFolder/LICENSE", _license);

    _writeFile("$mainFolder/README.md", (sink) => _writeReadme(sink, clientVersionBuild));

    _writeString("$mainFolder/.gitignore", _gitIgnore);

    _writeString("$mainFolder/CONTRIBUTORS", _contributors);

    _writeString("$mainFolder/VERSION", _description.etag);

    // Create cloud api files

    _writeString("$libFolder/src/client_base.dart", _CLOUD_API_SOURCE);
    _writeString("$libFolder/src/browser_client.dart", _CLOUD_API_BROWSER_SOURCE);
    _writeString("$libFolder/src/console_client.dart", _CLOUD_API_CONSOLE_SOURCE);

    // Create common library files

    _writeString("$libFolder/$_libraryName.dart", _createLibrary);

    _writeFile("$libFolder/src/client/client.dart", _writeClientClass);

    _writeFile("$libFolder/src/client/schemas.dart", _writeSchemas);

    _writeFile("$libFolder/src/client/resources.dart", _writeResources);

    // Create browser versions of the libraries
    _writeFile("$libFolder/$_libraryBrowserName.dart", _writeBrowserLibrary);

    // Create console versions of the libraries
    _writeFile("$libFolder/$_libraryConsoleName.dart", _writeConsoleLibrary);

    // Create hop_runner for the libraries
    _writeString("$mainFolder/tool/hop_runner.dart", _createHopRunner);

    print("Library $_libraryName generated successfully.");
    return new GenerateResult._(_name, _version, mainFolder);
  }

  void _writePubspec(StringSink sink, int clientVersionBuild) {
    sink.writeln("name: $_libraryPubspecName");
    sink.writeln("version: ${_config.getLibraryVersion(clientVersionBuild)}");

    sink.writeln("authors:");
    forEachOrdered(_config.authors, (String name, String email) {
      sink.writeln("- $name <$email>");
    });

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
    sink.writeln('For web applications:\n\n```\n  import \"package:$_libraryPubspecName/$_libraryBrowserName.dart\" as ${cleanName(_name).toLowerCase()}client;\n```');
    sink.writeln();
    sink.writeln('For console application:\n\n```\n  import \"package:$_libraryPubspecName/$_libraryConsoleName.dart\" as ${cleanName(_name).toLowerCase()}client;\n```');
    sink.writeln();

    sink.writeln('Working with out authentication the following constructor can be called:\n\n```\n  var ${cleanName(_name).toLowerCase()} = new ${cleanName(_name).toLowerCase()}client.${capitalize(_name)}();\n```');
    sink.writeln();
    sink.writeln('Working with authentication then create a new `GoogleOAuth2` object and pass it to the constructor:\n\n');
    sink.writeln('```\n  GoogleOAuth2 auth = new GoogleOAuth2(CLIENT_ID, SCOPES);\n  var ${cleanName(_name).toLowerCase()} = new ${cleanName(_name).toLowerCase()}client.${capitalize(_name)}(auth);\n```');
    sink.writeln();
    sink.writeln('### Licenses\n\n```');
    sink.write(_license);
    sink.writeln('```');
  }

  String get _createLibrary => """
library ${_shortName}_api;

import "dart:core" as core;
import "dart:async" as async;
import "dart:convert";
import 'dart:collection' as dart_collection;

import 'package:$_libraryPubspecName/src/client_base.dart';
export 'package:$_libraryPubspecName/src/client_base.dart' show APIRequestError;

part 'src/client/client.dart';
part 'src/client/schemas.dart';
part 'src/client/resources.dart';
""";

  void _writeBrowserLibrary(StringSink sink) {
    sink.write("""
library ${_shortName}_api.browser;

import "package:google_oauth2_client/google_oauth2_browser.dart" as oauth;

import 'package:$_libraryPubspecName/src/browser_client.dart';
import "package:$_libraryPubspecName/$_libraryName.dart";

""");

    if (_description.description != null) {
      sink.writeln('/** ${_description.description} */');
    } else {
      sink.writeln('/** Client to access the $_name $_version API */');
    }
    sink.writeln('class ${capitalize(_name)} extends Client with BrowserClient {');
    _writeScopes(sink);
    sink.writeln();
    sink.writeln('  final oauth.OAuth2 auth;');
    sink.writeln();
    sink.writeln("  ${capitalize(_name)}([oauth.OAuth2 this.auth]);");

    sink.writeln('}');
  }

  void _writeConsoleLibrary(StringSink sink) {
    sink.write("""
library ${_shortName}_api.console;

import "package:google_oauth2_client/google_oauth2_console.dart" as oauth2;

import 'package:$_libraryPubspecName/src/console_client.dart';

import "package:$_libraryPubspecName/$_libraryName.dart";

""");

    if (_description.description != null) {
      sink.writeln('/** ${_description.description} */');
    } else {
      sink.writeln('/** Client to access the $_name $_version API */');
    }
    sink.writeln('class ${capitalize(_name)} extends Client with ConsoleClient {');
    _writeScopes(sink);

    sink.writeln();
    sink.writeln('  final oauth2.OAuth2Console auth;');
    sink.writeln();
    sink.writeln("  ${capitalize(_name)}([oauth2.OAuth2Console this.auth]);");

    sink.writeln('}');
  }

  void _writeSchemas(StringSink sink) {
    sink.writeln("part of ${_shortName}_api;");
    sink.writeln();

    if (_description.schemas != null) {
      _description.schemas.forEach((String key, JsonSchema schema) {
        _writeSchemaClass(sink, key, schema);
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

  void _writeClientClass(StringSink sink) {
    sink.write("""part of ${_shortName}_api;

abstract class Client extends ClientBase {
  core.String basePath = \"${_description.basePath}\";
  core.String rootUrl = \"${_rootUriOrigin}/\";

""");

    if (_description.resources != null) {
      sink.writeln("""
  //
  // Resources
  //
""");
      _description.resources.forEach((key, resource) {
        var subClassName = "${capitalize(key)}Resource_";
        sink.writeln("  $subClassName get $key => new $subClassName(this);");
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
        sink.writeln('  $type get $key => params[\"$key\"];');
        sink.writeln('  set $key($type value) => params[\"$key\"] = value;');
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

  String get _createHopRunner => """
library hop_runner;

import 'package:hop/hop.dart';
import 'package:hop/hop_tasks.dart';

void main() {

  List pathList = [
    'lib/$_libraryBrowserName.dart',
    'lib/$_libraryConsoleName.dart',
    'lib/$_libraryName.dart'
  ];

  addTask('docs', createDartDocTask(pathList, linkApi: true));

  addTask('analyze', createAnalyzerTask(pathList));

  runHop();
}
""";

  static const _CLOUD_API_SOURCE = r"""
library cloud_api;

import "dart:async";
import "dart:convert";

// TODO: look into other ways of building out the multiPartBody

/**
 * Base class for all API clients, offering generic methods for HTTP Requests to the API
 */
abstract class ClientBase {
  String get basePath;
  String get rootUrl;
  bool makeAuthRequests = false;
  final Map params = {};

  static const _boundary = "-------314159265358979323846";
  static const _delimiter = "\r\n--$_boundary\r\n";
  static const _closeDelim = "\r\n--$_boundary--";

  /**
   * Sends a HTTPRequest using [method] (usually GET or POST) to [requestUrl] using the specified [urlParams] and [queryParams]. Optionally include a [body] in the request.
   */
  Future<Map<String, dynamic>> request(String requestUrl, String method, {String body, String contentType:"application/json", Map urlParams, Map queryParams});

  /**
   * Joins [content] (encoded as Base64-String) with specified [contentType] and additional request [body] into one multipart-body and send a HTTPRequest with [method] (usually POST) to [requestUrl]
   */
  Future<Map<String, dynamic>> upload(String requestUrl, String method, String body, String content, String contentType, {Map urlParams, Map queryParams}) {
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

    return request(requestUrl, method, body: multiPartBody.toString(), contentType: "multipart/mixed; boundary=\"$_boundary\"", urlParams: urlParams, queryParams: queryParams);
  }

  static Map<String, dynamic> responseParse(int statusCode, String responseBody) {
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
  String toString() => (message == null) ? "APIRequestException" : "APIRequestException: $message";
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
""";

  static const _CLOUD_API_BROWSER_SOURCE = r"""library cloud_api.browser;

import "dart:async";
import "dart:html" as html;
import "dart:convert";
import "dart:js" as js;
import "package:google_oauth2_client/google_oauth2_browser.dart" as oauth;

import 'client_base.dart';

/**
 * Base class for all Browser API clients, offering generic methods for HTTP Requests to the API
 */
abstract class BrowserClient implements ClientBase {

  static const _corsCallback = 'handleCLientLoad';

  oauth.OAuth2 get auth;
  bool _jsClientLoaded = false;

  /**
   * Loads the JS Client Library to make CORS-Requests
   */
  Future _loadJsClient() {

    if (_jsClientLoaded) {
      return new Future.value();
    }

    var completer = new Completer();

    js.context[_corsCallback] =  () {
      _jsClientLoaded = true;
      completer.complete();
    };

    html.ScriptElement script = new html.ScriptElement();
    script.src = "https://apis.google.com/js/client.js?onload=$_corsCallback";
    script.type = "text/javascript";
    html.document.body.children.add(script);

    return completer.future;
  }

  /**
   * Makes a request via the JS Client Library to circumvent CORS-problems
   */
  Future<Map<String, dynamic>> _makeJsClientRequest(String requestUrl, String method, {String body, String contentType, Map queryParams}) {
    var requestData = new Map();
    requestData["path"] = requestUrl;
    requestData["method"] = method;
    requestData["headers"] = new Map();

    if (queryParams != null) {
      requestData["params"] = queryParams;
    }

    if (body != null) {
      requestData["body"] = body;
      requestData["headers"]["Content-Type"] = contentType;
    }
    if (makeAuthRequests && auth != null && auth.token != null) {
      requestData["headers"]["Authorization"] = "${auth.token.type} ${auth.token.data}";
    }

    var completer = new Completer();
    var request = js.context["gapi"]["client"].callMethod("request", 
      [new js.JsObject.jsify(requestData)]);
    var callback = (jsonResp, rawResp) {
      if (jsonResp == null || (jsonResp is bool && jsonResp == false)) {
        var raw = JSON.decode(rawResp);
        if (raw["gapiRequest"]["data"]["status"] >= 400) {
          completer.completeError(new APIRequestError("JS Client - ${raw["gapiRequest"]["data"]["status"]} ${raw["gapiRequest"]["data"]["statusText"]} - ${raw["gapiRequest"]["data"]["body"]}"));
        } else {
          completer.complete({});
        }
      } else {
        completer.complete(js.context["JSON"].callMethod("stringify", [jsonResp]));
      }
    };
    request.execute(callback);

    return completer.future;
  }

  /**
   * Sends a HTTPRequest using [method] (usually GET or POST) to [requestUrl] using the specified [urlParams] and [queryParams]. Optionally include a [body] in the request.
   */
  Future<Map<String, dynamic>> request(String requestUrl, String method, {String body, String contentType:"application/json", Map urlParams, Map queryParams}) {

    if (urlParams == null) urlParams = {};
    if (queryParams == null) queryParams = {};

    params.forEach((key, param) {
      if (param != null && queryParams[key] == null) {
        queryParams[key] = param;
      }
    });

    var path;
    if (requestUrl.substring(0,1) == "/") {
      path ="$rootUrl${requestUrl.substring(1)}";
    } else {
      path ="$rootUrl${basePath.substring(1)}$requestUrl";
    }
    var url = oauth.UrlPattern.generatePattern(path, urlParams, queryParams);

    var request = new html.HttpRequest();
    var completer = new Completer();

    void handleError() {
      if (request.status == 0) {
        _loadJsClient().then((v) {
          if (requestUrl.substring(0,1) == "/") {
            path = requestUrl;
          } else {
            path ="$basePath$requestUrl";
          }
          url = oauth.UrlPattern.generatePattern(path, urlParams, {});
          _makeJsClientRequest(url, method, body: body, contentType: contentType, queryParams: queryParams)
            .then((response) {
              var data = JSON.decode(response);
              completer.complete(data);
            })
            .catchError((e) {
              completer.completeError(e);
              return true;
            });
        });
      } else {
        var error = "";
        if (request.responseText != null) {
          var errorJson;
          try {
            errorJson = JSON.decode(request.responseText);
          } on FormatException {
            errorJson = null;
          }
          if (errorJson != null && errorJson.containsKey("error")) {
            error = "${errorJson["error"]["code"]} ${errorJson["error"]["message"]}";
          }
        }
        if (error == "") {
          error = "${request.status} ${request.statusText}";
        }
        completer.completeError(new APIRequestError(error));
      }
    }

    request.onLoad.listen((_) {
      if (request.status > 0 && request.status < 400) {
        var data = {};
        if (!request.responseText.isEmpty) {
          data = JSON.decode(request.responseText);
        }
        completer.complete(data);
      } else {
        handleError();
      }
    });

    request.onError.listen((_) => handleError());

    request.open(method, url);
    request.setRequestHeader("Content-Type", contentType);
    if (makeAuthRequests && auth != null) {
      auth.authenticate(request).then((request) => request.send(body));
    } else {
      request.send(body);
    }

    return completer.future;
  }
}
""";

  static const _CLOUD_API_CONSOLE_SOURCE = r"""library cloud_api.console;

import "dart:io";
import "dart:async";
import "package:http/http.dart";
import "package:google_oauth2_client/google_oauth2_console.dart" as oauth2;

import 'client_base.dart';

/**
 * Base class for all Console API clients, offering generic methods for HTTP Requests to the API
 */
abstract class ConsoleClient implements ClientBase {

  oauth2.OAuth2Console get auth;

  /**
   * Sends a HTTPRequest using [method] (usually GET or POST) to [requestUrl] using the specified [urlParams] and [queryParams]. Optionally include a [body] in the request.
   */
  Future<Map<String, dynamic>> request(String requestUrl, String method, {String body, String contentType:"application/json", Map urlParams, Map queryParams}) {
    if (urlParams == null) urlParams = {};
    if (queryParams == null) queryParams = {};

    params.forEach((key, param) {
      if (param != null && queryParams[key] == null) {
        queryParams[key] = param;
      }
    });

    method = method.toLowerCase();

    var path;
    if (requestUrl.substring(0,1) == "/") {
      path ="$rootUrl${requestUrl.substring(1)}";
    } else {
      path ="$rootUrl${basePath.substring(1)}$requestUrl";
    }

    var url = new oauth2.UrlPattern(path).generate(urlParams, queryParams);
    var uri = Uri.parse(url);

    if (makeAuthRequests && auth != null) {
      // Client wants an authenticated request.
      return auth.withClient((r) => _request(r, method, uri, contentType, body));
    } else {
      // Client wants a non authenticated request.
      return _request(new Client(), method, uri, contentType, body);
    }
  }

  Future<Map<String, Object>> _request(Client httpClient, String method, Uri uri,
                        String contentType, String body) {
    var request = new Request(method, uri)
      ..headers[HttpHeaders.CONTENT_TYPE] = contentType;

    if(body != null) {
      request.body = body;
    }

    return httpClient.send(request)
        .then(Response.fromStream)
        .then((Response response) {
          return ClientBase.responseParse(response.statusCode, response.body);
        })
        .whenComplete(() {
          httpClient.close();
        });
  }
}
""";
}
