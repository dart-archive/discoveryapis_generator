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

  Drive([String apiKey, OAuth2 auth]) : super(apiKey, auth) {
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
