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
  final Pubspec config;

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

    _writeString(gitIgnorePath, _gitIgnore);

    var libraryPrefix = Scope.toValidIdentifier(
        config.name, removeUnderscores: false);

    // These libraries are used by all APIs for making requests.
    _writeString(commonExternalLibraryPath,
                 _COMMON_EXTERNAL_LIBRARY(libraryPrefix, config.name));
    _writeString(commonInternalLibraryPath,
                 _COMMON_INTERAL_LIBRARY(libraryPrefix, config.name));
    _writeString(commonInternalTestLibraryPath,
                 _COMMON_INTERAL_TEST_LIBRARY(libraryPrefix, config.name));

    var results = <GenerateResult>[];
    for (RestDescription description in descriptions) {
      String name = description.name.toLowerCase();
      String version = description.version.toLowerCase()
          .replaceAll('.', '_').replaceAll('-', '_');

      String apiFolderPath = "$libFolderPath/$name";
      String apiTestFolderPath = "$testFolderPath/$name";

      String apiVersionFile = "$libFolderPath/$name/$version.dart";
      String apiTestVersionFile = "$testFolderPath/$name/$version.dart";

      String packagePath = 'package:${config.name}/$name/$version.dart';

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
    var lib = new DartApiLibrary.build(
        description, internalUri, externalUri, config.name);
    _writeString(outputFile, lib.librarySource);
    return lib;
  }

  void _generateApiTestLibrary(String outputFile,
                               String packageImportPath,
                               DartApiLibrary apiLibrary) {
    var testLib = new DartApiTestLibrary.build(
        apiLibrary, packageImportPath, config.name);
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
    if (config.author != null) {
      sink.writeln("author: ${config.author}");
    }
    sink.writeln("description: ${config.description}");
    if (config.homepage != null) {
      sink.writeln("homepage: ${config.homepage}");
    }
    sink.writeln("environment:");
    sink.writeln("  sdk: '${config.sdkConstraint}'");
    sink.writeln("dependencies:");
    writeDependencies(config.dependencies);
    sink.writeln("dev_dependencies:");
    writeDependencies(config.devDependencies);
  }

  String _COMMON_EXTERNAL_LIBRARY(String libPrefix, String packageName) =>
"""library ${libPrefix}.common;

import 'dart:async' as async;
import 'dart:core' as core;
import 'dart:collection' as collection;
""" + r"""
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
  static final core.Function ExponentialBackoff = (core.int failedAttempts) {
    // Do not retry more than 5 times.
    if (failedAttempts > 5) return null;

    // Wait for 2^(failedAttempts-1) seconds, before retrying.
    // i.e. 1 second, 2 seconds, 4 seconds, ...
    return new core.Duration(seconds: 1 << (failedAttempts - 1));
  };

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

  /**
   * Function for determining the [core.Duration] to wait before making the
   * next attempt. See [ExponentialBackoff] for an example.
   */
  final core.Function backoffFunction;

  ResumableUploadOptions({this.numberOfAttempts: 3,
                          this.chunkSize: 1024 * 1024,
                          core.Function backoffFunction})
      : backoffFunction = backoffFunction == null ?
          ExponentialBackoff : backoffFunction {
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

  /** Length of this range (i.e. number of bytes) */
  core.int get length => end - start + 1;

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

  String _COMMON_INTERAL_LIBRARY(String libPrefix, String packageName) =>
"""
library ${libPrefix}.common_internal;

import "dart:async";
import "dart:convert";
import "dart:collection" as collection;

import "package:crypto/crypto.dart" as crypto;
import "../common/common.dart" as common_external;
import "package:http/http.dart" as http;

const String USER_AGENT_STRING =
    'google-api-dart-client ${config.name}/${config.version}';

""" + r"""
const CONTENT_TYPE_JSON_UTF8 = 'application/json; charset=utf-8';

/**
 * Base class for all API clients, offering generic methods for
 * HTTP Requests to the API
 */
class ApiRequester {
  final http.Client _httpClient;
  final String _rootUrl;
  final String _basePath;

  ApiRequester(this._httpClient, this._rootUrl, this._basePath) {
    assert(_rootUrl.endsWith('/'));
  }


