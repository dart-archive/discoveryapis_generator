part of urlshortener;

/**
 * Base class for all API clients, offering generic methods for HTTP Requests to the API
 */
abstract class Client {
  OAuth2 _auth;
  String _baseUrl;
  String _rootUrl;
  bool makeAuthRequests;
  Map _params;

  static const _boundary = "-------314159265358979323846";
  static const _delimiter = "\r\n--$_boundary\r\n";
  static const _closeDelim = "\r\n--$_boundary--";

  Client([OAuth2 this._auth]) {
    _params = new Map();
    makeAuthRequests = false;
  }

  /**
   * Send a HTTPRequest using [method] (usually GET or POST) to [requestUrl] using the specified [urlParams] and [queryParams]. Optionally include a [body] in the request.
   */
  Future _request(String requestUrl, String method, {String body, String contentType:"application/json", Map urlParams, Map queryParams}) {
    var request = new HttpRequest();
    var completer = new Completer();

    if (urlParams == null) urlParams = {};
    if (queryParams == null) queryParams = {};

    _params.forEach((key, param) {
      if (param != null) {
        queryParams[key] = param;
      }
    });

    var path;
    if (requestUrl.substring(0,1) == "/") {
      path ="$_rootUrl${requestUrl.substring(1)}";
    } else {
      path = "$_baseUrl$requestUrl";
    }
    final url = new UrlPattern(path).generate(urlParams, queryParams);

    request.on.loadEnd.add((Event e) {
      if (request.status == 200) {
        var data = JSON.parse(request.responseText);
        completer.complete(data);
      } else {
        var error = "";
        if (request.status == 0) {
          error = "Unknown Error, most likely related to same-origin-policies.";
        } else {
          if (request.responseText != null) {
            var errorJson;
            try {
              errorJson = JSON.parse(request.responseText); 
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
        }
        completer.completeException(new APIRequestException(error));
      }
    });

    request.open(method, url);
    request.setRequestHeader("Content-Type", contentType);
    if (makeAuthRequests && _auth != null) {
      _auth.authenticate(request).then((request) => request.send(body));
    } else {
      request.send(body);
    }

    return completer.future;
  }

  /**
   * Join [content] (encoded as Base64-String) with specified [contentType] and additional request [body] into one multipart-body and send a HTTPRequest with [method] (usually POST) to [requestUrl]
   */
  Future _upload(String requestUrl, String method, String body, String content, String contentType, {Map urlParams, Map queryParams}) {
    var multiPartBody = new StringBuffer();
    if (contentType == null || contentType.isEmpty) {
      contentType = "application/octet-stream";
    }
    multiPartBody
    ..add(_delimiter)
    ..add("Content-Type: application/json\r\n\r\n")
    ..add(body)
    ..add(_delimiter)
    ..add("Content-Type: ")
    ..add(contentType)
    ..add("\r\n")
    ..add("Content-Transfer-Encoding: base64\r\n")
    ..add("\r\n")
    ..add(contentType)
    ..add(_closeDelim);

    return _request(requestUrl, method, body: multiPartBody.toString(), contentType: "multipart/mixed; boundary=\"$_boundary\"", urlParams: urlParams, queryParams: queryParams);
  }
}

/// Base-class for all API Resources
abstract class Resource {
  /// The [Client] to be used for all requests
  Client _client;

  /// Create a new Resource, using the specified [Client] for requests
  Resource(Client this._client);
}

/// Exception thrown when the HTTP Request to the API failed
class APIRequestException implements Exception {
  final String msg;
  const APIRequestException([this.msg]);
  String toString() => (msg == null) ? "APIRequestException" : "APIRequestException: $msg";
}

