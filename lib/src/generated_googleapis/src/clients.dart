// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library discoveryapis_commons.clients;

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

import 'requests.dart' as client_requests;

const CONTENT_TYPE_JSON_UTF8 = 'application/json; charset=utf-8';

/// Base class for all API clients, offering generic methods for
/// HTTP Requests to the API
class ApiRequester {
  final http.Client _httpClient;
  final String _rootUrl;
  final String _basePath;
  final String _userAgent;

  ApiRequester(
      this._httpClient, this._rootUrl, this._basePath, this._userAgent) {
    assert(_rootUrl.endsWith('/'));
  }

  /// Sends a HTTPRequest using [method] (usually GET or POST) to [requestUrl]
  /// using the specified [urlParams] and [queryParams]. Optionally include a
  /// [body] and/or [uploadMedia] in the request.
  ///
  /// If [uploadMedia] was specified [downloadOptions] must be
  /// [DownloadOptions.Metadata] or `null`.
  ///
  /// If [downloadOptions] is [DownloadOptions.Metadata] the result will be
  /// decoded as JSON.
  ///
  /// If [downloadOptions] is `null` the result will be a Future completing with
  /// `null`.
  ///
  /// Otherwise the result will be downloaded as a [client_requests.Media]
  Future request(String requestUrl, String method,
      {String body,
      Map queryParams,
      client_requests.Media uploadMedia,
      client_requests.UploadOptions uploadOptions,
      client_requests.DownloadOptions downloadOptions =
          client_requests.DownloadOptions.Metadata}) {
    if (uploadMedia != null &&
        downloadOptions != client_requests.DownloadOptions.Metadata) {
      throw ArgumentError('When uploading a [Media] you cannot download a '
          '[Media] at the same time!');
    }
    client_requests.ByteRange downloadRange;
    if (downloadOptions is client_requests.PartialDownloadOptions &&
        !downloadOptions.isFullDownload) {
      downloadRange = downloadOptions.range;
    }
    queryParams = queryParams?.cast<String, List<String>>();

    return _request(requestUrl, method, body, queryParams, uploadMedia,
            uploadOptions, downloadOptions, downloadRange)
        .then(_validateResponse)
        .then((http.StreamedResponse response) {
      if (downloadOptions == null) {
        // If no download options are given, the response is of no interest
        // and we will drain the stream.
        return response.stream.drain();
      } else if (downloadOptions == client_requests.DownloadOptions.Metadata) {
        // Downloading JSON Metadata
        var stringStream = _decodeStreamAsText(response);
        if (stringStream != null) {
          return stringStream.join('').then((String bodyString) {
            if (bodyString == '') return null;
            return json.decode(bodyString);
          });
        } else {
          throw client_requests.ApiRequestError(
              'Unable to read response with content-type '
              "${response.headers['content-type']}.");
        }
      } else {
        // Downloading Media.
        var contentType = response.headers['content-type'];
        if (contentType == null) {
          throw client_requests.ApiRequestError(
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
            throw client_requests.ApiRequestError(
                'Content length of response does not match requested range '
                'length.');
          }
          var contentRange = response.headers['content-range'];
          var expected = 'bytes ${downloadRange.start}-${downloadRange.end}/';
          if (contentRange == null || !contentRange.startsWith(expected)) {
            throw client_requests.ApiRequestError('Attempting partial '
                "download but got invalid 'Content-Range' header "
                '(was: $contentRange, expected: $expected).');
          }
        }

        return client_requests.Media(response.stream, contentLength,
            contentType: contentType);
      }
    });
  }

  Future<http.StreamedResponse> _request(
      String requestUrl,
      String method,
      String body,
      Map<String, List<String>> queryParams,
      client_requests.Media uploadMedia,
      client_requests.UploadOptions uploadOptions,
      client_requests.DownloadOptions downloadOptions,
      client_requests.ByteRange downloadRange) {
    var downloadAsMedia = downloadOptions != null &&
        downloadOptions != client_requests.DownloadOptions.Metadata;

    queryParams ??= {};

    if (uploadMedia != null) {
      if (uploadOptions is client_requests.ResumableUploadOptions) {
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
      path = '$_rootUrl${requestUrl.substring(1)}';
    } else {
      path = '$_rootUrl${_basePath}$requestUrl';
    }

    bool containsQueryParameter = path.contains('?');
    void addQueryParameter(String name, String value) {
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
      var request = _RequestImpl(method, uri, bodyStream);
      request.headers.addAll({
        'user-agent': _userAgent,
        'content-type': uploadMedia.contentType,
        'content-length': '${uploadMedia.length}'
      });
      return _httpClient.send(request);
    }

    Future simpleRequest() {
      var length = 0;
      var bodyController = StreamController<List<int>>();
      if (body != null) {
        var bytes = utf8.encode(body);
        bodyController.add(bytes);
        length = bytes.length;
      }
      bodyController.close();

      var headers;
      if (downloadRange != null) {
        headers = {
          'user-agent': _userAgent,
          'content-type': CONTENT_TYPE_JSON_UTF8,
          'content-length': '$length',
          'range': 'bytes=${downloadRange.start}-${downloadRange.end}',
        };
      } else {
        headers = {
          'user-agent': _userAgent,
          'content-type': CONTENT_TYPE_JSON_UTF8,
          'content-length': '$length',
        };
      }

      var request = _RequestImpl(method, uri, bodyController.stream);
      request.headers.addAll(headers);
      return _httpClient.send(request);
    }

    if (uploadMedia != null) {
      // Three upload types:
      // 1. Resumable: Upload of data + metdata with multiple requests.
      // 2. Simple: Upload of media.
      // 3. Multipart: Upload of data + metadata.

      if (uploadOptions is client_requests.ResumableUploadOptions) {
        throw UnimplementedError();
      }

      if (uploadMedia.length == null) {
        throw ArgumentError(
            'For non-resumable uploads you need to specify the length of the '
            'media to upload.');
      }

      if (body == null) {
        return simpleUpload();
      } else {
        var uploader = MultipartMediaUploader(
            _httpClient, uploadMedia, body, uri, method, _userAgent);
        return uploader.upload();
      }
    }
    return simpleRequest();
  }
}

/// Does media uploads using the multipart upload protocol.
class MultipartMediaUploader {
  static final _boundary = '314159265358979323846';
  static final _base64Encoder = Base64Encoder();

