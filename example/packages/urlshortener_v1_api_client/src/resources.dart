part of urlshortener_v1_api_client;

class UrlResource extends Resource {

  UrlResource._internal(Client client) : super(client) {
  }

  /**
   * Expands a short URL or gets creation time and analytics.
   *
   * [shortUrl] - The short URL, including the protocol.
   *
   * [projection] - Additional information to return.
   *   Allowed values:
   *     ANALYTICS_CLICKS - Returns only click counts.
   *     ANALYTICS_TOP_STRINGS - Returns only top string counts.
   *     FULL - Returns the creation timestamp and all available analytics.
   */
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

  /**
   * Creates a new short URL.
   *
   * [request] - Url to send in this request
   */
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

  /**
   * Retrieves a list of URLs shortened by a user.
   *
   * [projection] - Additional information to return.
   *   Allowed values:
   *     ANALYTICS_CLICKS - Returns short URL click counts.
   *     FULL - Returns short URL click counts.
   *
   * [start_token] - Token for requesting successive pages of results.
   */
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

