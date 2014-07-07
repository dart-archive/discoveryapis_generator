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
///   |- test/common/common_internal.dart
///   |- test/$API/... (for all APIs to generate)
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
    var testFolderPath = "$packageFolderPath/test";
    var testCommonFolderPath = "$packageFolderPath/test/common";

    var pubspecYamlPath = "$packageFolderPath/pubspec.yaml";
    var licensePath = "$packageFolderPath/LICENSE";
    var readmePath = "$packageFolderPath/README.md";
    var versionPath = "$packageFolderPath/VERSION";
    var gitIgnorePath = "$packageFolderPath/.gitignore";

    var commonExternalLibraryPath = "$libFolderPath/common/common.dart";
    var commonExternalLibraryUri = "../common/common.dart";

    var commonInternalLibraryPath = "$libFolderPath/src/common_internal.dart";
    var commonInternalTestLibraryPath =
        "$testCommonFolderPath/common_internal_test.dart";
    var commonInternalLibraryUri = "../src/common_internal.dart";

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
    new Directory(testCommonFolderPath).createSync(recursive: true);

    _writeFile(pubspecYamlPath, _writePubspec);

    _writeString(licensePath, _license);

    _writeFile(readmePath, _writeReadme);

    _writeString(gitIgnorePath, _gitIgnore);

    // These libraries are used by all APIs for making requests.
    _writeString(commonExternalLibraryPath, _COMMON_EXTERNAL_LIBRARY);
    _writeString(commonInternalLibraryPath, _COMMON_INTERAL_LIBRARY);
    _writeString(commonInternalTestLibraryPath, _COMMON_INTERAL_TEST_LIBRARY);

    // TODO(kustermann):
    // _writeString(versionPath, _description.etag);

    var results = <GenerateResult>[];
    for (RestDescription description in descriptions) {
      String name = description.name.toLowerCase();
      String version = description.version.toLowerCase()
          .replaceAll('.', '_').replaceAll('-', '_');

      String apiFolderPath = "$libFolderPath/$name";
      String apiTestFolderPath = "$testFolderPath/$name";

      String apiVersionFile = "$libFolderPath/$name/$version.dart";
      String apiTestVersionFile = "$testFolderPath/$name/$version.dart";

      String packagePath = 'package:googleapis/$name/$version.dart';

      try {
        // Create API itself.
        new Directory(apiFolderPath).createSync();
        var apiLibrary = _generateApiLibrary(apiVersionFile,
                                             description,
                                             commonInternalLibraryUri,
                                             commonExternalLibraryUri);

        // Create Test for API.
        new Directory(apiTestFolderPath).createSync();
        _generateApiTestLibrary(apiTestVersionFile, packagePath, apiLibrary);

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

  DartApiLibrary _generateApiLibrary(String outputFile,
                                     RestDescription description,
                                     String internalUri,
                                     String externalUri) {
    var lib = new DartApiLibrary.build(description, internalUri, externalUri);
    _writeString(outputFile, lib.librarySource);
    return lib;
  }

  void _generateApiTestLibrary(String outputFile,
                               String packageImportPath,
                               DartApiLibrary apiLibrary) {
    var testLib = new DartApiTestLibrary.build(apiLibrary, packageImportPath);
    _writeString(outputFile, testLib.librarySource);
  }

  void _writePubspec(StringSink sink) {
    writeDependencies(dependencies) {
      orderedForEach(dependencies, (String lib, Object value) {
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
    writeDependencies(config.dependencies);
    sink.writeln("dev_dependencies:");
    writeDependencies(config.devDependencies);
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

/**
 * Represents a general error reported by the API endpoint.
 */
class ApiRequestError extends core.Error {
  final core.String message;

  ApiRequestError(this.message);

  core.String toString() => 'ApiRequestError(message: $message)';
}

/**
 * Represents a specific error reported by the API endpoint.
 */
class DetailedApiRequestError extends core.Error {
  final core.int status;
  final core.String message;

  DetailedApiRequestError(this.status, this.message);

  core.String toString()
      => 'DetailedApiRequestError(code: $status, message: $message)';
}

""";


  static const _COMMON_INTERAL_LIBRARY = r"""
library googleapis.common_internal;

import "dart:async";
import "dart:convert";
import "dart:collection" as collection;

import "package:crypto/crypto.dart" as crypto;
import "package:googleapis/common/common.dart" as common_external;
import "package:http_base/http_base.dart" as http_base;

class HeadersImpl implements http_base.Headers {
  final Map<String, List<String>> _m = {};

  HeadersImpl(Map map) {
    map.forEach((String key, List<String> values) {
      _m[key.toLowerCase()] = values;
    });
  }

  Iterable<String> get names => _m.keys;

  bool contains(String name) =>  _m.containsKey(name.toLowerCase());

  String operator [](String name) {
    var values = _m[name.toLowerCase()];
    if (values == null) return null;
    if (values.length == 1) return values.first;
    return values.join(',');
  }

  Iterable<String> getMultiple(String name) => _m[name.toLowerCase()];
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
  Future request(String requestUrl, String method,
        {String body, Map urlParams, Map queryParams,
         common_external.Media uploadMedia, String uploadMediaPath}) {
    return _request(requestUrl, method, body, urlParams, queryParams,
                    uploadMedia, uploadMediaPath)
        .then(_validateResponse).then((http_base.Response response) {

      var stringStream = _decodeStreamAsText(response);
      if (stringStream != null) {
        return stringStream.join('').then((String bodyString) {
          if (bodyString == '') return null;
          return JSON.decode(bodyString);
        });
      } else {
        throw new common_external.ApiRequestError(
            "Unable to read response with content-type "
            "${response.headers['content-type']}.");
      }
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
        {String body, Map urlParams, Map queryParams,
         common_external.Media uploadMedia, String uploadMediaPath}) {
    return _request(requestUrl, method, body, urlParams, queryParams,
                    uploadMedia, uploadMediaPath, downloadAsMedia: true)
        .then(_validateResponse).then((http_base.Response response) {
      // TODO: Do we need more validation here?
      var contentType = response.headers['content-type'];
      if (contentType == null) {
        throw new common_external.ApiRequestError(
            "No 'content-type' header in media response.");
      }
      var contentLength;
      try {
        contentLength = int.parse(response.headers['content-length']);
      } catch (_) {
        throw new common_external.ApiRequestError(
            "No or invalid 'content-length' header in media response.");
      }

      return new common_external.Media(
          response.read(), contentLength, contentType: contentType);
    });
  }

  Future _request(String requestUrl, String method,
        String body, Map urlParams, Map queryParams,
        common_external.Media uploadMedia,
        String uploadMediaPath, {bool downloadAsMedia: false}) {
    if (queryParams == null) queryParams = const {};
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
    var utf8ContentType = 'application/json; charset=utf-8';
    var headers = new HeadersImpl({'content-type' : [utf8ContentType]});

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
              ..write("Content-Type: $utf8ContentType\r\n\r\n")
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

Future<http_base.Response> _validateResponse(http_base.Response response) {
  var statusCode = response.status;

  // TODO: We assume that status codes between [200..400[ are OK.
  // Can we assume this?
  if (statusCode < 200 || statusCode >= 400) {
    throwGeneralError() {
      throw new common_external.ApiRequestError(
          'No error details. Http status was: ${response.status}.');
    }

    // Some error happened, try to decode the response and fetch the error.
    Stream<String> stringStream = _decodeStreamAsText(response);
    if (stringStream != null) {
      return stringStream.transform(JSON.decoder).first.then((json) {
        if (json is Map && json['error'] is Map) {
          var error = json['error'];
          var code = error['code'];
          var message = error['message'];
          throw new common_external.DetailedApiRequestError(code, message);
        } else {
          throwGeneralError();
        }
      });
    } else {
      throwGeneralError();
    }
  }

  return new Future.value(response);
}

Stream<String> _decodeStreamAsText(http_base.Response response) {
  // TODO: Correctly handle the response content-types, using correct
  // decoder.
  // Currently we assume that the api endpoint is responding with exactly
  // "application/json; charset=utf-8"
  String contentType = response.headers['Content-Type'];
  if (contentType != null &&
      contentType.toLowerCase() == 'application/json; charset=utf-8') {
    return response.read().transform(new Utf8Decoder(allowMalformed: true));
  } else {
    return null;
  }
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
            var listValue = params[variable];
            if (listValue is! List || listValue.length != 1) {
              throw new ArgumentError(
                "Url variable '$variable' must be a valid List with one item.");
            }
            return Uri.encodeComponent(listValue[0].toString());
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


  static const _COMMON_INTERAL_TEST_LIBRARY = r"""
import 'dart:async';
import 'dart:convert';

import 'package:googleapis/common/common.dart';
import 'package:googleapis/src/common_internal.dart';
import 'package:http_base/http_base.dart' as http_base;
import 'package:unittest/unittest.dart';

class HttpServerMock {
  Function _callback;
  bool _expectJson;

  void register(Function callback, bool expectJson) {
    _callback = callback;
    _expectJson = expectJson;
  }

  Future<http_base.Response> call(http_base.Request request) {
    if (_expectJson) {
      return request
          .read()
          .transform(UTF8.decoder)
          .join('')
          .then((String jsonString) {
        if (jsonString.isEmpty) {
          return _callback(request, null);
        } else {
          return _callback(request, JSON.decode(jsonString));
        }
      });
    } else {
      return request
          .read()
          .fold([], (buff, data) => buff..addAll(data))
          .then((data) {
        return _callback(request, data);
      });
    }
  }
}

http_base.Response emptyResponse(int status,
                                 http_base.Headers headers,
                                 String body) {
  if (headers == null) {
    headers = new HeadersImpl({});
  }
  return new ResponseImpl(status, headers, byteStream(body));
}

Stream<List<int>> byteStream(String s) {
  var bodyController = new StreamController();
  bodyController.add(UTF8.encode(s));
  bodyController.close();
  return bodyController.stream;
}

class _ApiRequestError extends TypeMatcher {
  const _ApiRequestError() : super("ApiRequestError");
  bool matches(item, Map matchState) => item is ApiRequestError;
}

class _DetailedApiRequestError extends TypeMatcher {
  const _DetailedApiRequestError() : super("DetailedApiRequestError");
  bool matches(item, Map matchState) => item is DetailedApiRequestError;
}

class TestError {}

class _TestError extends TypeMatcher {
  const _TestError() : super("TestError");
  bool matches(item, Map matchState) => item is TestError;
}

const isApiRequestError = const _ApiRequestError();
const isDetailedApiRequestError = const _DetailedApiRequestError();
const isTestError = const _TestError();


main() {
  group('common-external', () {
    test('mapMap', () {
      newTestMap() => {
        's' : 'string',
        'i' : 42,
      };

      var copy = mapMap(newTestMap());
      expect(copy, hasLength(2));
      expect(copy['s'], equals('string'));
      expect(copy['i'], equals(42));


      var mod = mapMap(newTestMap(), (x) => '$x foobar');
      expect(mod, hasLength(2));
      expect(mod['s'], equals('string foobar'));
      expect(mod['i'], equals('42 foobar'));
    });

    test('url-pattern', () {
      // The [UrlPattern] class currently only implements a very limited subset
      // of the uri template specification, namely:
      //   -  /{var}/
      //   -  /{/vars*}/
      // See: http://tools.ietf.org/html/draft-gregorio-uritemplate-07
      // TODO: Extend [UrlPattern] and implement corresponding tests.

      var pathVars = {
          'a' : ['AA'],
          'b' : ['B/B'],
          'c' : [''],
          'va' : ['1', 'x/y', 'z'],
          'vb' : ['4'],
          'vc' : [],
      };

      pattern(String p) => new UrlPattern(p);

      var patterns = [
          // No variables
          pattern(''),
          pattern('/'),
          pattern('fixed'),
          pattern('/fixed/'),

          pattern('fixed/with/long/relative/path'),
          pattern('/fixed/with/long/relative/path/'),

          // Normal variables
          pattern('{a}/variable'),
          pattern('/{a}/variable/'),

          pattern('{a}/variable/with/{b}'),
          pattern('/{a}/variable/with/{b}/'),

          pattern('variable/{b}'),
          pattern('/variable/{b}/'),

          pattern('start/{a}/relative/{b}/end/{c}'),
          pattern('/start/{a}/relative/{b}/end/{c}/'),

          pattern('{a}{b}'),
          pattern('/{a}{b}/'),

          // Variable-length variables + normal variables
          pattern('{a}start/{/va*}/rel/{/vb*}/ative/{/vc*}/end{b}'),
          pattern('{a}/start/{/va*}/rel/{/vb*}/ative/{/vc*}/end/{b}'),
      ];

      var results = [
          // No variables
          '',
          '/',
          'fixed',
          '/fixed/',

          'fixed/with/long/relative/path',
          '/fixed/with/long/relative/path/',

          // Normal variables
          'AA/variable',
          '/AA/variable/',

          'AA/variable/with/B%2FB',
          '/AA/variable/with/B%2FB/',

          'variable/B%2FB',
          '/variable/B%2FB/',

          'start/AA/relative/B%2FB/end/',
          '/start/AA/relative/B%2FB/end//',

          'AAB%2FB',
          '/AAB%2FB/',

          // Variable-length variables + normal variables
          'AAstart//1/x%2Fy/z/rel//4/ative///endB%2FB',
          'AA/start//1/x%2Fy/z/rel//4/ative///end/B%2FB',
      ];

      var queryVarList = [
          {},
          {
            'a' : ['foo'],
          },
          {
            'a' : ['foo'],
            'b' : ['b1', 'b2'],
          },
          {
            '/x' : ['x/y/z'],
          }
      ];
      var queryResults = [
          '',
          '?a=foo',
          '?a=foo&b=b1&b=b2',
          '?%2Fx=x%2Fy%2Fz',
      ];

      for (int i = 0; i < patterns.length; i++) {
        for (int j = 0; j < queryVarList.length; j++) {
          expect(patterns[i].generate(pathVars, queryVarList[j]),
                 equals('${results[i]}${queryResults[j]}'));
        }
      }

      expect(() => pattern('{'), throwsArgumentError);

      expect(() => pattern('{a}').generate({}, {}), throwsArgumentError);
      expect(() => pattern('{a}').generate({'a': null}, {}),
             throwsArgumentError);
      expect(() => pattern('{a}').generate({'a': 'var'}, {}),
             throwsArgumentError);

      expect(() => pattern('{a}').generate({}, {'a': null}),
             throwsArgumentError);
      expect(() => pattern('{a}').generate({}, {'a': 'var'}),
             throwsArgumentError);
    });

    test('http-headers', () {
      // TODO: Cookie headers are not special cased so far: impl+test missing.

      var a = ['a1', 'a2', 'a3'];
      var b = ['b1'];
      var headers = new HeadersImpl({'A' : a, 'b' : b});

      expect(headers.contains('a'), isTrue);
      expect(headers.contains('A'), isTrue);
      expect(headers.contains('b'), isTrue);
      expect(headers.contains('B'), isTrue);
      expect(headers.contains('c'), isFalse);
      expect(headers.contains('C'), isFalse);

      expect(headers.names, hasLength(2));
      expect(headers.names.contains('a'), isTrue);
      expect(headers.names.contains('b'), isTrue);
      expect(headers.names.contains('c'), isFalse);

      expect(headers.names.contains('A'), isFalse);
      expect(headers.names.contains('B'), isFalse);
      expect(headers.names.contains('C'), isFalse);

      expect(headers['a'], equals('a1,a2,a3'));
      expect(headers['A'], equals('a1,a2,a3'));
      expect(headers['b'], equals('b1'));
      expect(headers['B'], equals('b1'));

      expect(headers.getMultiple('a'), equals(a));
      expect(headers.getMultiple('A'), equals(a));
      expect(headers.getMultiple('b'), equals(b));
      expect(headers.getMultiple('B'), equals(b));
    });

    group('api-requester', () {
      var httpMock, rootUrl, basePath;
      ApiRequester requester;

      var responseHeaders = new HeadersImpl({
          'content-type' : ['application/json; charset=utf-8'],
      });

      setUp(() {
        httpMock = new HttpServerMock();
        rootUrl = 'http://example.com/';
        basePath = '/base/';
        requester = new ApiRequester(httpMock, rootUrl, basePath);
      });


      // Tests for Request, Response

      test('empty-request-empty-response', () {
        httpMock.register(expectAsync((http_base.Request request, json) {
          expect(request.method, equals('GET'));
          expect('${request.url}', equals('http://example.com/base/abc'));
          return emptyResponse(200, responseHeaders, '');
        }), true);
        requester.request('abc', 'GET').then(expectAsync((response) {
          expect(response, isNull);
        }));
      });

      test('json-map-request-json-map-response', () {
        httpMock.register(expectAsync((http_base.Request request, json) {
          expect(request.method, equals('GET'));
          expect('${request.url}', equals('http://example.com/base/abc'));
          expect(json is Map, isTrue);
          expect(json, hasLength(1));
          expect(json['foo'], equals('bar'));
          return emptyResponse(200, responseHeaders, '{"foo2" : "bar2"}');
        }), true);
        requester.request('abc',
                          'GET',
                          body: JSON.encode({'foo' : 'bar'})).then(
            expectAsync((response) {
          expect(response is Map, isTrue);
          expect(response, hasLength(1));
          expect(response['foo2'], equals('bar2'));
        }));
      });

      test('json-list-request-json-list-response', () {
        httpMock.register(expectAsync((http_base.Request request, json) {
          expect(request.method, equals('GET'));
          expect('${request.url}', equals('http://example.com/base/abc'));
          expect(json is List, isTrue);
          expect(json, hasLength(2));
          expect(json[0], equals('a'));
          expect(json[1], equals(1));
          return emptyResponse(200, responseHeaders, '["b", 2]');
        }), true);
        requester.request('abc',
                          'GET',
                          body: JSON.encode(['a', 1])).then(
            expectAsync((response) {
          expect(response is List, isTrue);
          expect(response[0], equals('b'));
          expect(response[1], equals(2));
        }));
      });


      // Tests for error responses
      group('request-errors', () {
        makeTestError() {
          // All errors from the [http_base.Client] propagate through.
          // We use [TestError] to simulate it.
          httpMock.register(expectAsync((http_base.Request request, string) {
            return new Future.error(new TestError());
          }), false);
        }

        makeDetailed400Error() {
          httpMock.register(expectAsync((http_base.Request request, string) {
            return emptyResponse(400,
                                 responseHeaders,
                                 '{"error" : {"code" : 42, "message": "foo"}}');
          }), false);
        }

        makeNormal199Error() {
          httpMock.register(expectAsync((http_base.Request request, string) {
            return emptyResponse(200, null, '');
          }), false);
        }

        makeInvalidContentTypeError({String contentType}) {
          httpMock.register(expectAsync((http_base.Request request, string) {
            var responseHeaders;
            if (contentType != null) {
              responseHeaders = new HeadersImpl({
                'content-type' : [contentType],
              });
            }
            return emptyResponse(200, null, '');
          }), false);
        }


        test('normal-http-client', () {
          makeTestError();
          expect(requester.request('abc', 'GET'), throwsA(isTestError));
        });

        test('normal-detailed-400', () {
          makeDetailed400Error();
          requester.request('abc', 'GET')
              .catchError(expectAsync((error, stack) {
            expect(error, isDetailedApiRequestError);
            DetailedApiRequestError e = error;
            expect(e.status, equals(42));
            expect(e.message, equals('foo'));
          }));
        });

        test('normal-199', () {
          makeNormal199Error();
          expect(requester.request('abc', 'GET'), throwsA(isApiRequestError));
        });

        test('normal-no-content-type', () {
          makeInvalidContentTypeError();
          expect(requester.request('abc', 'GET'), throwsA(isApiRequestError));
        });

        test('normal-invalid-content-type', () {
          makeInvalidContentTypeError(contentType: 'foobar');
          expect(requester.request('abc', 'GET'), throwsA(isApiRequestError));
        });

        test('media-http-client', () {
          makeTestError();
          expect(requester.requestMedia('abc', 'GET'), throwsA(isTestError));
        });

        test('media-detailed-400', () {
          makeDetailed400Error();
          requester.request('abc', 'GET')
              .catchError(expectAsync((error, stack) {
            expect(error, isDetailedApiRequestError);
            DetailedApiRequestError e = error;
            expect(e.status, equals(42));
            expect(e.message, equals('foo'));
          }));
        });

        test('media-199', () {
          makeNormal199Error();
          expect(requester.requestMedia('abc', 'GET'),
                 throwsA(isApiRequestError));
        });

        test('media-no-content-type', () {
          makeInvalidContentTypeError();
          expect(requester.requestMedia('abc', 'GET'),
                 throwsA(isApiRequestError));
        });

        test('media-invalid-content-type', () {
          makeInvalidContentTypeError(contentType: 'foobar');
          expect(requester.requestMedia('abc', 'GET'),
                 throwsA(isApiRequestError));
        });
      });


      // Tests for path/query parameters

      test('request-parameters-query', () {
        var queryParams = {
            'a' : ['a1', 'a2'],
            's' : ['s1']
        };
        httpMock.register(expectAsync((http_base.Request request, json) {
          expect(request.method, equals('GET'));
          expect('${request.url}',
                 equals('http://example.com/base/abc?a=a1&a=a2&s=s1'));
          return emptyResponse(200, responseHeaders, '');
        }), true);
        requester.request('abc', 'GET', queryParams: queryParams)
            .then(expectAsync((response) {
          expect(response, isNull);
        }));
      });

      test('request-parameters-path', () {
        var pathParams = {
            'a' : ['a1', 'a2'],
            's' : ['s1']
        };
        httpMock.register(expectAsync((http_base.Request request, json) {
          expect(request.method, equals('GET'));
          expect('${request.url}',
                 equals('http://example.com/base/s/foo/a1/a2/bar/s1/e'));
          return emptyResponse(200, responseHeaders, '');
        }), true);
        requester.request('s/foo{/a*}/bar/{s}/e', 'GET', urlParams: pathParams)
            .then(expectAsync((response) {
          expect(response, isNull);
        }));
      });

      // TODO: Tests for media upload / media download

    });
  });
}

""";
}