  /**
   * Sends a HTTPRequest using [method] (usually GET or POST) to [requestUrl]
   * using the specified [urlParams] and [queryParams]. Optionally include a
   * [body] and/or [uploadMedia] in the request.
   *
   * If [uploadMedia] was specified [downloadOptions] must be
   * [DownloadOptions.Metadata] or `null`.
   *
   * If [downloadOptions] is [DownloadOptions.Metadata] the result will be
   * decoded as JSON.
   *
   * If [downloadOptions] is `null` the result will be a Future completing with
   * `null`.
   *
   * Otherwise the result will be downloaded as a [common_external.Media]
   */
  Future request(String requestUrl, String method,
                 {String body, Map queryParams,
                  common_external.Media uploadMedia,
                  common_external.UploadOptions uploadOptions,
                  common_external.DownloadOptions downloadOptions:
                  common_external.DownloadOptions.Metadata}) {
    if (uploadMedia != null &&
        downloadOptions != common_external.DownloadOptions.Metadata) {
      throw new ArgumentError('When uploading a [Media] you cannot download a '
                              '[Media] at the same time!');
    }
    common_external.ByteRange downloadRange;
    if (downloadOptions is common_external.PartialDownloadOptions &&
        !downloadOptions.isFullDownload) {
      downloadRange = downloadOptions.range;
    }

    return _request(requestUrl, method, body, queryParams,
                    uploadMedia, uploadOptions,
                    downloadOptions,
                    downloadRange)
        .then(_validateResponse).then((http.StreamedResponse response) {
      if (downloadOptions == null) {
        // If no download options are given, the response is of no interest
        // and we will drain the stream.
        return response.stream.drain();
      } else if (downloadOptions == common_external.DownloadOptions.Metadata) {
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
          // We silently ignore errors here. If no content-length was specified
          // we use `null`.
          // Please note that the code below still asserts the content-length
          // is correct for range downloads.
        }

        if (downloadRange != null) {
          if (contentLength != downloadRange.length) {
            throw new common_external.ApiRequestError(
                "Content length of response does not match requested range "
                "length.");
          }
          var contentRange = response.headers['content-range'];
          var expected = 'bytes ${downloadRange.start}-${downloadRange.end}/';
          if (contentRange == null || !contentRange.startsWith(expected)) {
            throw new common_external.ApiRequestError("Attempting partial "
                "download but got invalid 'Content-Range' header "
                "(was: $contentRange, expected: $expected).");
          }
        }

        return new common_external.Media(
            response.stream, contentLength, contentType: contentType);
      }
    });
  }

  Future _request(String requestUrl, String method,
                  String body, Map queryParams,
                  common_external.Media uploadMedia,
                  common_external.UploadOptions uploadOptions,
                  common_external.DownloadOptions downloadOptions,
                  common_external.ByteRange downloadRange) {
    bool downloadAsMedia =
        downloadOptions != null &&
        downloadOptions != common_external.DownloadOptions.Metadata;

    if (queryParams == null) queryParams = {};

    if (uploadMedia != null) {
      if (uploadOptions is common_external.ResumableUploadOptions) {
        queryParams['uploadType'] = const ['resumable'];
      } else if (body == null) {
        queryParams['uploadType'] = const ['media'];
      } else {
        queryParams['uploadType'] = const ['multipart'];
      }
    }

    if (downloadAsMedia) {
      queryParams['alt'] = const ['media'];
    } else if (downloadOptions != null) {
      queryParams['alt'] = const ['json'];
    }

    var path;
    if (requestUrl.startsWith('/')) {
      path ="$_rootUrl${requestUrl.substring(1)}";
    } else {
      path ="$_rootUrl${_basePath.substring(1)}$requestUrl";
    }

    bool containsQueryParameter = path.contains('?');
    addQueryParameter(String name, String value) {
      name = Escaper.escapeQueryComponent(name);
      value = Escaper.escapeQueryComponent(value);
      if (containsQueryParameter) {
        path = '$path&$name=$value';
      } else {
        path = '$path?$name=$value';
      }
      containsQueryParameter = true;
    }
    queryParams.forEach((String key, List<String> values) {
      for (var value in values) {
        addQueryParameter(key, value);
      }
    });

    var uri = Uri.parse(path);

    Future simpleUpload() {
      var bodyStream = uploadMedia.stream;
      var request = new RequestImpl(method, uri, bodyStream);
      request.headers.addAll({
        'user-agent' : USER_AGENT_STRING,
        'content-type' : uploadMedia.contentType,
        'content-length' : '${uploadMedia.length}'
      });
      return _httpClient.send(request);
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

      var headers;
      if (downloadRange != null) {
        headers = {
          'user-agent' : USER_AGENT_STRING,
          'content-type' : CONTENT_TYPE_JSON_UTF8,
          'content-length' : '$length',
          'range' :  'bytes=${downloadRange.start}-${downloadRange.end}',
        };
      } else {
        headers = {
          'user-agent' : USER_AGENT_STRING,
          'content-type' : CONTENT_TYPE_JSON_UTF8,
          'content-length' : '$length',
        };
      }

      var request = new RequestImpl(method, uri, bodyController.stream);
      request.headers.addAll(headers);
      return _httpClient.send(request);
    }

    if (uploadMedia != null) {
      // Three upload types:
      // 1. Resumable: Upload of data + metdata with multiple requests.
      // 2. Simple: Upload of media.
      // 3. Multipart: Upload of data + metadata.

      if (uploadOptions is common_external.ResumableUploadOptions) {
        var helper = new ResumableMediaUploader(
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
        var uploader = new MultipartMediaUploader(
            _httpClient, uploadMedia, body, uri, method);
        return uploader.upload();
      }
    }
    return simpleRequest();
  }
}


/**
 * Does media uploads using the multipart upload protocol.
 */
class MultipartMediaUploader {
  static final _boundary = '314159265358979323846';
  static final _base64Encoder = new Base64Encoder();

  final http.Client _httpClient;
  final common_external.Media _uploadMedia;
  final Uri _uri;
  final String _body;
  final String _method;

  MultipartMediaUploader(
      this._httpClient, this._uploadMedia, this._body, this._uri, this._method);

