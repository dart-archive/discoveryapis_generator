part of discovery_api_client_generator;

const String clientVersion = "0.1";
const String dartEnvironmentVersionConstraint = '>=0.5.20';
const String jsDependenciesVersionConstraint = '>=0.0.23';
const String googleOAuth2ClientVersionConstraint = '>=0.2.15';

class Generator {
  final RestDescription _description;
  final String _prefix;

  String get _libraryPubspecName {
    var prefix = (_prefix.isEmpty) ? '' : _prefix + "_";
    return cleanName("${prefix}${_name}_${_version}_api").toLowerCase();
  }

  factory Generator(String data, [String prefix = "google"]) {
    var json = JSON.parse(data);
    var description = new RestDescription.fromJson(json);

    // paranoid check of input
    assert(description.name != null);

    return new Generator.core(description, prefix);
  }

  Generator.core(this._description, this._prefix);

  String get _name => _description.name;
  String get _version => _description.version;

  String get _shortName => cleanName("${_name}_${_version}").toLowerCase();

  String get _libraryName => "${_shortName}_api_client";
  String get _gitName => "dart_${_libraryName}";

  String get _libraryBrowserName => "${_shortName}_api_browser";
  String get _libraryConsoleName => "${_shortName}_api_console";

  bool generateClient(String outputDirectory, {bool check: false, bool force: false, int forceVersion}) {
    var mainFolder = "$outputDirectory/$_gitName";
    var libFolder = "$mainFolder/lib";
    var srcFolder = "src";

    int clientVersionBuild = 0;
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
              print("Nothing changed for $_libraryName");
              return false;
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

    (new Directory("$libFolder/$srcFolder/client")).createSync(recursive: true);
    (new Directory("$libFolder/$srcFolder/browser")).createSync(recursive: true);
    (new Directory("$libFolder/$srcFolder/console")).createSync(recursive: true);
    (new Directory("$mainFolder/tool")).createSync(recursive: true);

    _writeString("$mainFolder/pubspec.yaml", _createPubspec(clientVersionBuild));

    _writeString("$mainFolder/LICENSE", _license);

    _writeFile("$mainFolder/README.md", _writeReadme);

    _writeString("$mainFolder/.gitignore", _gitIgnore);

    _writeString("$mainFolder/CONTRIBUTORS", _contributors);

    _writeString("$mainFolder/VERSION", _description.etag);

    // Create common library files

    _writeString("$libFolder/$_libraryName.dart", _createLibrary(srcFolder));

    _writeFile("$libFolder/$srcFolder/client/client.dart", _writeClientClass);

    _writeFile("$libFolder/$srcFolder/client/schemas.dart", _writeSchemas);

    _writeFile("$libFolder/$srcFolder/client/resources.dart", _writeResources);

    // Create browser versions of the libraries
    _writeString("$libFolder/$_libraryBrowserName.dart", _createBrowserLibrary(srcFolder));

    _writeString("$libFolder/$srcFolder/browser/browser_client.dart", _createBrowserClientClass);

    _writeFile("$libFolder/$srcFolder/browser/$_name.dart", _writeBrowserMainClass);

    // Create console versions of the libraries
    _writeString("$libFolder/$_libraryConsoleName.dart", _createConsoleLibrary(srcFolder));

    _writeString("$libFolder/$srcFolder/console/console_client.dart", _createConsoleClientClass);

    _writeFile("$libFolder/$srcFolder/console/$_name.dart", _writeConsoleMainClass);

    // Create hop_runner for the libraries
    _writeString("$mainFolder/tool/hop_runner.dart", _createHopRunner);

    print("Library $_libraryName generated successfully.");
    return true;
  }

  String _createPubspec(int clientVersionBuild) => """
name: $_libraryPubspecName
version: $clientVersion.$clientVersionBuild
authors:
- Gerwin Sturm <scarygami@gmail.com>
- Adam Singer <financeCoding@gmail.com>
description: Auto-generated client library for accessing the $_name $_version API
homepage: https://github.com/dart-gde/discovery_api_dart_client_generator
environment:
  sdk: '${dartEnvironmentVersionConstraint}'
dependencies:
  google_oauth2_client: '${googleOAuth2ClientVersionConstraint}'
  js: '${jsDependenciesVersionConstraint}'
dev_dependencies:
  hop: any
""";

