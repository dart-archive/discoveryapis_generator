part of urlshortener;

class UrlResource extends Resource {

  UrlResource._internal(Client client) : super(client) {
  }

  /** Expands a short URL or gets creation time and analytics. */
  Future<Url> get(String shortUrl, {Map optParams}) {
    var completer = new Completer();
    var url = "url";
    var urlParams = new Map();
    if (optParams == null) optParams = new Map();

    optParams["shortUrl"] = shortUrl;

    var response;
    response = _client._request(url, "GET", urlParams: urlParams, queryParams: optParams);
    response.then((data) {
      completer.complete(new Url.fromJson(data));
    });

    return completer.future;
  }

  /** Creates a new short URL. */
  Future<Url> insert(Url request, {Map optParams}) {
    var completer = new Completer();
    var url = "url";
    var urlParams = new Map();
    if (optParams == null) optParams = new Map();

    var response;
    response = _client._request(url, "POST", body: request.toString(), urlParams: urlParams, queryParams: optParams);
    response.then((data) {
      completer.complete(new Url.fromJson(data));
    });

    return completer.future;
  }

  /** Retrieves a list of URLs shortened by a user. */
  Future<UrlHistory> list({Map optParams}) {
    var completer = new Completer();
    var url = "url/history";
    var urlParams = new Map();
    if (optParams == null) optParams = new Map();

    var response;
    response = _client._request(url, "GET", urlParams: urlParams, queryParams: optParams);
    response.then((data) {
      completer.complete(new UrlHistory.fromJson(data));
    });

    return completer.future;
  }
}

