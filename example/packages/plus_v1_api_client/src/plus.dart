part of plus_v1_api_client;

/** Client to access the plus v1 API */
/** The Google+ API enables developers to build on top of the Google+ platform. */
class Plus extends Client {

  ActivitiesResource _activities;
  ActivitiesResource get activities => _activities;
  CommentsResource _comments;
  CommentsResource get comments => _comments;
  PeopleResource _people;
  PeopleResource get people => _people;

  /** OAuth Scope2: Know who you are on Google */
  static const String PLUS_ME_SCOPE = "https://www.googleapis.com/auth/plus.me";

  /**
   * Data format for the response.
   * Added as queryParameter for each request.
   */
  String get alt => _params["alt"];
  set alt(String value) => _params["alt"] = value;

  /**
   * Selector specifying which fields to include in a partial response.
   * Added as queryParameter for each request.
   */
  String get fields => _params["fields"];
  set fields(String value) => _params["fields"] = value;

  /**
   * API key. Your API key identifies your project and provides you with API access, quota, and reports. Required unless you provide an OAuth 2.0 token.
   * Added as queryParameter for each request.
   */
  String get key => _params["key"];
  set key(String value) => _params["key"] = value;

  /**
   * OAuth 2.0 token for the current user.
   * Added as queryParameter for each request.
   */
  String get oauth_token => _params["oauth_token"];
  set oauth_token(String value) => _params["oauth_token"] = value;

  /**
   * Returns response with indentations and line breaks.
   * Added as queryParameter for each request.
   */
  bool get prettyPrint => _params["prettyPrint"];
  set prettyPrint(bool value) => _params["prettyPrint"] = value;

  /**
   * Available to use for quota purposes for server-side applications. Can be any arbitrary string assigned to a user, but should not exceed 40 characters. Overrides userIp if both are provided.
   * Added as queryParameter for each request.
   */
  String get quotaUser => _params["quotaUser"];
  set quotaUser(String value) => _params["quotaUser"] = value;

  /**
   * IP address of the site where the request originates. Use this if you want to enforce per-user limits.
   * Added as queryParameter for each request.
   */
  String get userIp => _params["userIp"];
  set userIp(String value) => _params["userIp"] = value;

  Plus([OAuth2 auth]) : super(auth) {
    _basePath = "/plus/v1/";
    _rootUrl = "https://www.googleapis.com:443/";
    _activities = new ActivitiesResource._internal(this);
    _comments = new CommentsResource._internal(this);
    _people = new PeopleResource._internal(this);
  }
}