  void _writeReadme(StringSink sink) {
    sink.write("""
# $_libraryPubspecName

### Description

Auto-generated client library for accessing the $_name $_version API.

""");
    sink.write("#### ");
    if (_description.icons != null && _description.icons.x16 != null) {
      sink.write("![Logo](${_description.icons.x16}) ");
    }
    sink.write("${_description.title} - $_name $_version\n\n");
    sink.write("${_description.description}\n\n");
    if (_description.documentationLink != null) {
      sink.write("Official API documentation: ${_description.documentationLink}\n\n");
    }
    sink.write("For web applications:\n```\nimport \"package:$_libraryPubspecName/$_libraryBrowserName.dart\" as ${cleanName(_name).toLowerCase()}client;\n```\n\n");
    sink.write("For console application:\n```\nimport \"package:$_libraryPubspecName/$_libraryConsoleName.dart\" as ${cleanName(_name).toLowerCase()}client;\n```\n\n");

    sink.write("```\nvar ${cleanName(_name).toLowerCase()} = new ${cleanName(_name).toLowerCase()}client.${capitalize(_name)}();\n```\n\n");
    sink.write("### Licenses\n\n```\n");
    sink.write(_license);
    sink.write("```\n");
  }

  String _createLibrary(String srcFolder) => """
library $_libraryName;

import "dart:core" as core;
import "dart:async" as async;
import "dart:json" as JSON;
import 'dart:collection' as dart_collection;

part "$srcFolder/client/client.dart";
part "$srcFolder/client/schemas.dart";
part "$srcFolder/client/resources.dart";
""";

  String _createBrowserLibrary(String srcFolder) => """
library $_libraryBrowserName;

import "$_libraryName.dart";
export "$_libraryName.dart";

import "dart:core" as core;
import "dart:html" as html;
import "dart:async" as async;
import "dart:json" as JSON;
import "package:js/js.dart" as js;
import "package:google_oauth2_client/google_oauth2_browser.dart" as oauth;

part "$srcFolder/browser/browser_client.dart";
part "$srcFolder/browser/$_name.dart";
""";

  String _createConsoleLibrary(String srcFolder) => """
library $_libraryConsoleName;

import "$_libraryName.dart";
export "$_libraryName.dart";

import "dart:core" as core;
import "dart:io" as io;
import "dart:async" as async;
import "dart:json" as JSON;
import "package:http/http.dart" as http;
import "package:google_oauth2_client/google_oauth2_console.dart" as oauth2;

part "$srcFolder/console/console_client.dart";
part "$srcFolder/console/$_name.dart";
""";

  void _writeSchemas(StringSink sink) {
    sink.write("part of $_libraryName;\n\n");

    if (_description.schemas != null) {
      _description.schemas.forEach((String key, JsonSchema schema) {
        _writeSchemaClass(sink, key, schema);
      });

      sink.write(_mapMapFunction);
    }
  }

