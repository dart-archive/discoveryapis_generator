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
    var commonFolderPath = "$packageFolderPath/lib/common";
    var srcFolderPath = "$packageFolderPath/lib/src";

    var pubspecYamlPath = "$packageFolderPath/pubspec.yaml";
    var licensePath = "$packageFolderPath/LICENSE";
    var readmePath = "$packageFolderPath/README.md";
    var versionPath = "$packageFolderPath/VERSION";
    var gitIgnorePath = "$packageFolderPath/.gitignore";

    var commonExternalLibraryPath = "$libFolderPath/common/common.dart";
    var commonExternalLibraryUri = "../common/common.dart";

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

    new Directory(commonFolderPath).createSync(recursive: true);
    new Directory(srcFolderPath).createSync(recursive: true);

    _writeFile(pubspecYamlPath, _writePubspec);

    _writeString(licensePath, _license);

    _writeFile(readmePath, _writeReadme);

    _writeString(gitIgnorePath, _gitIgnore);

    // These libraries are used by all APIs for making requests.
    _writeString(commonExternalLibraryPath, _COMMON_EXTERNAL_LIBRARY);
    _writeString(commonInternalLibraryPath, _COMMON_INTERAL_LIBRARY);

    // TODO(kustermann):
    // _writeString(versionPath, _description.etag);

    var results = <GenerateResult>[];
    for (RestDescription description in descriptions) {
      String name = description.name.toLowerCase();
      String version = description.version.toLowerCase()
          .replaceAll('.', '_').replaceAll('-', '_');
      String apiFolderPath = "$libFolderPath/$name";
      String apiVersionFile = "$libFolderPath/$name/$version.dart";
      String packagePath = 'package:googleapis/$name/$version.dart';
      try {
        new Directory(apiFolderPath).createSync();
        _generateApiLibrary(apiVersionFile,
                            description,
                            commonInternalLibraryUri,
                            commonExternalLibraryUri);
        var result = new GenerateResult(name, version, packagePath);
        results.add(result);
      } catch (error, stack) {
        var errorMessage = '';
        if (error is GeneratorError) {
          errorMessage = '$error';
        } else {
          errorMessage = '$error\nstack: $stack';
        }
        results.add(
            new GenerateResult.error(name, version, packagePath, errorMessage));
      }
    }
    return results;
  }

  void _generateApiLibrary(String outputFile,
                           RestDescription description,
                           String internalUri,
                           String externalUri) {
    var lib = new DartApiLibrary.build(description, internalUri, externalUri);
    _writeString(outputFile, lib.librarySource);
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
    orderedForEach(config.dependencies, (String lib, Object value) {
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

  static const _COMMON_EXTERNAL_LIBRARY = r"""
library googleapis.common;

import 'dart:async' as async;
import 'dart:core' as core;
import 'dart:collection' as collection;

class Media {
  final async.Stream<core.List<core.int>> stream;
  final core.String contentType;
  final core.int length;

  Media(this.stream, this.length,
        {this.contentType: "application/octet-stream"});
}

""";

  static const _COMMON_INTERAL_LIBRARY = r"""
library cloud_api;

import "dart:async";
import "dart:convert";
import "dart:collection" as collection;

import "package:crypto/crypto.dart" as crypto;
import "package:googleapis/common/common.dart" as common_external;
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
  final String _rootUrl;
  final String _basePath;

  ApiRequester(this._httpClient, this._rootUrl, this._basePath);

  static const _boundaryString = "314159265358979323846";

  /**
   * Sends a HTTPRequest using [method] (usually GET or POST) to [requestUrl]
   * using the specified [urlParams] and [queryParams]. Optionally include a
   * [body] and/or [uploadMedia] in the request.
   */
  Future<Map<String, dynamic>> request(String requestUrl, String method,
        {String body, String contentType:"application/json",
         Map urlParams, Map queryParams,
         common_external.Media uploadMedia, String uploadMediaPath}) {
    return _request(requestUrl, method, body, contentType,
                    urlParams, queryParams,
                    uploadMedia,
                    uploadMediaPath).then((http_base.Response response) {
      return response.read().transform(UTF8.decoder).join('')
          .then((String bodyString) {
        DetailedApiRequestError.validateResponse(response.status, bodyString);
        if (bodyString == '') return null;
        return JSON.decode(bodyString);
      });
    });
  }

  /**
   * Sends a HTTPRequest using [method] (usually GET or POST) to [requestUrl]
   * using the specified [urlParams] and [queryParams]. Optionally include a
   * [body] and/or [uploadMedia] in the request.
   *
   * Decodes the response as a [common_external.Media]
   */
  Future<common_external.Media> requestMedia(String requestUrl, String method,
        {String body, String contentType:"application/json",
         Map urlParams, Map queryParams,
         common_external.Media uploadMedia, String uploadMediaPath}) {
    return _request(requestUrl, method, body, contentType,
                    urlParams, queryParams,
                    uploadMedia, uploadMediaPath,
                    downloadAsMedia: true).then((http_base.Response response) {
      // TODO: Do some validation here.
      var stream = response.read();
      var contentType = response.headers['content-type'];
      var contentLength = int.parse(response.headers['content-length']);
      return new common_external.Media(
          stream, contentLength, contentType: contentType);
    });
  }

  Future _request(String requestUrl, String method,
        String body, String contentType, Map urlParams,
        Map queryParams, common_external.Media uploadMedia,
        String uploadMediaPath, {bool downloadAsMedia: false}) {
    if (queryParams == null) queryParams = const {};
    var allQueryParameters = new Map<String,String>.from(queryParams);

    var path;
    if (uploadMedia != null) {
      requestUrl = uploadMediaPath;
    }

    if (requestUrl.substring(0,1) == "/") {
      path ="$_rootUrl${requestUrl.substring(1)}";
    } else {
      path ="$_rootUrl${_basePath.substring(1)}$requestUrl";
    }

    var url = new UrlPattern(path).generate(urlParams, queryParams);
    var uri = Uri.parse(url);
    if (uploadMedia != null || downloadAsMedia) {
      if (uri.query.isEmpty) {
        url = '$url?';
      }

      if (uploadMedia != null) {
        if (body == null) {
          url = '${url}&uploadType=media';
        } else {
          url = '${url}&uploadType=multipart';
        }
      }

      if (downloadAsMedia) {
        url = '${url}&alt=media';
      }

      uri = Uri.parse(url);
    }

    var bodyStream;
    var headers = new HeadersImpl({'content-type' : [contentType]});

    // FIXME: Validate content-length of media?
    if (uploadMedia != null) {
      // Three cases:
      // 1. simple: upload of media
      // 2. multipart: upload of data + metadata
      // 3. resumable upload: upload of data + metdata + complicated stuff

      if (body == null) {
        // 1. simple upload of media
        headers = new HeadersImpl({
          'content-type' : [uploadMedia.contentType],
          'content-length' : ['${uploadMedia.length}']
        });
        bodyStream = uploadMedia.stream;
      } else {
        // 2. multipart: upload of data + metadata
        // TODO: This needs to be made streaming based and much more efficient.

        var bodyController = new StreamController<List<int>>();
        bodyStream = bodyController.stream;
        return uploadMedia.stream.fold(
            [], (buffer, data) => buffer..addAll(data)).then((List<int> data) {

          var bodyString = new StringBuffer();
          bodyString
              ..write('--$_boundaryString\r\n')
              ..write("Content-Type: $contentType\r\n\r\n")
              ..write(body)
              ..write('\r\n--$_boundaryString\r\n')
              ..write("Content-Type: ${uploadMedia.contentType}\r\n")
              ..write("Content-Transfer-Encoding: base64\r\n\r\n")
              ..write(crypto.CryptoUtils.bytesToBase64(data))
              ..write('\r\n--$_boundaryString--');
          var bytes = UTF8.encode(bodyString.toString());
          bodyController.add(bytes);
          bodyController.close();
          headers = new HeadersImpl({
            'content-type' : [
                "multipart/mixed; boundary=\"$_boundaryString\""],
            'content-length' : ['${bytes.length}']
          });
        });

        // 3. resumable upload: upload of data + metdata + complicated stuff
        // TODO
      }
    } else {
      var bodyController = new StreamController<List<int>>();
      bodyStream = bodyController.stream;
      if (body != null) {
        bodyController.add(UTF8.encode(body));
      }
      bodyController.close();
    }

    var request = new RequestImpl(method, uri, headers, bodyStream);
    return _httpClient(request);
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
        // FIXME: This is a really hacky way of detecting paths like
        //  - "customer/{customerId}/orgunits{/orgUnitPath*}"
        // TODO: We should write a proper UrlPattern class.
        // TODO: Make sure that the call sites guarantee that the values
        // are not `null`.
        String variable = pattern.substring(open + 1, close);
        if (variable.startsWith('/') && variable.endsWith('*')) {
          variable = variable.substring(1, variable.length - 1);
          _tokens.add((params) {
            if (params[variable] is! List) {
              throw new ArgumentError(
                "Url variable '$variable' must be a valid List.");
            }
            return '/' + params[variable]
                .map((item) => Uri.encodeComponent('$item'))
                .join('/');
          });
        }  else {
          _tokens.add((params) {
            if (params[variable] == null) {
              throw new ArgumentError(
                  "Url variable '$variable' must not be null.");
            } else {
              return Uri.encodeComponent(params[variable].toString());
            }
          });
        }
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

Map mapMap(Map source, [Object convert(Object source) = null]) {
  assert(source != null);
  var result = new collection.LinkedHashMap();
  source.forEach((String key, value) {
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
}