  Future<http.StreamedResponse> upload() {
    var base64MediaStream =
        _uploadMedia.stream.transform(_base64Encoder).transform(ASCII.encoder);
    var base64MediaStreamLength =
        Base64Encoder.lengthOfBase64Stream(_uploadMedia.length);

    // NOTE: We assume that [_body] is encoded JSON without any \r or \n in it.
    // This guarantees us that [_body] cannot contain a valid multipart
    // boundary.
    var bodyHead =
        '--$_boundary\r\n'
        "Content-Type: $CONTENT_TYPE_JSON_UTF8\r\n\r\n"
        + _body +
        '\r\n--$_boundary\r\n'
        "Content-Type: ${_uploadMedia.contentType}\r\n"
        "Content-Transfer-Encoding: base64\r\n\r\n";
    var bodyTail = '\r\n--$_boundary--';

    var totalLength =
        bodyHead.length + base64MediaStreamLength + bodyTail.length;

    var bodyController = new StreamController<List<int>>();
    bodyController.add(UTF8.encode(bodyHead));
    bodyController.addStream(base64MediaStream).then((_) {
      bodyController.add(UTF8.encode(bodyTail));
    }).catchError((error, stack) {
      bodyController.addError(error, stack);
    }).then((_) {
      bodyController.close();
    });

    var headers = {
        'user-agent' : USER_AGENT_STRING,
        'content-type' : "multipart/related; boundary=\"$_boundary\"",
        'content-length' : '$totalLength'
    };
    var bodyStream = bodyController.stream;
    var request = new RequestImpl(_method, _uri, bodyStream);
    request.headers.addAll(headers);
    return _httpClient.send(request);
  }
}


/**
 * Base64 encodes a stream of bytes.
 */
class Base64Encoder implements StreamTransformer<List<int>, String> {
  static int lengthOfBase64Stream(int lengthOfByteStream) {
    return ((lengthOfByteStream + 2) ~/ 3) * 4;
  }

  Stream<String> bind(Stream<List<int>> stream) {
    StreamController<String> controller;

    // Holds between 0 and 3 bytes and is used as a buffer.
    List<int> remainingBytes = [];

    void onData(List<int> bytes) {
      if ((remainingBytes.length + bytes.length) < 3) {
        remainingBytes.addAll(bytes);
        return;
      }
      int start;
      if (remainingBytes.length == 0) {
        start = 0;
      } else if (remainingBytes.length == 1) {
        remainingBytes.add(bytes[0]);
        remainingBytes.add(bytes[1]);
        start = 2;
      } else if (remainingBytes.length == 2) {
        remainingBytes.add(bytes[0]);
        start = 1;
      }

      // Convert & Send bytes from buffer (if necessary).
      if (remainingBytes.length > 0) {
        controller.add(crypto.CryptoUtils.bytesToBase64(remainingBytes));
        remainingBytes.clear();
      }

      int chunksOf3 = (bytes.length - start) ~/ 3;
      int end = start + 3 * chunksOf3;
      int remaining = bytes.length - end;

      // Convert & Send main bytes.
      if (start == 0 && end == bytes.length) {
        // Fast path if [bytes] are devisible by 3.
        controller.add(crypto.CryptoUtils.bytesToBase64(bytes));
      } else {
        controller.add(
            crypto.CryptoUtils.bytesToBase64(bytes.sublist(start, end)));

        // Buffer remaining bytes if necessary.
        if (end < bytes.length) {
          remainingBytes.addAll(bytes.sublist(end));
        }
      }
    }

    void onError(error, stack) {
      controller.addError(error, stack);
    }

    void onDone() {
      if (remainingBytes.length > 0) {
        controller.add(crypto.CryptoUtils.bytesToBase64(remainingBytes));
        remainingBytes.clear();
      }
      controller.close();
    }

    var subscription;
    controller = new StreamController<String>(
        onListen: () {
          subscription = stream.listen(
              onData, onError: onError, onDone: onDone);
        },
        onPause: () {
          subscription.pause();
        },
        onResume: () {
          subscription.resume();
        },
        onCancel: () {
          subscription.cancel();
        });
    return controller.stream;
  }
}


// TODO: Buffer less if we know the content length in advance.
/**
 * Does media uploads using the resumable upload protocol.
 */
class ResumableMediaUploader {
  final http.Client _httpClient;
  final common_external.Media _uploadMedia;
  final Uri _uri;
  final String _body;
  final String _method;
  final common_external.ResumableUploadOptions _options;

  ResumableMediaUploader(
      this._httpClient, this._uploadMedia, this._body, this._uri, this._method,
      this._options);