  void _writeResources(StringSink sink) {
    sink.writeln("part of $_libraryName;");
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
        sink.write("\n");
        if (scopes.description != null) {
          sink.write("  /** OAuth Scope2: ${scopes.description} */\n");
        } else {
          sink.write("  /** OAuth Scope2 */\n");
        }
        sink.write("  static const core.String ${scopeName}_SCOPE = \"$name\";\n");
      });
    }
  }

  void _writeBrowserMainClass(StringSink sink) {
    sink.write("part of $_libraryBrowserName;\n\n");
    sink.write("/** Client to access the $_name $_version API */\n");
    if (_description.description != null) {
      sink.write("/** ${_description.description} */\n");
    }
    sink.write("class ${capitalize(_name)} extends BrowserClient {\n");
    _writeScopes(sink);
    sink.writeln();
    sink.writeln('  final oauth.OAuth2 auth;');
    sink.writeln();
    sink.writeln("  ${capitalize(_name)}([oauth.OAuth2 this.auth]);");

    sink.write("}\n");
  }

  void _writeConsoleMainClass(StringSink sink) {
    sink.write("part of $_libraryConsoleName;\n\n");
    sink.write("/** Client to access the $_name $_version API */\n");
    if (_description.description != null) {
      sink.write("/** ${_description.description} */\n");
    }
    sink.write("class ${capitalize(_name)} extends ConsoleClient {\n");
    _writeScopes(sink);

    sink.writeln();
    sink.writeln('  final oauth2.OAuth2Console auth;');
    sink.writeln();
    sink.writeln("  ${capitalize(_name)}([oauth2.OAuth2Console this.auth]);");

    sink.write("}\n");
  }

  String get _rootUriOrigin => Uri.parse(_description.rootUrl).origin;

  void _writeClientClass(StringSink sink) {
    sink.write("""part of $_libraryName;

/**
 * Base class for all API clients, offering generic methods for HTTP Requests to the API
 */
abstract class Client {
  core.String basePath = \"${_description.basePath}\";
  core.String rootUrl = \"${_rootUriOrigin}/\";
  core.bool makeAuthRequests = false;
  final core.Map params = {};

  static const _boundary = "-------314159265358979323846";
  static const _delimiter = "\\r\\n--\$_boundary\\r\\n";
  static const _closeDelim = "\\r\\n--\$_boundary--";

  /**
   * Sends a HTTPRequest using [method] (usually GET or POST) to [requestUrl] using the specified [urlParams] and [queryParams]. Optionally include a [body] in the request.
   */
  async.Future request(core.String requestUrl, core.String method, {core.String body, core.String contentType:"application/json", core.Map urlParams, core.Map queryParams});

  /**
   * Joins [content] (encoded as Base64-String) with specified [contentType] and additional request [body] into one multipart-body and send a HTTPRequest with [method] (usually POST) to [requestUrl]
   */
  async.Future upload(core.String requestUrl, core.String method, core.String body, core.String content, core.String contentType, {core.Map urlParams, core.Map queryParams}) {
    var multiPartBody = new core.StringBuffer();
    if (contentType == null || contentType.isEmpty) {
      contentType = "application/octet-stream";
    }
    multiPartBody
    ..write(_delimiter)
    ..write("Content-Type: application/json\\r\\n\\r\\n")
    ..write(body)
    ..write(_delimiter)
    ..write("Content-Type: ")
    ..write(contentType)
    ..write("\\r\\n")
    ..write("Content-Transfer-Encoding: base64\\r\\n")
    ..write("\\r\\n")
    ..write(content)
    ..write(_closeDelim);

    return request(requestUrl, method, body: multiPartBody.toString(), contentType: "multipart/mixed; boundary=\\"\$_boundary\\"", urlParams: urlParams, queryParams: queryParams);
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
        sink.write("\n");
        sink.write("  /**\n");
        if (param.description != null) {
          sink.write("   * ${param.description}\n");
        }
        sink.write("   * Added as queryParameter for each request.\n");
        sink.write("   */\n");
        sink.write("  $type get $key => params[\"$key\"];\n");
        sink.write("  set $key($type value) => params[\"$key\"] = value;\n");
      });
    }

    if (_description.methods != null) {
      sink.writeln("""

  //
  // Methods
  //""");
      _description.methods.forEach((String key, RestMethod method) {
        sink.write("\n");
        _writeMethod(sink, key, method, true);
      });
    }

    sink.write("""
}

/// Base-class for all API Resources
abstract class Resource {
  /// The [Client] to be used for all requests
  final Client _client;

  /// Create a new Resource, using the specified [Client] for requests
  Resource(Client this._client);
}

/// Exception thrown when the HTTP Request to the API failed
class APIRequestException implements core.Exception {
  final core.String msg;
  const APIRequestException([this.msg]);
  core.String toString() => (msg == null) ? "APIRequestException" : "APIRequestException: \$msg";
}
""");
  }

  String get _createBrowserClientClass => """
part of $_libraryBrowserName;

/**
 * Base class for all Browser API clients, offering generic methods for HTTP Requests to the API
 */
abstract class BrowserClient extends Client {

  oauth.OAuth2 get auth;
  core.bool _jsClientLoaded = false;

  /**
   * Loads the JS Client Library to make CORS-Requests
   */
  async.Future<core.bool> _loadJsClient() {
    var completer = new async.Completer();

    if (_jsClientLoaded) {
      completer.complete(true);
      return completer.future;
    }

    js.scoped((){
      js.context["handleClientLoad"] =  new js.Callback.once(() {
        _jsClientLoaded = true;
        completer.complete(true);
      });
    });

    html.ScriptElement script = new html.ScriptElement();
    script.src = "http://apis.google.com/js/client.js?onload=handleClientLoad";
    script.type = "text/javascript";
    html.document.body.children.add(script);

    return completer.future;
  }

  /**
   * Makes a request via the JS Client Library to circumvent CORS-problems
   */
  async.Future _makeJsClientRequest(core.String requestUrl, core.String method, {core.String body, core.String contentType, core.Map queryParams}) {
    var completer = new async.Completer();
    var requestData = new core.Map();
    requestData["path"] = requestUrl;
    requestData["method"] = method;
    requestData["headers"] = new core.Map();

    if (queryParams != null) {
      requestData["params"] = queryParams;
    }

    if (body != null) {
      requestData["body"] = body;
      requestData["headers"]["Content-Type"] = contentType;
    }
    if (makeAuthRequests && auth != null && auth.token != null) {
      requestData["headers"]["Authorization"] = "\${auth.token.type} \${auth.token.data}";
    }

    js.scoped(() {
      var request = js.context["gapi"]["client"]["request"](js.map(requestData));
      var callback = new js.Callback.once((jsonResp, rawResp) {
        if (jsonResp == null || (jsonResp is core.bool && jsonResp == false)) {
          var raw = JSON.parse(rawResp);
          if (raw["gapiRequest"]["data"]["status"] >= 400) {
            completer.completeError(new APIRequestException("JS Client - \${raw["gapiRequest"]["data"]["status"]} \${raw["gapiRequest"]["data"]["statusText"]} - \${raw["gapiRequest"]["data"]["body"]}"));
          } else {
            completer.complete({});
          }
        } else {
          completer.complete(js.context["JSON"]["stringify"](jsonResp));
        }
      });
      request.execute(callback);
    });

    return completer.future;
  }

  /**
   * Sends a HTTPRequest using [method] (usually GET or POST) to [requestUrl] using the specified [urlParams] and [queryParams]. Optionally include a [body] in the request.
   */
  async.Future request(core.String requestUrl, core.String method, {core.String body, core.String contentType:"application/json", core.Map urlParams, core.Map queryParams}) {
    var request = new html.HttpRequest();
    var completer = new async.Completer();

    if (urlParams == null) urlParams = {};
    if (queryParams == null) queryParams = {};

    params.forEach((key, param) {
      if (param != null && queryParams[key] == null) {
        queryParams[key] = param;
      }
    });

    var path;
    if (requestUrl.substring(0,1) == "/") {
      path ="\$rootUrl\${requestUrl.substring(1)}";
    } else {
      path ="\$rootUrl\${basePath.substring(1)}\$requestUrl";
    }
    var url = new oauth.UrlPattern(path).generate(urlParams, queryParams);

    void handleError() {
      if (request.status == 0) {
        _loadJsClient().then((v) {
          if (requestUrl.substring(0,1) == "/") {
            path = requestUrl;
          } else {
            path ="\$basePath\$requestUrl";
          }
          url = new oauth.UrlPattern(path).generate(urlParams, {});
          _makeJsClientRequest(url, method, body: body, contentType: contentType, queryParams: queryParams)
            .then((response) {
              var data = JSON.parse(response);
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
            errorJson = JSON.parse(request.responseText);
          } on core.FormatException {
            errorJson = null;
          }
          if (errorJson != null && errorJson.containsKey("error")) {
            error = "\${errorJson["error"]["code"]} \${errorJson["error"]["message"]}";
          }
        }
        if (error == "") {
          error = "\${request.status} \${request.statusText}";
        }
        completer.completeError(new APIRequestException(error));
      }
    }

    request.onLoad.listen((_) {
      if (request.status > 0 && request.status < 400) {
        var data = {};
        if (!request.responseText.isEmpty) {
          data = JSON.parse(request.responseText);
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

  String get _createConsoleClientClass => """