  final http.Client _httpClient;
  final client_requests.Media _uploadMedia;
  final Uri _uri;
  final String _body;
  final String _method;
  final String _userAgent;

  MultipartMediaUploader(this._httpClient, this._uploadMedia, this._body,
      this._uri, this._method, this._userAgent);

  Future<http.StreamedResponse> upload() {
    var base64MediaStream =
        _uploadMedia.stream.transform(_base64Encoder).transform(ascii.encoder);
    var base64MediaStreamLength =
        Base64Encoder.lengthOfBase64Stream(_uploadMedia.length);

    // NOTE: We assume that [_body] is encoded JSON without any \r or \n in it.
    // This guarantees us that [_body] cannot contain a valid multipart
    // boundary.
    var bodyHead = '--$_boundary\r\n'
            'Content-Type: $CONTENT_TYPE_JSON_UTF8\r\n\r\n' +
        _body +
        '\r\n--$_boundary\r\n'
            'Content-Type: ${_uploadMedia.contentType}\r\n'
            'Content-Transfer-Encoding: base64\r\n\r\n';
    var bodyTail = '\r\n--$_boundary--';

    var totalLength =
        bodyHead.length + base64MediaStreamLength + bodyTail.length;

    var bodyController = StreamController<List<int>>();
    bodyController.add(utf8.encode(bodyHead));
    bodyController.addStream(base64MediaStream).then((_) {
      bodyController.add(utf8.encode(bodyTail));
    }).catchError((error, stack) {
      bodyController.addError(error, stack);
    }).then((_) {
      bodyController.close();
    });

    var headers = {
      'user-agent': _userAgent,
      'content-type': 'multipart/related; boundary=\"$_boundary\"',
      'content-length': '$totalLength'
    };
    var bodyStream = bodyController.stream;
    var request = _RequestImpl(_method, _uri, bodyStream);
    request.headers.addAll(headers);
    return _httpClient.send(request);
  }
}

/// Base64 encodes a stream of bytes.
class Base64Encoder extends StreamTransformerBase<List<int>, String> {
  static int lengthOfBase64Stream(int lengthOfByteStream) {
    return ((lengthOfByteStream + 2) ~/ 3) * 4;
  }

