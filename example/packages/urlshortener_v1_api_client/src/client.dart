part of urlshortener_v1_api_client;

/**
 * Base class for all API clients, offering generic methods for HTTP Requests to the API
 */
abstract class Client {
  OAuth2 _auth;
  String _basePath;
  String _rootUrl;
  bool makeAuthRequests;
  Map _params;
  bool _jsClientLoaded = false;

  static const _boundary = "-------314159265358979323846";
  static const _delimiter = "\r\n--$_boundary\r\n";
  static const _closeDelim = "\r\n--$_boundary--";

  Client([OAuth2 this._auth]) {
    _params = new Map();
    makeAuthRequests = false;
  }

  /**
   * Loads the JS Client Library to make CORS-Requests
   */
  Future<bool> _loadJsClient() {
    var completer = new Completer();
    
    if (_jsClientLoaded) {
      completer.complete(true);
      return completer.future;
    }
    
    js.scoped((){
      js.context.handleClientLoad =  new js.Callback.once(() {
        _jsClientLoaded = true;
        completer.complete(true);
      });
    });
    
    ScriptElement script = new ScriptElement();
    script.src = "http://apis.google.com/js/client.js?onload=handleClientLoad";
    script.type = "text/javascript";
    document.body.children.add(script);
    
    return completer.future;
  }
  
  /**
   * Makes a request via the JS Client Library to circumvent CORS-problems
   */
  Future _makeJsClientRequest(String requestUrl, String method, {String body, String contentType, Map queryParams}) {
    var completer = new Completer();
    var requestData = new Map();
    requestData["path"] = requestUrl;
    requestData["method"] = method;
    requestData["headers"] = new Map();
    
    if (queryParams != null) {
      requestData["params"] = queryParams;
    }
    
    if (body != null) {
      requestData["body"] = body;
      requestData["headers"]["Content-Type"] = contentType;
    }
    if (makeAuthRequests && _auth != null && _auth.token != null) {
      requestData["headers"]["Authorization"] = "${_auth.token.type} ${_auth.token.data}";
    }
    
    js.scoped(() {
      var request = js.context.gapi.client.request(js.map(requestData));
      var callback = new js.Callback.once((jsonResp, rawResp) {
        if (jsonResp is bool && jsonResp == false) {
          var raw = JSON.parse(rawResp);
          if (raw["gapiRequest"]["data"]["status"] >= 400) {
            completer.completeException(new APIRequestException("JS Client - ${raw["gapiRequest"]["data"]["status"]} ${raw["gapiRequest"]["data"]["statusText"]} - ${raw["gapiRequest"]["data"]["body"]}"));
          } else {
            completer.complete({});              
          }
        } else {
          completer.complete(js.context.JSON.stringify(jsonResp));
        }
      });
      request.execute(callback);
    });
    
    return completer.future;
  }

  /**
   * Sends a HTTPRequest using [method] (usually GET or POST) to [requestUrl] using the specified [urlParams] and [queryParams]. Optionally include a [body] in the request.
   */
  Future _request(String requestUrl, String method, {String body, String contentType:"application/json", Map urlParams, Map queryParams}) {
    var request = new HttpRequest();
    var completer = new Completer();

    if (urlParams == null) urlParams = {};
    if (queryParams == null) queryParams = {};

    _params.forEach((key, param) {
      if (param != null && queryParams[key] == null) {
        queryParams[key] = param;
      }
    });

    var path;
    if (requestUrl.substring(0,1) == "/") {
      path ="$_rootUrl${requestUrl.substring(1)}";
    } else {
      path ="$_rootUrl${_basePath.substring(1)}$requestUrl";
    }
    var url = new UrlPattern(path).generate(urlParams, queryParams);

    request.on.loadEnd.add((Event e) {
      if (request.status == 200) {
        var data = JSON.parse(request.responseText);
        completer.complete(data);
      } else {
        if (request.status == 0) {
          _loadJsClient().then((v) {
            if (requestUrl.substring(0,1) == "/") {
              path = requestUrl;
            } else {
              path ="$_basePath$requestUrl";
            }
            url = new UrlPattern(path).generate(urlParams, {});
            _makeJsClientRequest(url, method, body: body, contentType: contentType, queryParams: queryParams)
              ..handleException((e) {
                completer.completeException(e);
                return true;
              })
              ..then((response) {
                var data = JSON.parse(response);
                completer.complete(data);
              });
          });
        } else {
          var error = "";
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
          completer.completeException(new APIRequestException(error));
        }
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
   * Joins [content] (encoded as Base64-String) with specified [contentType] and additional request [body] into one multipart-body and send a HTTPRequest with [method] (usually POST) to [requestUrl]
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
    ..add(content)
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