  /**
   * Returns the final [http.StreamedResponse] if the upload succeded and
   * completes with an error otherwise.
   *
   * The returned response stream has not been listened to.
   */
  Future<http.StreamedResponse> upload() {
    return _startSession().then((Uri uploadUri) {
      StreamSubscription subscription;

      var completer = new Completer<http.StreamedResponse>();
      bool completed = false;

      var chunkStack = new ChunkStack(_options.chunkSize);
      subscription = _uploadMedia.stream.listen((List<int> bytes) {
        chunkStack.addBytes(bytes);

        // Upload all but the last chunk.
        // The final send will be done in the [onDone] handler.
        if (chunkStack.length > 1) {
          // Pause the input stream.
          subscription.pause();

          // Upload all chunks except the last one.
          var fullChunks = chunkStack.removeSublist(0, chunkStack.length - 1);
          Future.forEach(fullChunks,
                         (c) => _uploadChunkDrained(uploadUri, c)).then((_) {
            // All chunks uploaded, we can continue consuming data.
            subscription.resume();
          }).catchError((error, stack) {
            subscription.cancel();
            completed = true;
            completer.completeError(error, stack);
          });
        }
      }, onError: (error, stack) {
        subscription.cancel();
        if (!completed) {
          completed = true;
          completer.completeError(error, stack);
        }
      }, onDone: () {
        if (!completed) {
          chunkStack.finalize();

          var lastChunk;
          if (chunkStack.totalByteLength > 0) {
            assert(chunkStack.length == 1);
            lastChunk = chunkStack.removeSublist(0, chunkStack.length).first;
          } else {
            lastChunk = new ResumableChunk([], 0, 0);
          }
          var end = lastChunk.endOfChunk;

          // Validate that we have the correct number of bytes if length was
          // specified.
          if (_uploadMedia.length != null) {
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
          _uploadChunkResumable(uploadUri, lastChunk, lastChunk: true)
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

    var request = new RequestImpl(_method, _uri, bodyStream);
    request.headers.addAll({
      'user-agent' : USER_AGENT_STRING,
      'content-type' : CONTENT_TYPE_JSON_UTF8,
      'content-length' : '$length',
      'x-upload-content-type' : _uploadMedia.contentType,
      'x-upload-content-length' : '${_uploadMedia.length}',
    });

    return _httpClient.send(request).then((http.StreamedResponse response) {
      return response.stream.drain().then((_) {
        var uploadUri = response.headers['location'];
        if (response.statusCode != 200 || uploadUri == null) {
          throw new common_external.ApiRequestError(
              'Invalid response for resumable upload attempt '
              '(status was: ${response.statusCode})');
        }
        return Uri.parse(uploadUri);
      });
    });
  }

  /**
   * Uploads [chunk], retries upon server errors. The response stream will be
   * drained.
   */
  Future _uploadChunkDrained(Uri uri, ResumableChunk chunk) {
    return _uploadChunkResumable(uri, chunk).then((response) {
      return response.stream.drain();
    });
  }

  /**
   * Does repeated attempts to upload [chunk].
   */
  Future _uploadChunkResumable(Uri uri,
                               ResumableChunk chunk,
                               {bool lastChunk: false}) {
    tryUpload(int attemptsLeft) {
      return _uploadChunk(uri, chunk, lastChunk: lastChunk)
          .then((http.StreamedResponse response) {
        var status = response.statusCode;
        if (attemptsLeft > 0 &&
            (status == 500 || (502 <= status && status < 504))) {
          return response.stream.drain().then((_) {
            // Delay the next attempt. Default backoff function is exponential.
            int failedAttemts = _options.numberOfAttempts - attemptsLeft;
            var duration = _options.backoffFunction(failedAttemts);
            if (duration == null) {
              throw new common_external.DetailedApiRequestError(
                  status,
                  'Resumable upload: Uploading a chunk resulted in status '
                  '$status. Maximum number of retries reached.');
            }

            return new Future.delayed(duration).then((_) {
              return tryUpload(attemptsLeft - 1);
            });
          });
        } else if (!lastChunk && status != 308) {
            return response.stream.drain().then((_) {
              throw new common_external.DetailedApiRequestError(
                  status,
                  'Resumable upload: Uploading a chunk resulted in status '
                  '$status instead of 308.');
            });
        } else if (lastChunk && status != 201 && status != 200) {
          return response.stream.drain().then((_) {
            throw new common_external.DetailedApiRequestError(
                status,
                'Resumable upload: Uploading a chunk resulted in status '
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
   * Returns the returned [http.StreamedResponse] or completes with an error if
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

    var headers = {
        'user-agent' : USER_AGENT_STRING,
        'content-type' : _uploadMedia.contentType,
        'content-length' : '${chunk.length}',
        'content-range' :
            'bytes ${chunk.offset}-${chunk.endOfChunk - 1}/$mediaTotalLength',
    };

    var stream = _listOfBytes2Stream(chunk.byteArrays);
    var request = new RequestImpl('PUT', uri, stream);
    request.headers.addAll(headers);
    return _httpClient.send(request);
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
 * Represents a stack of [ResumableChunk]s.
 */
class ChunkStack {
  final int _chunkSize;
  final List<ResumableChunk> _chunkStack = [];

  // Currently accumulated data.
  List<List<int>> _byteArrays = [];
  int _length = 0;
  int _totalLength = 0;
  int _offset = 0;

  bool _finalized = false;

  ChunkStack(this._chunkSize);

  int get length => _chunkStack.length;

  int get totalByteLength => _offset;

  /**
   * Returns the chunks [from] ... [to] and deletes it from the stack.
   */
  List<ResumableChunk> removeSublist(int from, int to) {
    var sublist = _chunkStack.sublist(from, to);
    _chunkStack.removeRange(from, to);
    return sublist;
  }

  /**
   * Adds [bytes] to the buffer. If the buffer is larger than the given chunk
   * size a new [ResumableChunk] will be created.
   */
  void addBytes(List<int> bytes) {
    if (_finalized) {
      throw new StateError('ChunkStack has already been finalized.');
    }

    var remaining = _chunkSize - _length;

    if (bytes.length >= remaining) {
      var left = bytes.sublist(0, remaining);
      var right = bytes.sublist(remaining);

      _byteArrays.add(left);
      _length += left.length;

      _chunkStack.add(new ResumableChunk(_byteArrays, _offset, _length));

      _byteArrays = [];
      _offset += _length;
      _length = 0;

      addBytes(right);
    } else if (bytes.length > 0) {
      _byteArrays.add(bytes);
      _length += bytes.length;
    }
  }

  /**
   * Finalizes this [ChunkStack] and creates the last chunk (may have less bytes
   * than the chunk size, but not zero).
   */
  void finalize() {
    if (_finalized) {
      throw new StateError('ChunkStack has already been finalized.');
    }
    _finalized = true;

    if (_length > 0) {
      _chunkStack.add(new ResumableChunk(_byteArrays, _offset, _length));
      _offset += _length;
    }
  }
}


/**
 * Represents a chunk of data that will be transferred in one http request.
 */
class ResumableChunk {
  final List<List<int>> byteArrays;
  final int offset;
  final int length;

  /**
   * Index of the next byte after this chunk.
   */
  int get endOfChunk => offset + length;

  ResumableChunk(this.byteArrays, this.offset, this.length);
}

class RequestImpl extends http.BaseRequest {
  final Stream<List<int>> _stream;

  RequestImpl(String method, Uri url, [Stream<List<int>> stream])
      : _stream = stream == null ? new Stream.fromIterable([]) : stream,
        super(method, url);

  http.ByteStream finalize() {
    super.finalize();
    return new http.ByteStream(_stream);
  }
}


class Escaper {
  // Character class definitions from RFC 6570
  // (see http://tools.ietf.org/html/rfc6570)
  // ALPHA          =  %x41-5A / %x61-7A   ; A-Z / a-z
  // DIGIT          =  %x30-39             ; 0
  // HEXDIG         =  DIGIT / "A" / "B" / "C" / "D" / "E" / "F"
  // pct-encoded    =  "%" HEXDIG HEXDIG
  // unreserved     =  ALPHA / DIGIT / "-" / "." / "_" / "~"
  // reserved       =  gen-delims / sub-delims
  // gen-delims     =  ":" / "/" / "?" / "#" / "[" / "]" / "@"
  // sub-delims     =  "!" / "$" / "&" / "'" / "(" / ")"
  //                /  "*" / "+" / "," / ";" / "="

  // NOTE: Uri.encodeQueryComponent() does the following:
  // ...
  // Then the resulting bytes are "percent-encoded". This transforms spaces
  // (U+0020) to a plus sign ('+') and all bytes that are not the ASCII decimal
  // digits, letters or one of '-._~' are written as a percent sign '%'
  // followed by the two-digit hexadecimal representation of the byte.
  // ...

  // NOTE: Uri.encodeFull() does the following:
  // ...
  // All characters except uppercase and lowercase letters, digits and the
  // characters !#$&'()*+,-./:;=?@_~ are percent-encoded.
  // ...

  static String ecapeVariableReserved(String name) {
    // ... perform variable expansion, as defined in Section 3.2.1, with the
    // allowed characters being those in the set
    // (unreserved / reserved / pct-encoded)

    // NOTE: The chracters [ and ] need (according to URI Template spec) not be
    // percent encoded. The dart implementation does percent-encode [ and ].
    // This gives us in effect a conservative encoding, since the server side
    // must interpret percent-encoded parts anyway due to arbitrary unicode.

    // NOTE: This is broken in the discovery protocol. It allows ? and & to be
    // expanded via URI Templates which may generate completely bogus URIs.
    // TODO/FIXME: Should we change this to _encodeUnreserved() as well
    // (disadvantage, slashes get encoded at this point)?
    return Uri.encodeFull(name);
  }

  static String ecapePathComponent(String name) {
    // For each defined variable in the variable-list, append "/" to the
    // result string and then perform variable expansion, as defined in
    // Section 3.2.1, with the allowed characters being those in the
    // *unreserved set*.
    return _encodeUnreserved(name);
  }

  static String ecapeVariable(String name) {
    // ... perform variable expansion, as defined in Section 3.2.1, with the
    // allowed characters being those in the *unreserved set*.
    return _encodeUnreserved(name);
  }

  static String escapeQueryComponent(String name) {
    // This method will not be used by UriTemplate, but rather for encoding
    // normal query name/value pairs.

    // NOTE: For safety reasons we use '%20' instead of '+' here as well.
    // TODO/FIXME: Should we do this?
    return _encodeUnreserved(name);
  }

  static String _encodeUnreserved(String name) {
    // The only difference between dart's [Uri.encodeQueryComponent] and the
    // encoding defined by RFC 6570 for the above-defined unreserved character
    // set is the encoding of space.
    // Dart's Uri class will convert spaces to '+' which we replace by '%20'.
    return Uri.encodeQueryComponent(name).replaceAll('+', '%20');
  }
}


Future<http.StreamedResponse> _validateResponse(
    http.StreamedResponse response) {
  var statusCode = response.statusCode;

  // TODO: We assume that status codes between [200..400[ are OK.
  // Can we assume this?
  if (statusCode < 200 || statusCode >= 400) {
    throwGeneralError() {
      throw new common_external.ApiRequestError(
          'No error details. Http status was: ${response.statusCode}.');
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


Stream<String> _decodeStreamAsText(http.StreamedResponse response) {
  // TODO: Correctly handle the response content-types, using correct
  // decoder.
  // Currently we assume that the api endpoint is responding with json
  // encoded in UTF8.
  String contentType = response.headers['content-type'];
  if (contentType != null &&
      contentType.toLowerCase().startsWith('application/json')) {
    return response.stream.transform(new Utf8Decoder(allowMalformed: true));
  } else {
    return null;
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


  String _COMMON_INTERAL_TEST_LIBRARY(String libPrefix, String packageName) =>
"""library ${libPrefix}.common_internal_test;
import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart' as crypto;
import 'package:$packageName/common/common.dart';
import 'package:$packageName/src/common_internal.dart';
import 'package:http/http.dart' as http;
import 'package:unittest/unittest.dart';
""" + r"""
class HttpServerMock extends http.BaseClient {
  Function _callback;
  bool _expectJson;

  void register(Function callback, bool expectJson) {
    _callback = callback;
    _expectJson = expectJson;
  }

  Future<http.StreamedResponse> send(http.BaseRequest request) {
    if (_expectJson) {
      return request.finalize()
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
      var stream = request.finalize();
      if (stream == null) {
        return _callback(request, []);
      } else {
        return stream.toBytes().then((data) {
          return _callback(request, data);
        });
      }
    }
  }
}

http.StreamedResponse stringResponse(int status, Map headers, String body) {
  var stream = new Stream.fromIterable([UTF8.encode(body)]);
  return new http.StreamedResponse(stream, status, headers: headers);
}

http.StreamedResponse binaryResponse(int status,
                                     Map<String,String> headers,
                                     List<int> bytes) {
  var stream = new Stream.fromIterable([bytes]);
  return new http.StreamedResponse(stream, status, headers: headers);
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
    test('escaper', () {
      expect(Escaper.ecapePathComponent('a/b%c '), equals('a%2Fb%25c%20'));
      expect(Escaper.ecapeVariable('a/b%c '), equals('a%2Fb%25c%20'));
      expect(Escaper.ecapeVariableReserved('a/b%c+ '), equals('a/b%25c+%20'));
      expect(Escaper.escapeQueryComponent('a/b%c '), equals('a%2Fb%25c%20'));
    });

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

    test('base64-encoder', () {
      var base64encoder = new Base64Encoder();

      testString(String msg, String expectedBase64) {
        var msgBytes = UTF8.encode(msg);

        Stream singleByteStream(List<int> msgBytes) {
          var controller = new StreamController();
          for (var byte in msgBytes) {
            controller.add([byte]);
          }
          controller.close();
          return controller.stream;
        }

        Stream allByteStream(List<int> msgBytes) {
          var controller = new StreamController();
          controller.add(msgBytes);
          controller.close();
          return controller.stream;
        }

        singleByteStream(msgBytes)
            .transform(base64encoder)
            .join('')
            .then(expectAsync((String result) {
          expect(result, equals(expectedBase64));
        }));

        allByteStream(msgBytes)
            .transform(base64encoder)
            .join('')
            .then(expectAsync((String result) {
          expect(result, equals(expectedBase64));
        }));

        expect(Base64Encoder.lengthOfBase64Stream(msg.length),
               equals(expectedBase64.length));
      }

      testString('pleasure.', 'cGxlYXN1cmUu');
      testString('leasure.', 'bGVhc3VyZS4=');
      testString('easure.', 'ZWFzdXJlLg==');
      testString('asure.', 'YXN1cmUu');
      testString('sure.', 'c3VyZS4=');
      testString('', '');
    });

    group('chunk-stack', () {
      var chunkSize = 9;

      folded(List<List<int>> byteArrays) {
        return byteArrays.fold([], (buf, e) => buf..addAll(e));
      }

      test('finalize', () {
        var chunkStack = new ChunkStack(9);
        chunkStack.finalize();
        expect(() => chunkStack.addBytes([1]), throwsA(isStateError));
        expect(() => chunkStack.finalize(), throwsA(isStateError));
      });

      test('empty', () {
        var chunkStack = new ChunkStack(9);
        expect(chunkStack.length, equals(0));
        chunkStack.finalize();
        expect(chunkStack.length, equals(0));
      });

      test('sub-chunk-size', () {
        var bytes = [1, 2, 3];

        var chunkStack = new ChunkStack(9);
        chunkStack.addBytes(bytes);
        expect(chunkStack.length, equals(0));
        chunkStack.finalize();
        expect(chunkStack.length, equals(1));
        expect(chunkStack.totalByteLength, equals(bytes.length));

        var chunks = chunkStack.removeSublist(0, chunkStack.length);
        expect(chunkStack.length, equals(0));
        expect(chunks, hasLength(1));

        expect(folded(chunks.first.byteArrays), equals(bytes));
        expect(chunks.first.offset, equals(0));
        expect(chunks.first.length, equals(3));
        expect(chunks.first.endOfChunk, equals(bytes.length));
      });

      test('exact-chunk-size', () {
        var bytes = [1, 2, 3, 4, 5, 6, 7, 8, 9];

        var chunkStack = new ChunkStack(9);
        chunkStack.addBytes(bytes);
        expect(chunkStack.length, equals(1));
        chunkStack.finalize();
        expect(chunkStack.length, equals(1));
        expect(chunkStack.totalByteLength, equals(bytes.length));

        var chunks = chunkStack.removeSublist(0, chunkStack.length);
        expect(chunkStack.length, equals(0));
        expect(chunks, hasLength(1));

        expect(folded(chunks.first.byteArrays), equals(bytes));
        expect(chunks.first.offset, equals(0));
        expect(chunks.first.length, equals(bytes.length));
        expect(chunks.first.endOfChunk, equals(bytes.length));
      });

      test('super-chunk-size', () {
        var bytes0 = [1, 2, 3, 4];
        var bytes1 = [1, 2, 3, 4];
        var bytes2 = [5, 6, 7, 8, 9, 10, 11];
        var bytes = folded([bytes0, bytes1, bytes2]);

        var chunkStack = new ChunkStack(9);
        chunkStack.addBytes(bytes0);
        chunkStack.addBytes(bytes1);
        chunkStack.addBytes(bytes2);
        expect(chunkStack.length, equals(1));
        chunkStack.finalize();
        expect(chunkStack.length, equals(2));
        expect(chunkStack.totalByteLength, equals(bytes.length));

        var chunks = chunkStack.removeSublist(0, chunkStack.length);
        expect(chunkStack.length, equals(0));
        expect(chunks, hasLength(2));

        expect(folded(chunks.first.byteArrays),
               equals(bytes.sublist(0, chunkSize)));
        expect(chunks.first.offset, equals(0));
        expect(chunks.first.length, equals(chunkSize));
        expect(chunks.first.endOfChunk, equals(chunkSize));

        expect(folded(chunks.last.byteArrays),
               equals(bytes.sublist(chunkSize)));
        expect(chunks.last.offset, equals(chunkSize));
        expect(chunks.last.length, equals(bytes.length - chunkSize));
        expect(chunks.last.endOfChunk, equals(bytes.length));
      });
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

      var responseHeaders = {
          'content-type' : 'application/json; charset=utf-8',
      };

      setUp(() {
        httpMock = new HttpServerMock();
        rootUrl = 'http://example.com/';
        basePath = '/base/';
        requester = new ApiRequester(httpMock, rootUrl, basePath);
      });


      // Tests for Request, Response

      group('metadata-request-response', () {
        test('empty-request-empty-response', () {
          httpMock.register(expectAsync((http.BaseRequest request, json) {
            expect(request.method, equals('GET'));
            expect('${request.url}',
                   equals('http://example.com/base/abc?alt=json'));
            return stringResponse(200, responseHeaders, '');
          }), true);
          requester.request('abc', 'GET').then(expectAsync((response) {
            expect(response, isNull);
          }));
        });

        test('json-map-request-json-map-response', () {
          httpMock.register(expectAsync((http.BaseRequest request, json) {
            expect(request.method, equals('GET'));
            expect('${request.url}',
                   equals('http://example.com/base/abc?alt=json'));
            expect(json is Map, isTrue);
            expect(json, hasLength(1));
            expect(json['foo'], equals('bar'));
            return stringResponse(200, responseHeaders, '{"foo2" : "bar2"}');
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
          httpMock.register(expectAsync((http.BaseRequest request, json) {
            expect(request.method, equals('GET'));
            expect('${request.url}',
                   equals('http://example.com/base/abc?alt=json'));
            expect(json is List, isTrue);
            expect(json, hasLength(2));
            expect(json[0], equals('a'));
            expect(json[1], equals(1));
            return stringResponse(200, responseHeaders, '["b", 2]');
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
      });

      group('media-download', () {
        test('media-download', () {
          var data256 = new List.generate(256, (i) => i);
          httpMock.register(expectAsync((http.BaseRequest request, data) {
            expect(request.method, equals('GET'));
            expect('${request.url}',
                   equals('http://example.com/base/abc?alt=media'));
            expect(data, isEmpty);
            var headers = {
                'content-length' : '${data256.length}',
                'content-type' : 'foobar',
            };
            return binaryResponse(200, headers, data256);
          }), false);
          requester.request('abc',
                            'GET',
                            body: '',
                            downloadOptions: DownloadOptions.FullMedia).then(
              expectAsync((Media media) {
            expect(media.contentType, equals('foobar'));
            expect(media.length, equals(data256.length));
            media.stream.fold([], (b, d) => b..addAll(d)).then(expectAsync((d) {
              expect(d, equals(data256));
            }));
          }));
        });

        test('media-download-partial', () {
          var data256 = new List.generate(256, (i) => i);
          var data64 = data256.sublist(128, 128 + 64);

          httpMock.register(expectAsync((http.BaseRequest request, data) {
            expect(request.method, equals('GET'));
            expect('${request.url}',
                   equals('http://example.com/base/abc?alt=media'));
            expect(data, isEmpty);
            expect(request.headers['range'],
                   equals('bytes=128-191'));
            var headers = {
                'content-length' : '${data64.length}',
                'content-type' : 'foobar',
                'content-range' : 'bytes 128-191/256',
            };
            return binaryResponse(200, headers, data64);
          }), false);
          var range = new ByteRange(128, 128 + 64 - 1);
          var options = new PartialDownloadOptions(range);
          requester.request('abc',
                            'GET',
                            body: '',
                            downloadOptions: options).then(
              expectAsync((Media media) {
            expect(media.contentType, equals('foobar'));
            expect(media.length, equals(data64.length));
            media.stream.fold([], (b, d) => b..addAll(d)).then(expectAsync((d) {
              expect(d, equals(data64));
            }));
          }));
        });

        test('json-upload-media-download', () {
          var data256 = new List.generate(256, (i) => i);
          httpMock.register(expectAsync((http.BaseRequest request, json) {
            expect(request.method, equals('GET'));
            expect('${request.url}',
                    equals('http://example.com/base/abc?alt=media'));
            expect(json is List, isTrue);
            expect(json, hasLength(2));
            expect(json[0], equals('a'));
            expect(json[1], equals(1));

            var headers = {
                'content-length' : '${data256.length}',
                'content-type' : 'foobar',
            };
            return binaryResponse(200, headers, data256);
          }), true);
          requester.request('abc',
                            'GET',
                            body: JSON.encode(['a', 1]),
                            downloadOptions: DownloadOptions.FullMedia).then(
              expectAsync((Media media) {
            expect(media.contentType, equals('foobar'));
            expect(media.length, equals(data256.length));
            media.stream.fold([], (b, d) => b..addAll(d)).then(expectAsync((d) {
              expect(d, equals(data256));
            }));
          }));
        });
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
        validateServerRequest(e, http.BaseRequest request, List<int> data) {
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
          return (http.BaseRequest request, List<int> data) {
            return validateServerRequest(expectations[i++], request, data);
          };
        }

        test('simple', () {
          var bytes = new List.generate(10 * 256 * 1024 + 1, (i) => i % 256);
          var expectations = [
              {
                'url' : 'http://example.com/xyz?uploadType=media&alt=json',
                'method' : 'POST',
                'data' : bytes,
                'headers' : {
                  'content-length' : '${bytes.length}',
                  'content-type' : 'foobar',
                },
                'response' : stringResponse(200, responseHeaders, '')
              },
          ];

          httpMock.register(
              expectAsync(serverRequestValidator(expectations)), false);
          var media = mediaFromByteArrays([bytes]);
          requester.request('/xyz',
                            'POST',
                            uploadMedia: media).then(
              expectAsync((response) {}));
        });

        test('multipart-upload', () {
          var bytes = new List.generate(10 * 256 * 1024 + 1, (i) => i % 256);
          var contentBytes =
              '--314159265358979323846\r\n'
              'Content-Type: $CONTENT_TYPE_JSON_UTF8\r\n\r\n'
              'BODY'
              '\r\n--314159265358979323846\r\n'
              'Content-Type: foobar\r\n'
              'Content-Transfer-Encoding: base64\r\n\r\n'
              '${crypto.CryptoUtils.bytesToBase64(bytes)}'
              '\r\n--314159265358979323846--';

          var expectations = [
              {
                'url' : 'http://example.com/xyz?uploadType=multipart&alt=json',
                'method' : 'POST',
                'data' : UTF8.encode('$contentBytes'),
                'headers' : {
                  'content-length' : '${contentBytes.length}',
                  'content-type' :
                      'multipart/related; boundary="314159265358979323846"',
                },
                'response' : stringResponse(200, responseHeaders, '')
              },
          ];

          httpMock.register(
              expectAsync(serverRequestValidator(expectations)), false);
          var media = mediaFromByteArrays([bytes]);
          requester.request('/xyz',
                            'POST',
                            body: 'BODY',
                            uploadMedia: media).then(
              expectAsync((response) {}));
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
              'url' : 'http://example.com/xyz?uploadType=resumable&alt=json',
              'method' : 'POST',
              'data' : [],
              'headers' : {
                'content-length' : '0',
                'content-type' : 'application/json; charset=utf-8',
                'x-upload-content-type' : 'foobar',
              }..addAll(stream ? {} : {
                'x-upload-content-length' : '$totalLength',
              }),
              'response' : stringResponse(
                  200, {'location' : 'http://upload.com/'}, '')
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
                  var headers = isLast
                      ? { 'content-type' : 'application/json; charset=utf-8' }
                      : {'range' : firstRange };
                  response = stringResponse(isLast ? 200 : 308, headers, '');
                } else {
                  var headers = {};
                  response = stringResponse(503, headers, '');
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
            var bytes = new List.generate(length, (i) => i % 256);
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
            var result = requester.request('/xyz',
                                           'POST',
                                           uploadMedia: media,
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

          Function backoffWrapper(int callCount) {
            return expectAsync((int failedAttempts) {
              var exp = ResumableUploadOptions.ExponentialBackoff;
              Duration duration = exp(failedAttempts);
              expect(duration.inSeconds, equals(1 << (failedAttempts - 1)));
              return const Duration(milliseconds: 1);
            }, count: callCount);
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
            var numFailedAttempts = 4 * 3;
            var options = new ResumableUploadOptions(
                chunkSize: 256 * 1024, numberOfAttempts: 4,
                backoffFunction: backoffWrapper(numFailedAttempts));
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
            var numFailedAttempts = 2;
            var options = new ResumableUploadOptions(
                chunkSize: 256 * 1024, numberOfAttempts: 3,
                backoffFunction: backoffWrapper(numFailedAttempts));
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
          // All errors from the [http.Client] propagate through.
          // We use [TestError] to simulate it.
          httpMock.register(expectAsync((http.BaseRequest request, string) {
            return new Future.error(new TestError());
          }), false);
        }

        makeDetailed400Error() {
          httpMock.register(expectAsync((http.BaseRequest request, string) {
            return stringResponse(400,
                                 responseHeaders,
                                 '{"error" : {"code" : 42, "message": "foo"}}');
          }), false);
        }

        makeNormal199Error() {
          httpMock.register(expectAsync((http.BaseRequest request, string) {
            return stringResponse(199, {}, '');
          }), false);
        }

        makeInvalidContentTypeError() {
          httpMock.register(expectAsync((http.BaseRequest request, string) {
            var responseHeaders = { 'content-type' : 'image/png'};
            return stringResponse(200, responseHeaders, '');
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

        test('normal-invalid-content-type', () {
          makeInvalidContentTypeError();
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
      });


      // Tests for path/query parameters

      test('request-parameters-query', () {
        var queryParams = {
            'a' : ['a1', 'a2'],
            's' : ['s1']
        };
        httpMock.register(expectAsync((http.BaseRequest request, json) {
          expect(request.method, equals('GET'));
          expect('${request.url}',
                 equals('http://example.com/base/abc?a=a1&a=a2&s=s1&alt=json'));
          return stringResponse(200, responseHeaders, '');
        }), true);
        requester.request('abc', 'GET', queryParams: queryParams)
            .then(expectAsync((response) {
          expect(response, isNull);
        }));
      });

      test('request-parameters-path', () {
        httpMock.register(expectAsync((http.BaseRequest request, json) {
          expect(request.method, equals('GET'));
          expect('${request.url}', equals(
              'http://example.com/base/s/foo/a1/a2/bar/s1/e?alt=json'));
          return stringResponse(200, responseHeaders, '');
        }), true);
        requester.request('s/foo/a1/a2/bar/s1/e', 'GET')
            .then(expectAsync((response) {
          expect(response, isNull);
        }));
      });
    });
  });
}
""";
}