  @override
  Stream<String> bind(Stream<List<int>> stream) {
    StreamController<String> controller;

    // Holds between 0 and 3 bytes and is used as a buffer.
    var remainingBytes = <int>[];

    void onData(List<int> bytes) {
      if ((remainingBytes.length + bytes.length) < 3) {
        remainingBytes.addAll(bytes);
        return;
      }
      int start;
      if (remainingBytes.isEmpty) {
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
      if (remainingBytes.isNotEmpty) {
        controller.add(base64.encode(remainingBytes));
        remainingBytes.clear();
      }

      var chunksOf3 = (bytes.length - start) ~/ 3;
      var end = start + 3 * chunksOf3;

      // Convert & Send main bytes.
      if (start == 0 && end == bytes.length) {
        // Fast path if [bytes] are devisible by 3.
        controller.add(base64.encode(bytes));
      } else {
        controller.add(base64.encode(bytes.sublist(start, end)));

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
      if (remainingBytes.isNotEmpty) {
        controller.add(base64.encode(remainingBytes));
        remainingBytes.clear();
      }
      controller.close();
    }

    var subscription;
    controller = StreamController<String>(onListen: () {
      subscription = stream.listen(onData, onError: onError, onDone: onDone);
    }, onPause: () {
      subscription.pause();
    }, onResume: () {
      subscription.resume();
    }, onCancel: () {
      subscription.cancel();
    });
    return controller.stream;
  }
}

/// Represents a stack of [ResumableChunk]s.
class ChunkStack {
  final int _chunkSize;
  final List<ResumableChunk> _chunkStack = [];

  // Currently accumulated data.
  List<List<int>> _byteArrays = [];
  int _length = 0;
  int _offset = 0;

  bool _finalized = false;

  ChunkStack(this._chunkSize);

  /// Whether data for a not-yet-finished [ResumableChunk] is present. A call to
  /// `finalize` will create a [ResumableChunk] of this data.
  bool get hasPartialChunk => _length > 0;

  /// The number of chunks in this [ChunkStack].
  int get length => _chunkStack.length;

  /// The total number of bytes which have been converted to [ResumableChunk]s.
  /// Can only be called once this [ChunkStack] has been finalized.
  int get totalByteLength {
    if (!_finalized) {
      throw StateError('ChunkStack has not been finalized yet.');
    }

    return _offset;
  }

  /// Returns the chunks [from] ... [to] and deletes it from the stack.
  List<ResumableChunk> removeSublist(int from, int to) {
    var sublist = _chunkStack.sublist(from, to);
    _chunkStack.removeRange(from, to);
    return sublist;
  }

  /// Adds [bytes] to the buffer. If the buffer is larger than the given chunk
  /// size a new [ResumableChunk] will be created.
  void addBytes(List<int> bytes) {
    if (_finalized) {
      throw StateError('ChunkStack has already been finalized.');
    }

    var remaining = _chunkSize - _length;

    if (bytes.length >= remaining) {
      var left = bytes.sublist(0, remaining);
      var right = bytes.sublist(remaining);

      _byteArrays.add(left);
      _length += left.length;

      _chunkStack.add(ResumableChunk(_byteArrays, _offset, _length));

      _byteArrays = [];
      _offset += _length;
      _length = 0;

      addBytes(right);
    } else if (bytes.isNotEmpty) {
      _byteArrays.add(bytes);
      _length += bytes.length;
    }
  }

  /// Finalizes this [ChunkStack] and creates the last chunk (may have less bytes
  /// than the chunk size, but not zero).
  void finalize() {
    if (_finalized) {
      throw StateError('ChunkStack has already been finalized.');
    }
    _finalized = true;

    if (_length > 0) {
      _chunkStack.add(ResumableChunk(_byteArrays, _offset, _length));
      _offset += _length;
    }
  }
}

/// Represents a chunk of data that will be transferred in one http request.
class ResumableChunk {
  final List<List<int>> byteArrays;
  final int offset;
  final int length;

  /// Index of the next byte after this chunk.
  int get endOfChunk => offset + length;

  ResumableChunk(this.byteArrays, this.offset, this.length);
}

class _RequestImpl extends http.BaseRequest {
  final Stream<List<int>> _stream;

  _RequestImpl(String method, Uri url, [Stream<List<int>> stream])
      : _stream = stream ?? Stream.fromIterable([]),
        super(method, url);

  @override
  http.ByteStream finalize() {
    super.finalize();
    return http.ByteStream(_stream);
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
    http.StreamedResponse response) async {
  var statusCode = response.statusCode;

  // TODO: We assume that status codes between [200..400[ are OK.
  // Can we assume this?
  if (statusCode < 200 || statusCode >= 400) {
    @alwaysThrows
    void throwGeneralError() {
      throw client_requests.DetailedApiRequestError(
          statusCode, 'No error details. HTTP status was: ${statusCode}.');
    }

    // Some error happened, try to decode the response and fetch the error.
    var stringStream = _decodeStreamAsText(response);
    if (stringStream != null) {
      final jsonResponse = await stringStream.transform(json.decoder).first;
      if (jsonResponse is Map && jsonResponse['error'] is Map) {
        final Map error = jsonResponse['error'];
        final code = error['code'];
        final message = error['message'];
        var errors = <client_requests.ApiRequestErrorDetail>[];
        if (error.containsKey('errors') && error['errors'] is List) {
          errors = error['errors']
              .map<client_requests.ApiRequestErrorDetail>(
                  (e) => client_requests.ApiRequestErrorDetail.fromJson(e))
              .toList();
        }
        throw client_requests.DetailedApiRequestError(code, message,
            errors: errors);
      } else {
        throwGeneralError();
      }
    } else {
      throwGeneralError();
    }
  }

  return response;
}

Stream<String> _decodeStreamAsText(http.StreamedResponse response) {
  // TODO: Correctly handle the response content-types, using correct
  // decoder.
  // Currently we assume that the api endpoint is responding with json
  // encoded in UTF8.
  var contentType = response.headers['content-type'];
  if (contentType != null &&
      contentType.toLowerCase().startsWith('application/json')) {
    return response.stream.transform(Utf8Decoder(allowMalformed: true));
  } else {
    return null;
  }
}

/// Creates a new [Map] and inserts all entries of [source] into it,
/// optionally calling [convert] on the values.
Map<String, T> mapMap<F, T>(
    Map<String, F> source, T Function(F source) convert) {
  assert(source != null);
  assert(convert != null);
  final result = <String, T>{};
  source.forEach((String key, F value) {
    result[key] = convert(value);
  });
  return result;
}
