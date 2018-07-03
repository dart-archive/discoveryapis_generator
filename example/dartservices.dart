// This is a generated file (see the discoveryapis_generator project).

// ignore_for_file: unnecessary_cast

library discoveryapis_generator.dartservices.v1;

import 'dart:async';
import 'dart:convert' as convert;

import 'package:_discoveryapis_commons/_discoveryapis_commons.dart' as commons;
import 'package:http/http.dart' as http;

export 'package:_discoveryapis_commons/_discoveryapis_commons.dart'
    show ApiRequestError, DetailedApiRequestError;

const String USER_AGENT = 'dart-api-client dartservices/v1';

class DartservicesApi {
  final commons.ApiRequester _requester;

  DartservicesApi(http.Client client,
      {String rootUrl: "http://localhost/",
      String servicePath: "api/dartservices/v1/"})
      : _requester =
            new commons.ApiRequester(client, rootUrl, servicePath, USER_AGENT);

  /// [request] - The metadata request object.
  ///
  /// Request parameters:
  ///
  /// Completes with a [AnalysisResults].
  ///
  /// Completes with a [commons.ApiRequestError] if the API endpoint returned an
  /// error.
  ///
  /// If the used [http.Client] completes with an error when making a REST call,
  /// this method will complete with the same error.
  Future<AnalysisResults> analyze(SourceRequest request) {
    var _url = null;
    var _queryParams = new Map<String, List<String>>();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;

    if (request != null) {
      _body = convert.json.encode((request).toJson());
    }

    _url = 'analyze';

    var _response = _requester.request(_url, "POST",
        body: _body,
        queryParams: _queryParams,
        uploadOptions: _uploadOptions,
        uploadMedia: _uploadMedia,
        downloadOptions: _downloadOptions);
    return _response.then((data) => new AnalysisResults.fromJson(data));
  }

  /// Request parameters:
  ///
  /// [source] - Query parameter: 'source'.
  ///
  /// Completes with a [AnalysisResults].
  ///
  /// Completes with a [commons.ApiRequestError] if the API endpoint returned an
  /// error.
  ///
  /// If the used [http.Client] completes with an error when making a REST call,
  /// this method will complete with the same error.
  Future<AnalysisResults> analyzeGet({String source}) {
    var _url = null;
    var _queryParams = new Map<String, List<String>>();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;

    if (source != null) {
      _queryParams["source"] = [source];
    }

    _url = 'analyze';

    var _response = _requester.request(_url, "GET",
        body: _body,
        queryParams: _queryParams,
        uploadOptions: _uploadOptions,
        uploadMedia: _uploadMedia,
        downloadOptions: _downloadOptions);
    return _response.then((data) => new AnalysisResults.fromJson(data));
  }

  /// [request] - The metadata request object.
  ///
  /// Request parameters:
  ///
  /// Completes with a [CompileResponse].
  ///
  /// Completes with a [commons.ApiRequestError] if the API endpoint returned an
  /// error.
  ///
  /// If the used [http.Client] completes with an error when making a REST call,
  /// this method will complete with the same error.
  Future<CompileResponse> compile(SourceRequest request) {
    var _url = null;
    var _queryParams = new Map<String, List<String>>();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;

    if (request != null) {
      _body = convert.json.encode((request).toJson());
    }

    _url = 'compile';

    var _response = _requester.request(_url, "POST",
        body: _body,
        queryParams: _queryParams,
        uploadOptions: _uploadOptions,
        uploadMedia: _uploadMedia,
        downloadOptions: _downloadOptions);
    return _response.then((data) => new CompileResponse.fromJson(data));
  }

  /// Request parameters:
  ///
  /// [source] - Query parameter: 'source'.
  ///
  /// Completes with a [CompileResponse].
  ///
  /// Completes with a [commons.ApiRequestError] if the API endpoint returned an
  /// error.
  ///
  /// If the used [http.Client] completes with an error when making a REST call,
  /// this method will complete with the same error.
  Future<CompileResponse> compileGet({String source}) {
    var _url = null;
    var _queryParams = new Map<String, List<String>>();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;

    if (source != null) {
      _queryParams["source"] = [source];
    }

    _url = 'compile';

    var _response = _requester.request(_url, "GET",
        body: _body,
        queryParams: _queryParams,
        uploadOptions: _uploadOptions,
        uploadMedia: _uploadMedia,
        downloadOptions: _downloadOptions);
    return _response.then((data) => new CompileResponse.fromJson(data));
  }

  /// [request] - The metadata request object.
  ///
  /// Request parameters:
  ///
  /// Completes with a [commons.ApiRequestError] if the API endpoint returned an
  /// error.
  ///
  /// If the used [http.Client] completes with an error when making a REST call,
  /// this method will complete with the same error.
  Future complete(SourceRequest request) {
    var _url = null;
    var _queryParams = new Map<String, List<String>>();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;

    if (request != null) {
      _body = convert.json.encode((request).toJson());
    }

    _downloadOptions = null;

    _url = 'complete';

    var _response = _requester.request(_url, "POST",
        body: _body,
        queryParams: _queryParams,
        uploadOptions: _uploadOptions,
        uploadMedia: _uploadMedia,
        downloadOptions: _downloadOptions);
    return _response.then((data) => null);
  }

