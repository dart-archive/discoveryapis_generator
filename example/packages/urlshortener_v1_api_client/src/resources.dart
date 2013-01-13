part of urlshortener_v1_api_client;

class UrlResource extends Resource {

  UrlResource._internal(Client client) : super(client) {
  }

  /** Expands a short URL or gets creation time and analytics. */
  Future<Url> get(String shortUrl, {String projection}) {
    var completer = new Completer();
    var url = "url";
    var urlParams = new Map();
    var queryParams = new Map();

    if (?projection && projection != null) queryParams["projection"] = projection;
    if (?shortUrl && shortUrl != null) queryParams["shortUrl"] = shortUrl;
    var response;
    response = _client._request(url, "GET", urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(new Url.fromJson(data)));
    return completer.future;
  }

  /** Creates a new short URL. */
  Future<Url> insert(Url request) {
    var completer = new Completer();
    var url = "url";
    var urlParams = new Map();
    var queryParams = new Map();

    var response;
    response = _client._request(url, "POST", body: request.toString(), urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(new Url.fromJson(data)));
    return completer.future;
  }

  /** Retrieves a list of URLs shortened by a user. */
  Future<UrlHistory> list({String projection, String start_token}) {
    var completer = new Completer();
    var url = "url/history";
    var urlParams = new Map();
    var queryParams = new Map();

    if (?projection && projection != null) queryParams["projection"] = projection;
    if (?start_token && start_token != null) queryParams["start-token"] = start_token;
    var response;
    response = _client._request(url, "GET", urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(new UrlHistory.fromJson(data)));
    return completer.future;
  }
}

