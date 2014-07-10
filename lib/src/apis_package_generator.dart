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

/**
 * Represents a media consisting of a stream of bytes, a content type and a
 * length.
 */
class Media {
  final async.Stream<core.List<core.int>> stream;
  final core.String contentType;
  final core.int length;

  /**
   * Creates a new [Media] with a byte [stream] of length [length] with a
   * [contentType].
   *
   * When uploading media, [length] can only be null if [ResumableUploadOptions]
   * is used.
   */
  Media(this.stream, this.length,
        {this.contentType: "application/octet-stream"}) {
    if (stream == null || contentType == null) {
      throw new core.ArgumentError(
          'Arguments stream, contentType and length must not be null.');
    }
    if (length != null && length < 0) {
      throw new core.ArgumentError('A negative content length is not allowed');
    }
  }
}


/**
 * Represents options for uploading a [Media].
 */
class UploadOptions {
  /** Use either simple uploads (only media) or multipart for media+metadata */
  static const UploadOptions Default = const UploadOptions();

  /** Make resumable uploads */
  static final ResumableUploadOptions Resumable = new ResumableUploadOptions();

  const UploadOptions();
}


/**
 * Specifies options for resumable uploads.
 */
class ResumableUploadOptions extends UploadOptions {
  /**
   * Maximum number of upload attempts per chunk.
   */
  final core.int numberOfAttempts;

  /**
   * Preferred size (in bytes) of a uploaded chunk.
   * Must be a multiple of 256 KB.
   *
   * The default is 1 MB.
   */
  final core.int chunkSize;

  ResumableUploadOptions({this.numberOfAttempts: 3,
                          this.chunkSize: 1024 * 1024}) {
    // See e.g. here:
    // https://developers.google.com/maps-engine/documentation/resumable-upload
    //
    // Chunk size restriction:
    // There are some chunk size restrictions based on the size of the file you
    // are uploading. Files larger than 256 KB (256 x 1024 bytes) must have
    // chunk sizes that are multiples of 256 KB. For files smaller than 256 KB,
    // there are no restrictions. In either case, the final chunk has no
    // limitations; you can simply transfer the remaining bytes. If you use
    // chunking, it is important to keep the chunk size as large as possible
    // to keep the upload efficient.
    //
    if (numberOfAttempts < 1 || (chunkSize % (256 * 1024)) != 0) {
      throw new core.ArgumentError('Invalid arguments.');
    }
  }
}


/**
 * Represents options for downloading media.
 *
 * For partial downloads, see [PartialDownloadOptions].
 */
class DownloadOptions {
  /** Download only metadata. */
  static const DownloadOptions Metadata = const DownloadOptions();

  /** Download full media. */
  static final PartialDownloadOptions FullMedia =
      new PartialDownloadOptions(new ByteRange(0, -1));

  const DownloadOptions();

  /** Indicates whether metadata should be downloaded. */
  core.bool get isMetadataDownload => true;
}


/**
 * Options for downloading a [Media].
 */
class PartialDownloadOptions extends DownloadOptions {
  /** The range of bytes to be downloaded */
  final ByteRange range;

  PartialDownloadOptions(this.range);

  core.bool get isMetadataDownload => false;

  /**
   * `true` if this is a full download and `false` if this is a partial
   * download.
   */
  core.bool get isFullDownload => range.start == 0 && range.end == -1;
}


/**
 * Specifies a range of media.
 */
class ByteRange {
  /** First byte of media. */
  final core.int start;

  /** Last byte of media (inclusive) */
  final core.int end;

  ByteRange(this.start, this.end) {
    if (!(start == 0  && end == -1 || start >= 0 && end > start)) {
      throw new core.ArgumentError('Invalid media range [$start, $end]');
    }
  }
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
class DetailedApiRequestError extends ApiRequestError {
  final core.int status;

  DetailedApiRequestError(this.status, core.String message) : super(message);