  /// Request parameters:
  ///
  /// [source] - Query parameter: 'source'.
  ///
  /// [offset] - Query parameter: 'offset'.
  ///
  /// Completes with a [commons.ApiRequestError] if the API endpoint returned an
  /// error.
  ///
  /// If the used [http.Client] completes with an error when making a REST call,
  /// this method will complete with the same error.
  Future completeGet({String source, int offset}) {
    var _url = null;
    var _queryParams = new Map<String, List<String>>();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;

    if (source != null) {
      _queryParams["source"] = [source];
    }
    if (offset != null) {
      _queryParams["offset"] = ["${offset}"];
    }

    _downloadOptions = null;

    _url = 'complete';

    var _response = _requester.request(_url, "GET",
        body: _body,
        queryParams: _queryParams,
        uploadOptions: _uploadOptions,
        uploadMedia: _uploadMedia,
        downloadOptions: _downloadOptions);
    return _response.then((data) => null);
  }

  /// [request] - The metadata request object.
  ///
  /// Request parameters:
  ///
  /// Completes with a [DocumentResponse].
  ///
  /// Completes with a [commons.ApiRequestError] if the API endpoint returned an
  /// error.
  ///
  /// If the used [http.Client] completes with an error when making a REST call,
  /// this method will complete with the same error.
  Future<DocumentResponse> document(SourceRequest request) {
    var _url = null;
    var _queryParams = new Map<String, List<String>>();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;

    if (request != null) {
      _body = convert.json.encode((request).toJson());
    }

    _url = 'document';

    var _response = _requester.request(_url, "POST",
        body: _body,
        queryParams: _queryParams,
        uploadOptions: _uploadOptions,
        uploadMedia: _uploadMedia,
        downloadOptions: _downloadOptions);
    return _response.then((data) => new DocumentResponse.fromJson(data));
  }

  /// Request parameters:
  ///
  /// [source] - Query parameter: 'source'.
  ///
  /// [offset] - Query parameter: 'offset'.
  ///
  /// Completes with a [DocumentResponse].
  ///
  /// Completes with a [commons.ApiRequestError] if the API endpoint returned an
  /// error.
  ///
  /// If the used [http.Client] completes with an error when making a REST call,
  /// this method will complete with the same error.
  Future<DocumentResponse> documentGet({String source, int offset}) {
    var _url = null;
    var _queryParams = new Map<String, List<String>>();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = commons.DownloadOptions.Metadata;
    var _body = null;

    if (source != null) {
      _queryParams["source"] = [source];
    }
    if (offset != null) {
      _queryParams["offset"] = ["${offset}"];
    }

    _url = 'document';

    var _response = _requester.request(_url, "GET",
        body: _body,
        queryParams: _queryParams,
        uploadOptions: _uploadOptions,
        uploadMedia: _uploadMedia,
        downloadOptions: _downloadOptions);
    return _response.then((data) => new DocumentResponse.fromJson(data));
  }
}

class AnalysisIssue {
  int charLength;
  int charStart;
  String kind;
  int line;
  String location;
  String message;

  AnalysisIssue();

  AnalysisIssue.fromJson(Map _json) {
    if (_json.containsKey("charLength")) {
      charLength = _json["charLength"];
    }
    if (_json.containsKey("charStart")) {
      charStart = _json["charStart"];
    }
    if (_json.containsKey("kind")) {
      kind = _json["kind"];
    }
    if (_json.containsKey("line")) {
      line = _json["line"];
    }
    if (_json.containsKey("location")) {
      location = _json["location"];
    }
    if (_json.containsKey("message")) {
      message = _json["message"];
    }
  }

  Map<String, Object> toJson() {
    final Map<String, Object> _json = new Map<String, Object>();
    if (charLength != null) {
      _json["charLength"] = charLength;
    }
    if (charStart != null) {
      _json["charStart"] = charStart;
    }
    if (kind != null) {
      _json["kind"] = kind;
    }
    if (line != null) {
      _json["line"] = line;
    }
    if (location != null) {
      _json["location"] = location;
    }
    if (message != null) {
      _json["message"] = message;
    }
    return _json;
  }
}

class AnalysisResults {
  List<AnalysisIssue> issues;

  AnalysisResults();

  AnalysisResults.fromJson(Map _json) {
    if (_json.containsKey("issues")) {
      issues = (_json["issues"] as List)
          .map<AnalysisIssue>((value) => new AnalysisIssue.fromJson(value))
          .toList();
    }
  }

  Map<String, Object> toJson() {
    final Map<String, Object> _json = new Map<String, Object>();
    if (issues != null) {
      _json["issues"] = issues.map((value) => (value).toJson()).toList();
    }
    return _json;
  }
}

class CompileResponse {
  String result;

  CompileResponse();

  CompileResponse.fromJson(Map _json) {
    if (_json.containsKey("result")) {
      result = _json["result"];
    }
  }

  Map<String, Object> toJson() {
    final Map<String, Object> _json = new Map<String, Object>();
    if (result != null) {
      _json["result"] = result;
    }
    return _json;
  }
}

class DocumentResponse {
  Map<String, String> info;

  DocumentResponse();

  DocumentResponse.fromJson(Map _json) {
    if (_json.containsKey("info")) {
      info = (_json["info"] as Map).cast<String, String>();
    }
  }

  Map<String, Object> toJson() {
    final Map<String, Object> _json = new Map<String, Object>();
    if (info != null) {
      _json["info"] = info;
    }
    return _json;
  }
}

class SourceRequest {
  int offset;
  String source;

  SourceRequest();

  SourceRequest.fromJson(Map _json) {
    if (_json.containsKey("offset")) {
      offset = _json["offset"];
    }
    if (_json.containsKey("source")) {
      source = _json["source"];
    }
  }

  Map<String, Object> toJson() {
    final Map<String, Object> _json = new Map<String, Object>();
    if (offset != null) {
      _json["offset"] = offset;
    }
    if (source != null) {
      _json["source"] = source;
    }
    return _json;
  }
}
