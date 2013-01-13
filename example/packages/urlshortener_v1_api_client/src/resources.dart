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
   *
   * [optParams] - Additional query parameters
   */
  Future<Url> get(String shortUrl, {String projection, Map optParams}) {
    var completer = new Completer();
    var url = "url";
    var urlParams = new Map();
    var queryParams = new Map();

    var paramErrors = new StringBuffer();
    if (!["ANALYTICS_CLICKS", "ANALYTICS_TOP_STRINGS", "FULL"].contains(projection)) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("Allowed values for projection: ANALYTICS_CLICKS, ANALYTICS_TOP_STRINGS, FULL");
    }
    if (projection != null) queryParams["projection"] = projection;
    if (shortUrl == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("shortUrl is required");
    }
    if (shortUrl != null) queryParams["shortUrl"] = shortUrl;
    if (optParams != null) {
      optParams.forEach((key, value) {
        if (value != null && queryParams[key] == null) {
          queryParams[key] = value;
        }
      });
    }

    if (!paramErrors.isEmpty) {
      completer.completeException(new ArgumentError(paramErrors.toString()));
      return completer.future;
    }

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
   *
   * [optParams] - Additional query parameters
   */
  Future<Url> insert(Url request, {Map optParams}) {
    var completer = new Completer();
    var url = "url";
    var urlParams = new Map();
    var queryParams = new Map();

    var paramErrors = new StringBuffer();
    if (optParams != null) {
      optParams.forEach((key, value) {
        if (value != null && queryParams[key] == null) {
          queryParams[key] = value;
        }
      });
    }

    if (!paramErrors.isEmpty) {
      completer.completeException(new ArgumentError(paramErrors.toString()));
      return completer.future;
    }

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
   *
   * [optParams] - Additional query parameters
   */
  Future<UrlHistory> list({String projection, String start_token, Map optParams}) {
    var completer = new Completer();
    var url = "url/history";
    var urlParams = new Map();
    var queryParams = new Map();

    var paramErrors = new StringBuffer();
    if (!["ANALYTICS_CLICKS", "FULL"].contains(projection)) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("Allowed values for projection: ANALYTICS_CLICKS, FULL");
    }
    if (projection != null) queryParams["projection"] = projection;
    if (start_token != null) queryParams["start-token"] = start_token;
    if (optParams != null) {
      optParams.forEach((key, value) {
        if (value != null && queryParams[key] == null) {
          queryParams[key] = value;
        }
      });
    }

    if (!paramErrors.isEmpty) {
      completer.completeException(new ArgumentError(paramErrors.toString()));
      return completer.future;
    }

    var response;
    response = _client._request(url, "GET", urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(new UrlHistory.fromJson(data)));
    return completer.future;
  }
}