  core.String toString()
      => 'DetailedApiRequestError(status: $status, message: $message)';
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

const CONTENT_TYPE_UTF8 = 'application/json; charset=utf-8';

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
   *
   * If [uploadMedia] was specified [downloadOptions] must be
   * [DownloadOptions.Metadata].
   *
   * If [downloadOptions] is [DownloadOptions.Metadata] the result will be
   * decoded as JSON.
   *
   * [downloadOptions] must never be null.
   *
   * Otherwise the result will be downloaded as a [common_external.Media]
   */
  Future request(String requestUrl, String method,
                {String body, Map urlParams, Map queryParams,
                 common_external.Media uploadMedia,
                 common_external.UploadOptions uploadOptions,
                 common_external.DownloadOptions downloadOptions:
                     common_external.DownloadOptions.Metadata,
                 String uploadMediaPath}) {
    if (uploadMedia != null &&
        downloadOptions != common_external.DownloadOptions.Metadata) {
      throw new ArgumentError('When uploading a [Media] you cannot download a '
                              '[Media] at the same time!');
    }
    return _request(requestUrl, method, body, urlParams, queryParams,
                    uploadMedia, uploadOptions,
                    downloadOptions,
                    uploadMediaPath)
        .then(_validateResponse).then((http_base.Response response) {
      if (downloadOptions == common_external.DownloadOptions.Metadata) {
        // Downloading JSON Metadata
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
      } else {
        // Downloading Media.
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
      }
    });
  }

