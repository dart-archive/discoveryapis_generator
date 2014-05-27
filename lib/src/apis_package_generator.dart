part of discovery_api_client_generator;

/// Generates a dart package with all APIs given in the constructor.
///
/// This class generates a dart package with the following layout:
/// $packageFolderPath
///   |- .gitignore
///   |- pubspec.yaml
///   |- LICENSE
///   |- README.md
///   |- VERSION
///   |- lib/src/... (containing shared code)
///   |- lib/$API/... (for all APIs to generate)
///
/// It will use [ApiLibraryGenerator] to generate the APIs themselves.
class ApisPackageGenerator {
  final List<RestDescription> descriptions;
  final String packageFolderPath;
  final Config config;

  /// [descriptions] is a list of API descriptions we want to generate code for.
  /// [config] contains configuration parameters for this API package generator.
  /// [packageFolderPath] is the output directory where the dart package gets
  /// generated.
  ApisPackageGenerator(this.descriptions, this.config, this.packageFolderPath);

  /// Starts generating the API package with all the APIs given in the
  /// constructor.
  /// If the output directory already exists it will delete everything in it
  /// except ".git" folders.
  List<GenerateResult> generateApiPackage() {
    var libFolderPath = "$packageFolderPath/lib";
    var srcFolderPath = "$packageFolderPath/lib/src";

    var pubspecYamlPath = "$packageFolderPath/pubspec.yaml";
    var licensePath = "$packageFolderPath/LICENSE";
    var readmePath = "$packageFolderPath/README.md";
    var versionPath = "$packageFolderPath/VERSION";
    var gitIgnorePath = "$packageFolderPath/.gitignore";
    var commonInternalLibraryPath = "$libFolderPath/src/client_base.dart";
    var commonInternalLibraryUri = "../src/client_base.dart";

    // Clean contents of directory (except for .git folder)
    var packageDirectory = new Directory(packageFolderPath);
    if (packageDirectory.existsSync()) {
      print("Emptying folder before library generation.");
      packageDirectory.listSync().forEach((FileSystemEntity fse) {
        if (fse is File) {
          fse.deleteSync();
        } else if (fse is Directory && !fse.path.endsWith(".git")) {
          fse.deleteSync(recursive: true);
        }
      });
    }

    new Directory(libFolderPath).createSync(recursive: true);
    new Directory(srcFolderPath).createSync(recursive: true);

    _writeFile(pubspecYamlPath, _writePubspec);

    _writeString(licensePath, _license);

    _writeFile(readmePath, _writeReadme);

    _writeString(gitIgnorePath, _gitIgnore);

    // This library is used by all APIs for making requests.
    _writeString(commonInternalLibraryPath, _CLOUD_API_SOURCE);

    // TODO(kustermann):
    // _writeString(versionPath, _description.etag);

    var results = <GenerateResult>[];
    for (RestDescription description in descriptions) {
      String name = description.name.toLowerCase();
      String version = description.version.toLowerCase()
          .replaceAll('.', '_').replaceAll('-', '_');

      String libraryName = "googleapis.$name.$version";
      String apiFolderPath = "$libFolderPath/$name";
      String apiVersionFile = "$libFolderPath/$name/$version.dart";

      new Directory(apiFolderPath).createSync();

      var apiGenerator = new ApiLibraryGenerator(
          description, libraryName, commonInternalLibraryUri);
      apiGenerator.generateClient(apiVersionFile);
      var result = new GenerateResult(name, version,
          'package:googleapis/${apiVersionFile.replaceFirst('lib/', '')}');
      results.add(result);
    }
    return results;
  }

  void _writePubspec(StringSink sink) {
    sink.writeln("name: ${config.name}");
    sink.writeln("version: ${config.version}");
    sink.writeln("author: Dart Team <misc@dartlang.org>");
    sink.writeln("description: Auto-generated client libraries for accessing "
                 "the following APIS.\n"
                 "TODO(kustermann): insert all apis here.");
    sink.writeln("homepage: https://github.com/dart-lang/"
                 "discovery_api_dart_client_generator");
    sink.writeln("environment:");
    sink.writeln("  sdk: '${config.sdkConstraint}'");
    sink.writeln("dependencies:");
    forEachOrdered(config.dependencies, (String lib, Object value) {
      if (value is String) {
        sink.writeln("  $lib: $value");
      } else if (value is Map) {
        sink.writeln("  $lib:\n");
        value.forEach((k, v) {
          sink.writeln("    $k: $v\n");
        });
      }
    });
  }

  void _writeReadme(StringSink sink) {
    sink.write("""
# ${config.name}

### Description

Auto-generated client libraries for accessing Google APIs.

### Usage

Adding dependency to pubspec.yaml

```
  dependencies:
    googleapis: any
```

TODO(kustermann):
Add instructions on how to get an authenticated client.

Import API and use it, e.g.

```
  import 'package:googleapis/drive/v1.dart' as drive_api;

  main() {
    var drive = new drive_api.Drive();
    // TODO(kustermann: Make a real example here.
    drive.list().then((List<Files> files) {
    });
  }

```

');


""");
    for (RestDescription description in descriptions) {
      sink.write("#### ");
      if (description.icons != null && description.icons.x16 != null) {
        sink.write("![Logo](${description.icons.x16}) ");
      }
      sink.writeln(
          '${description.title} - ${description.name} ${description.version}');
      sink.writeln();
      sink.writeln('${description.description}');
      sink.writeln();
      if (description.documentationLink != null) {
        sink.writeln(
            'Official API documentation: ${description.documentationLink}');
        sink.writeln();
      }
    }
    sink.writeln('### Licenses\n\n```');
    sink.write(_license);
    sink.writeln('```');
  }


  static const _CLOUD_API_SOURCE = r"""
library cloud_api;

import "dart:async";
import "dart:convert";

import "package:http_base/http_base.dart" as http_base;

class HeadersImpl implements http_base.Headers {
  final Map<String, List<String>> _m;

  HeadersImpl(this._m);

  Iterable<String> get names => _m.keys;

  bool contains(String name) =>  _m.containsKey(name);

  String operator [](String name) {
    var values = _m[name];
    if (values == null) return null;
    if (values.length == 1) return values.first;
    return values.join('');
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
 * Base class for all API clients, offering generic methods for
 * HTTP Requests to the API
 */
class ApiRequester {
  bool makeAuthRequests = false;

  final http_base.Client _httpClient;
  final Map<String, Object> _optionalQueryAdditions;
  final String _rootUrl;
  final String _basePath;

  ApiRequester(this._httpClient, this._optionalQueryAdditions, this._rootUrl,
               this._basePath);

  static const _boundary = "-------314159265358979323846";
  static const _delimiter = "\r\n--$_boundary\r\n";
  static const _closeDelim = "\r\n--$_boundary--";

  /**
   * Sends a HTTPRequest using [method] (usually GET or POST) to [requestUrl]
   * using the specified [urlParams] and [queryParams]. Optionally include a
   * [body] in the request.
   */
  Future<Map<String, dynamic>> request(String requestUrl, String method,
        {String body, String contentType:"application/json", Map urlParams,
         Map queryParams}) {
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
      return response.read().transform(UTF8.decoder).join('')
          .then((String bodyString) {
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
      String body, String content, String contentType,
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
}
