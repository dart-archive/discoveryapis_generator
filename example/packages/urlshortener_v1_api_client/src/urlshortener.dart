part of urlshortener;

/** Client to access the urlshortener v1 API */
/** Lets you create, inspect, and manage goo.gl short URLs */
class Urlshortener extends Client {


  UrlResource _url;
  UrlResource get url => _url;

  Urlshortener([String apiKey, OAuth2 auth]) : super(apiKey, auth) {
    _baseUrl = "https://www.googleapis.com:443/urlshortener/v1/";
    _rootUrl = "https://www.googleapis.com:443/";
    _url = new UrlResource._internal(this);
  }
}