  // TODO: Handle [downloadOptions] -- e.g. partial media downloads.
  Future _request(String requestUrl, String method,
                  String body, Map urlParams, Map queryParams,
                  common_external.Media uploadMedia,
                  common_external.UploadOptions uploadOptions,
                  common_external.DownloadOptions downloadOptions,
                  String uploadMediaPath) {
    bool downloadAsMedia =
        downloadOptions != common_external.DownloadOptions.Metadata;

    Uri buildRequestUri() {
      if (queryParams == null) queryParams = const {};
      var path;
      if (uploadMedia != null) {
        requestUrl = uploadMediaPath;
      }

      if (requestUrl.startsWith("/")) {
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
          if (uploadOptions is common_external.ResumableUploadOptions) {
            url = '${url}&uploadType=resumable';
          } else if (body == null) {
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
      return uri;
    }

    var uri = buildRequestUri();

    Future multipartUpload() {
      // TODO: This needs to be made streaming based and much more efficient.

      var bodyController = new StreamController<List<int>>();
      var bodyStream = bodyController.stream;
      return uploadMedia.stream.fold(
          [], (buffer, data) => buffer..addAll(data)).then((List<int> data) {

        var bodyString = new StringBuffer();
        bodyString
            ..write('--$_boundaryString\r\n')
            ..write("Content-Type: $CONTENT_TYPE_UTF8\r\n\r\n")
            ..write(body)
            ..write('\r\n--$_boundaryString\r\n')
            ..write("Content-Type: ${uploadMedia.contentType}\r\n")
            ..write("Content-Transfer-Encoding: base64\r\n\r\n")
            ..write(crypto.CryptoUtils.bytesToBase64(data))
            ..write('\r\n--$_boundaryString--');
        var bytes = UTF8.encode(bodyString.toString());
        bodyController.add(bytes);
        bodyController.close();
        var headers = new HeadersImpl({
          'content-type' : [
              "multipart/mixed; boundary=\"$_boundaryString\""],
          'content-length' : ['${bytes.length}']
        });
        return _httpClient(new RequestImpl(method, uri, headers, bodyStream));
      });
    }

    Future simpleUpload() {
      var headers = new HeadersImpl({
        'content-type' : [uploadMedia.contentType],
        'content-length' : ['${uploadMedia.length}']
      });
      var bodyStream = uploadMedia.stream;
      var request = new RequestImpl(method, uri, headers, bodyStream);
      return _httpClient(request);
    }

    Future simpleRequest() {
      var length = 0;
      var bodyController = new StreamController<List<int>>();
      if (body != null) {
        var bytes = UTF8.encode(body);
        bodyController.add(bytes);
        length = bytes.length;
      }
      bodyController.close();

      var headers = new HeadersImpl({
          'content-type' : [CONTENT_TYPE_UTF8],
          'content-length' : ['$length'],
      });
      return _httpClient(
          new RequestImpl(method, uri, headers, bodyController.stream));
    }

    // FIXME: Validate content-length of media?
    if (uploadMedia != null) {
      // Three upload types:
      // 1. Resumable: Upload of data + metdata with multiple requests.
      // 2. Simple: Upload of media.
      // 3. Multipart: Upload of data + metadata.

      if (uploadOptions is common_external.ResumableUploadOptions) {
        var helper = new ResumableUploadHelper(
            _httpClient, uploadMedia, body, uri, method, uploadOptions);
        return helper.upload();
      }

      if (uploadMedia.length == null) {
        throw new ArgumentError(
            'For non-resumable uploads you need to specify the length of the '
            'media to upload.');
      }

      if (body == null) {
        return simpleUpload();
      } else {
        return multipartUpload();
      }
    }
    return simpleRequest();
  }
}

// TODO: Handle [uploadOptions.numberOfAttempts]
// TODO: Buffer less if we know the content length in advance.
class ResumableUploadHelper {
  final http_base.Client _httpClient;
  final common_external.Media _uploadMedia;
  final Uri _uri;
  final String _body;
  final String _method;
  final common_external.ResumableUploadOptions _options;

  ResumableUploadHelper(
      this._httpClient, this._uploadMedia, this._body, this._uri, this._method,
      this._options);

  /**
   * Returns the final [http_base.Response] if the upload succeded and completes
   * with an error otherwise.
   *
   * The returned response stream has not been listened to.
   */
  Future<http_base.Response> upload() {
    return _startSession().then((Uri uploadUri) {
      StreamSubscription subscription;

      // Uploading state
      int chunkSize = _options.chunkSize;
      List<ResumableChunk> chunkStack = [];
      var emptyChunk = new ResumableChunk(chunkSize, chunkStack, 0);
      chunkStack.add(emptyChunk);

      var completer = new Completer<http_base.Response>();
      bool completed = false;

      subscription = _uploadMedia.stream.listen((List<int> bytes) {
        chunkStack.last.addBytes(bytes);
        // Upload all but the last chunk.
        // The final send will be done in the [onDone] handler.
        if (chunkStack.length > 1) {
          // Pause the input stream.
          subscription.pause();

          Future<http_base.Response> upload(ResumableChunk chunk) {
            return _uploadChunkResumable(uploadUri, chunk).then((response) {
              return response.read().drain();
            });
          }

          var fullChunks = chunkStack.sublist(0, chunkStack.length - 1);

          // Upload all chunks except the last one.
          Future.forEach(fullChunks, upload).then((_) {
            chunkStack.removeRange(0, chunkStack.length - 1);

            // All chunks uploaded, we can continue consuming data.
            subscription.resume();
          }).catchError((error, stack) {
            subscription.cancel();
            completed = true;
            completer.completeError(error, stack);
          });
        }
      }, onDone: () {
        if (!completed) {
          // Validate that we have the correct number of bytes if length was
          // specified.
          if (_uploadMedia.length != null) {
            var end = chunkStack.last.endOfChunk;
            if (end < _uploadMedia.length) {
              completer.completeError(new common_external.ApiRequestError(
                  'Received less bytes than indicated by [Media.length].'));
              return;
            } else if (end > _uploadMedia.length) {
              completer.completeError(
                  'Received more bytes than indicated by [Media.length].');
              return;
            }
          }

          // Upload last chunk and *do not drain the response* but complete
          // with it.
          _uploadChunkResumable(uploadUri, chunkStack.last, lastChunk: true)
              .then((response) {
            completer.complete(response);
          }).catchError((error, stack) {
            completer.completeError(error, stack);
          });
        }
      });

      return completer.future;
    });
  }


  /**
   * Starts a resumable upload.
   *
   * Returns the [Uri] which should be used for uploading all content.
   */
  Future<Uri> _startSession() {
    var length = 0;
    var bytes;
    if (_body != null) {
      bytes = UTF8.encode(_body);
      length = bytes.length;
    }
    var bodyStream = _bytes2Stream(bytes);

    var headers = new HeadersImpl({
        'content-type' : [CONTENT_TYPE_UTF8],
        'content-length' : ['$length'],
        'x-upload-content-type' : [_uploadMedia.contentType],
        'x-upload-content-length' : ['${_uploadMedia.length}'],
    });
    var request =
        new RequestImpl(_method, _uri, headers, bodyStream);

    return _httpClient(request).then((http_base.Response response) {
      return response.read().drain().then((_) {
        var uploadUri = response.headers['location'];
        if (response.status != 200 || uploadUri == null) {
          throw new common_external.ApiRequestError(
              'Invalid response for resumable upload attempt '
              '(status was: ${response.status})');
        }
        return Uri.parse(uploadUri);
      });
    });
  }

  Future _uploadChunkResumable(Uri uri,
                               ResumableChunk chunk,
                               {bool lastChunk: false}) {
    tryUpload(int attemptsLeft) {
      return _uploadChunk(uri, chunk, lastChunk: lastChunk)
          .then((http_base.Response response) {
        var status = response.status;
        if (attemptsLeft > 0 &&
            (status == 500 || (502 <= status && status < 504))) {
          return response.read().drain().then((_) {
            // TODO:
            // We should implement an exponential backoff algorithm.
            return tryUpload(attemptsLeft - 1);
          });
        } else if (!lastChunk && status != 308) {
            return response.read().drain().then((_) {
              throw new common_external.DetailedApiRequestError(
                  status,
                  'Resumable upload: Uploading a chunk resulted in '
                  '$status instead of 308.');
            });
        } else if (lastChunk && status != 201 && status != 200) {
          return response.read().drain().then((_) {
            throw new common_external.DetailedApiRequestError(
                status,
                'Resumable upload: Uploading a chunk resulted in '
                '$status instead of 200 or 201.');
          });
        } else {
          return response;
        }
      });
    }

    return tryUpload(_options.numberOfAttempts - 1);
  }

  /**
   * Uploads [length] bytes in [byteArrays] and ensures the upload was
   * successful.
   *
   * Content-Range: [start ... (start + length)[
   *
   * Returns the returned [http_base.Response] or completes with an error if
   * the upload did not succeed. The response stream will not be listened to.
   */
  Future _uploadChunk(Uri uri, ResumableChunk chunk, {bool lastChunk: false}) {
    // If [uploadMedia.length] is null, we do not know the length.
    var mediaTotalLength = _uploadMedia.length;
    if (mediaTotalLength == null || lastChunk) {
      if (lastChunk) {
        mediaTotalLength = '${chunk.endOfChunk}';
      } else {
        mediaTotalLength = '*';
      }
    }

    var headers = new HeadersImpl({
        'content-type' : [_uploadMedia.contentType],
        'content-length' : ['${chunk.length}'],
        'content-range' :
            ['bytes ${chunk.offset}-${chunk.endOfChunk - 1}/$mediaTotalLength'],
    });

    var stream = _listOfBytes2Stream(chunk.byteArrays);
    var request = new RequestImpl('PUT', uri, headers, stream);
    return _httpClient(request);
  }

  Stream<List<int>> _bytes2Stream(List<int> bytes) {
    var bodyController = new StreamController<List<int>>();
    if (bytes != null) {
      bodyController.add(bytes);
    }
    bodyController.close();
    return bodyController.stream;
  }

  Stream<List<int>> _listOfBytes2Stream(List<List<int>> listOfBytes) {
    var controller = new StreamController();
    for (var array in listOfBytes) {
      controller.add(array);
    }
    controller.close();
    return controller.stream;
  }
}


/**
 * Represents a chunk of data that will be transferred in one go.
 */
class ResumableChunk {
  final int chunkSize;
  final List<ResumableChunk> chunkStack;
  final int offset;

  List<List<int>> byteArrays = [];
  int length = 0;

  int get endOfChunk => offset + length;

  ResumableChunk(this.chunkSize, this.chunkStack, this.offset);

  void addBytes(List<int> bytes) {
    var remaining = chunkSize - length;

    if (bytes.length > remaining) {
      var left = bytes.sublist(0, remaining);
      var right = bytes.sublist(remaining);
      byteArrays.add(left);
      length += left.length;

      var c = new ResumableChunk(chunkSize, chunkStack, offset + chunkSize);
      chunkStack.add(c);
      c.addBytes(right);
    } else {
      byteArrays.add(bytes);
      length += bytes.length;
    }
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

    test('media', () {
      // Tests for [MediaRange]
      var partialRange = new ByteRange(1, 100);
      expect(partialRange.start, equals(1));
      expect(partialRange.end, equals(100));

      var fullRange = new ByteRange(0, -1);
      expect(fullRange.start, equals(0));
      expect(fullRange.end, equals(-1));

      expect(() => new ByteRange(0, 0), throws);
      expect(() => new ByteRange(-1, 0), throws);
      expect(() => new ByteRange(-1, 1), throws);

      // Tests for [DownloadOptions]
      expect(DownloadOptions.Metadata.isMetadataDownload, isTrue);

      expect(DownloadOptions.FullMedia.isFullDownload, isTrue);
      expect(DownloadOptions.FullMedia.isMetadataDownload, isFalse);

      // Tests for [Media]
      var stream = new StreamController().stream;
      expect(() => new Media(null, 0, contentType: 'foobar'),
             throwsA(isArgumentError));
      expect(() => new Media(stream, 0, contentType: null),
             throwsA(isArgumentError));
      expect(() => new Media(stream, -1, contentType: 'foobar'),
             throwsA(isArgumentError));

      var lengthUnknownMedia = new Media(stream, null);
      expect(lengthUnknownMedia.stream, equals(stream));
      expect(lengthUnknownMedia.length, equals(null));

      var media = new Media(stream, 10, contentType: 'foobar');
      expect(media.stream, equals(stream));
      expect(media.length, equals(10));
      expect(media.contentType, equals('foobar'));

      // Tests for [ResumableUploadOptions]
      expect(() => new ResumableUploadOptions(numberOfAttempts: 0),
             throwsA(isArgumentError));
      expect(() => new ResumableUploadOptions(chunkSize: 1),
             throwsA(isArgumentError));
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


      // Tests for media uploads

      group('media-upload', () {
        Stream streamFromByteArrays(byteArrays) {
          var controller = new StreamController();
          for (var array in byteArrays) {
            controller.add(array);
          }
          controller.close();
          return controller.stream;
        }
        Media mediaFromByteArrays(byteArrays, {bool withLen: true}) {
          int len = 0;
          byteArrays.forEach((array) { len += array.length; });
          if (!withLen) len = null;
          return new Media(streamFromByteArrays(byteArrays),
                           len,
                           contentType: 'foobar');
        }
        validateServerRequest(e, http_base.Request request, List<int> data) {
          return new Future.sync(() {
            var h = e['headers'];
            var r = e['response'];

            expect(request.url.toString(), equals(e['url']));
            expect(request.method, equals(e['method']));
            h.forEach((k, v) {
              expect(request.headers[k], equals(v));
            });

            expect(data, equals(e['data']));
            return r;
          });
        }
        serverRequestValidator(List expectations) {
          int i = 0;
          return (http_base.Request request, List<int> data) {
            return validateServerRequest(expectations[i++], request, data);
          };
        }

        test('simple', () {
          int i = 0;
          var bytes =
              new List.filled(10 * 256 * 1024 + 1, () => (i++) % 256);
          var expectations = [
              {
                'url' : 'http://example.com/xyz?&uploadType=media',
                'method' : 'POST',
                'data' : bytes,
                'headers' : {
                  'content-length' : '${bytes.length}',
                  'content-type' : 'foobar',
                },
                'response' : emptyResponse(200, responseHeaders, '')
              },
          ];

          httpMock.register(
              expectAsync(serverRequestValidator(expectations)), false);
          var media = mediaFromByteArrays([bytes]);
          requester.request('abc',
                            'POST',
                            uploadMedia: media,
                            uploadMediaPath: '/xyz').then(
              expectAsync((response) {}));
        });

        test('multipart-upload', () {
          // TODO
        });

        group('resumable-upload', () {
          // TODO: respect [stream]
          buildExpectations(List<int> bytes, int chunkSize, bool stream,
              {int numberOfServerErrors: 0}) {
            int totalLength = bytes.length;
            int numberOfChunks = totalLength ~/ chunkSize;
            int numberOfBytesInLastChunk = totalLength % chunkSize;

            if (numberOfBytesInLastChunk > 0) {
              numberOfChunks++;
            } else {
              numberOfBytesInLastChunk = chunkSize;
            }

            var expectations = [];

            // First request is making a POST and gets the upload URL.
            expectations.add({
              'url' : 'http://example.com/xyz?&uploadType=resumable',
              'method' : 'POST',
              'data' : [],
              'headers' : {
                'content-length' : '0',
                'content-type' : 'application/json; charset=utf-8',
                'x-upload-content-type' : 'foobar',
              }..addAll(stream ? {} : {
                'x-upload-content-length' : '$totalLength',
              }),
              'response' : emptyResponse(
                  200,
                  new HeadersImpl({'location' : ['http://upload.com/'],}),
                  '')
            });

            var lastEnd = 0;
            for (int i = 0; i < numberOfChunks; i++) {
              bool isLast = i == (numberOfChunks - 1);
              var lengthMarker = stream && !isLast ? '*' : '$totalLength';

              int bytesToExpect = chunkSize;
              if (isLast) {
                bytesToExpect = numberOfBytesInLastChunk;
              }

              var start = i * chunkSize;
              var end = start + bytesToExpect;
              var sublist = bytes.sublist(start, end);

              var firstContentRange =
                  'bytes $start-${end-1}/$lengthMarker';
              var firstRange =
                  'bytes=0-${end-1}';

              // We issue [numberOfServerErrors] 503 errors first, and then a
              // successfull response.
              for (var j = 0; j < (numberOfServerErrors + 1); j++) {
                bool successfullResponse = j == numberOfServerErrors;

                var response;
                if (successfullResponse) {
                  var headers = new HeadersImpl(
                      isLast ? {
                        'content-type' : ['application/json; charset=utf-8'],
                      } : {
                        'range' : [firstRange],
                      });
                  response = emptyResponse(isLast ? 200 : 308, headers, '');
                } else {
                  var headers = new HeadersImpl({});
                  response = emptyResponse(503, headers, '');
                }

                expectations.add({
                  'url' : 'http://upload.com/',
                  'method' : 'PUT',
                  'data' : sublist,
                  'headers' : {
                    'content-length' : '${sublist.length}',
                    'content-range' : firstContentRange,
                    'content-type' : 'foobar',
                  },
                  'response' : response,
                });
              }
            }
            return expectations;
          }

          List<List<int>> makeParts(List<int> bytes, List<int> splits) {
            var parts = [];
            int lastEnd = 0;
            for (int i = 0; i < splits.length; i++) {
              parts.add(bytes.sublist(lastEnd, splits[i]));
              lastEnd = splits[i];
            }
            return parts;
          }

          runTest(int chunkSizeInBlocks, int length, List splits, bool stream,
                  {int numberOfServerErrors: 0, resumableOptions,
                   int expectedErrorStatus, int messagesNrOfFailure}) {
            int chunkSize = chunkSizeInBlocks * 256 * 1024;

            int i = 0;
            var bytes = new List.filled(length, () => (i++) % 256);
            var parts = makeParts(bytes, splits);

            // Simulation of our server
            var expectations = buildExpectations(
                bytes, chunkSize, false,
                numberOfServerErrors: numberOfServerErrors);
            // If the server simulates 50X errors and the client resumes only
            // a limited amount of time, we'll trunkate the number of requests
            // the server expects.
            // [The client will give up and if the server expects more, the test
            //  would timeout.]
            if (expectedErrorStatus != null) {
              expectations = expectations.sublist(0, messagesNrOfFailure);
            }
            httpMock.register(
                expectAsync(serverRequestValidator(expectations),
                            count: expectations.length),
                false);

            // Our client
            var media = mediaFromByteArrays(parts);
            if (resumableOptions == null) {
              resumableOptions =
                  new ResumableUploadOptions(chunkSize: chunkSize);
            }
            var result = requester.request('abc',
                                           'POST',
                                           uploadMedia: media,
                                           uploadMediaPath: '/xyz',
                                           uploadOptions: resumableOptions);
            if (expectedErrorStatus != null) {
              result.catchError(expectAsync((error) {
                expect(error is DetailedApiRequestError, isTrue);
                expect(error.status, equals(expectedErrorStatus));
              }));
            } else {
              result.then(expectAsync((_) {}));
            }
          }

          test('length-small-block', () {
            runTest(1, 10, [10], false);
          });

          test('length-small-block-parts', () {
            runTest(1, 20, [1, 2, 3, 4, 5, 6, 7, 19, 20], false);
          });

          test('length-big-block', () {
            runTest(1, 1024 * 1024, [1024*1024], false);
          });

          test('length-big-block-parts', () {
            runTest(1, 1024 * 1024,
                    [1,
                     256*1024-1,
                     256*1024,
                     256*1024+1,
                     1024*1024-1,
                     1024*1024], false);
          });

          test('stream-small-block', () {
            runTest(1, 10, [10], true);
          });

          test('stream-small-block-parts', () {
            runTest(1, 20, [1, 2, 3, 4, 5, 6, 7, 19, 20], true);
          });

          test('stream-big-block', () {
            runTest(1, 1024 * 1024, [1024*1024], true);
          });

          test('stream-big-block-parts', () {
            runTest(1, 1024 * 1024,
                    [1,
                     256*1024-1,
                     256*1024,
                     256*1024+1,
                     1024*1024-1,
                     1024*1024], true);
          });

          test('stream-big-block-parts--with-server-error-recovery', () {
            var options = new ResumableUploadOptions(
                chunkSize: 256 * 1024, numberOfAttempts: 4);
            runTest(1, 1024 * 1024,
                    [1,
                     256*1024-1,
                     256*1024,
                     256*1024+1,
                     1024*1024-1,
                     1024*1024],
                     true,
                     numberOfServerErrors: 3,
                     resumableOptions: options);
          });

          test('stream-big-block-parts--server-error', () {
            var options = new ResumableUploadOptions(
                chunkSize: 256 * 1024, numberOfAttempts: 3);
            runTest(1, 1024 * 1024,
                    [1,
                     256*1024-1,
                     256*1024,
                     256*1024+1,
                     1024*1024-1,
                     1024*1024],
                     true,
                     numberOfServerErrors: 3,
                     resumableOptions: options,
                     expectedErrorStatus: 503,
                     messagesNrOfFailure: 4);
          });
        });
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

        var options = DownloadOptions.FullMedia;
        test('media-http-client', () {
          makeTestError();
          expect(requester.request('abc', 'GET', downloadOptions: options),
                 throwsA(isTestError));
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
          expect(requester.request('abc', 'GET', downloadOptions: options),
                 throwsA(isApiRequestError));
        });

        test('media-no-content-type', () {
          makeInvalidContentTypeError();
          expect(requester.request('abc', 'GET', downloadOptions: options),
                 throwsA(isApiRequestError));
        });

        test('media-invalid-content-type', () {
          makeInvalidContentTypeError(contentType: 'foobar');
          expect(requester.request('abc', 'GET', downloadOptions: options),
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