part of $_libraryConsoleName;

/**
 * Base class for all Console API clients, offering generic methods for HTTP Requests to the API
 */
abstract class ConsoleClient extends Client {

  oauth2.OAuth2Console get auth;

  /**
   * Sends a HTTPRequest using [method] (usually GET or POST) to [requestUrl] using the specified [urlParams] and [queryParams]. Optionally include a [body] in the request.
   */
  async.Future<core.Map<core.String, core.Object>> request(core.String requestUrl, core.String method, {core.String body, core.String contentType:"application/json", core.Map urlParams, core.Map queryParams}) {
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
      path ="\$rootUrl\${requestUrl.substring(1)}";
    } else {
      path ="\$rootUrl\${basePath.substring(1)}\$requestUrl";
    }

    var url = new oauth2.UrlPattern(path).generate(urlParams, queryParams);
    var uri = core.Uri.parse(url);

    if (makeAuthRequests && auth != null) {
      // Client wants an authenticated request.
      return auth.withClient((r) => _request(r, method, uri, contentType, body));
    } else {
      // Client wants a non authenticated request.
      return _request(new http.Client(), method, uri, contentType, body);
    }
  }

  async.Future<core.Map<core.String, core.Object>> _request(http.Client client, core.String method, core.Uri uri,
                        core.String contentType, core.String body) {
    var request = new http.Request(method, uri)
      ..headers[io.HttpHeaders.CONTENT_TYPE] = contentType;

    if(body != null) {
      request.body = body;
    }

    return client.send(request)
        .then(http.Response.fromStream)
        .then((http.Response response) {
          if(response.body.isEmpty) {
            return null;
          }
          return JSON.parse(response.body);
        })
        .whenComplete(() {
          client.close();
        });
  }
}
""";

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
}
