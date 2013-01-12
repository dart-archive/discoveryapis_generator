part of drive;

/** Client to access the drive v2 API */
/** The API to interact with Drive. */
class Drive extends Client {

  AboutResource _about;
  AboutResource get about => _about;
  AppsResource _apps;
  AppsResource get apps => _apps;
  ChangesResource _changes;
  ChangesResource get changes => _changes;
  ChildrenResource _children;
  ChildrenResource get children => _children;
  CommentsResource _comments;
  CommentsResource get comments => _comments;
  FilesResource _files;
  FilesResource get files => _files;
  ParentsResource _parents;
  ParentsResource get parents => _parents;
  PermissionsResource _permissions;
  PermissionsResource get permissions => _permissions;
  RepliesResource _replies;
  RepliesResource get replies => _replies;
  RevisionsResource _revisions;
  RevisionsResource get revisions => _revisions;

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

  Drive([OAuth2 auth]) : super(auth) {
    _baseUrl = "https://www.googleapis.com:443/drive/v2/";
    _rootUrl = "https://www.googleapis.com:443/";
    _about = new AboutResource._internal(this);
    _apps = new AppsResource._internal(this);
    _changes = new ChangesResource._internal(this);
    _children = new ChildrenResource._internal(this);
    _comments = new CommentsResource._internal(this);
    _files = new FilesResource._internal(this);
    _parents = new ParentsResource._internal(this);
    _permissions = new PermissionsResource._internal(this);
    _replies = new RepliesResource._internal(this);
    _revisions = new RevisionsResource._internal(this);
  }
}
