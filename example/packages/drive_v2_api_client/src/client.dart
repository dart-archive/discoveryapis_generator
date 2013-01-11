part of drive;

abstract class Client {
  String _apiKey;
  OAuth2 _auth;
  String _baseUrl;
  String _rootUrl;
  bool makeAuthRequests = false;

  static const _boundary = "-------314159265358979323846";
  static const _delimiter = "\r\n--$_boundary\r\n";
  static const _closeDelim = "\r\n--$_boundary--";

  Client([String this._apiKey, OAuth2 this._auth]);

  Future _request(String requestUrl, String method, {String body, String contentType:"application/json", Map urlParams, Map queryParams}) {
    var request = new HttpRequest();
    var completer = new Completer();

    if (urlParams == null) urlParams = {};
    if (queryParams == null) queryParams = {};

    if (_apiKey != null) {
      queryParams["key"] = _apiKey;
    }

    final url = new UrlPattern("${(requestUrl.substring(0,1) == "/") ? _rootUrl :_baseUrl}$requestUrl").generate(urlParams, queryParams);

    request.on.loadEnd.add((Event e) {
      if (request.status == 200) {
        var data = JSON.parse(request.responseText);
        completer.complete(data);
      } else {
        completer.complete({"error": "Error ${request.status}: ${request.statusText}"});
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


abstract class Resource {
  Client _client;

  Resource(Client this._client);
}
