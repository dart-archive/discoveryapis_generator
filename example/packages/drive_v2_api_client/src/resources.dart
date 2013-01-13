part of drive_v2_api_client;

class AboutResource extends Resource {

  AboutResource._internal(Client client) : super(client) {
  }

  /** Gets the information about the current user along with Drive API settings */
  Future<About> get({bool includeSubscribed, String maxChangeIdCount, String startChangeId}) {
    var completer = new Completer();
    var url = "about";
    var urlParams = new Map();
    var queryParams = new Map();

    if (?includeSubscribed && includeSubscribed != null) queryParams["includeSubscribed"] = includeSubscribed;
    if (?maxChangeIdCount && maxChangeIdCount != null) queryParams["maxChangeIdCount"] = maxChangeIdCount;
    if (?startChangeId && startChangeId != null) queryParams["startChangeId"] = startChangeId;
    var response;
    response = _client._request(url, "GET", urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(new About.fromJson(data)));
    return completer.future;
  }
}

class AppsResource extends Resource {

  AppsResource._internal(Client client) : super(client) {
  }

  /** Gets a specific app. */
  Future<App> get(String appId) {
    var completer = new Completer();
    var url = "apps/{appId}";
    var urlParams = new Map();
    var queryParams = new Map();

    if (?appId && appId != null) urlParams["appId"] = appId;
    var response;
    response = _client._request(url, "GET", urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(new App.fromJson(data)));
    return completer.future;
  }

  /** Lists a user's apps. */
  Future<AppList> list() {
    var completer = new Completer();
    var url = "apps";
    var urlParams = new Map();
    var queryParams = new Map();

    var response;
    response = _client._request(url, "GET", urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(new AppList.fromJson(data)));
    return completer.future;
  }
}

class ChangesResource extends Resource {

  ChangesResource._internal(Client client) : super(client) {
  }

  /** Gets a specific change. */
  Future<Change> get(String changeId) {
    var completer = new Completer();
    var url = "changes/{changeId}";
    var urlParams = new Map();
    var queryParams = new Map();

    if (?changeId && changeId != null) urlParams["changeId"] = changeId;
    var response;
    response = _client._request(url, "GET", urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(new Change.fromJson(data)));
    return completer.future;
  }

  /** Lists the changes for a user. */
  Future<ChangeList> list({bool includeDeleted, bool includeSubscribed, int maxResults, String pageToken, String startChangeId}) {
    var completer = new Completer();
    var url = "changes";
    var urlParams = new Map();
    var queryParams = new Map();

    if (?includeDeleted && includeDeleted != null) queryParams["includeDeleted"] = includeDeleted;
    if (?includeSubscribed && includeSubscribed != null) queryParams["includeSubscribed"] = includeSubscribed;
    if (?maxResults && maxResults != null) queryParams["maxResults"] = maxResults;
    if (?pageToken && pageToken != null) queryParams["pageToken"] = pageToken;
    if (?startChangeId && startChangeId != null) queryParams["startChangeId"] = startChangeId;
    var response;
    response = _client._request(url, "GET", urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(new ChangeList.fromJson(data)));
    return completer.future;
  }
}

class ChildrenResource extends Resource {

  ChildrenResource._internal(Client client) : super(client) {
  }

  /** Removes a child from a folder. */
  Future<Map> delete(String folderId, String childId) {
    var completer = new Completer();
    var url = "files/{folderId}/children/{childId}";
    var urlParams = new Map();
    var queryParams = new Map();

    if (?childId && childId != null) urlParams["childId"] = childId;
    if (?folderId && folderId != null) urlParams["folderId"] = folderId;
    var response;
    response = _client._request(url, "DELETE", urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(data));
    return completer.future;
  }

  /** Gets a specific child reference. */
  Future<ChildReference> get(String folderId, String childId) {
    var completer = new Completer();
    var url = "files/{folderId}/children/{childId}";
    var urlParams = new Map();
    var queryParams = new Map();

    if (?childId && childId != null) urlParams["childId"] = childId;
    if (?folderId && folderId != null) urlParams["folderId"] = folderId;
    var response;
    response = _client._request(url, "GET", urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(new ChildReference.fromJson(data)));
    return completer.future;
  }

  /** Inserts a file into a folder. */
  Future<ChildReference> insert(ChildReference request, String folderId) {
    var completer = new Completer();
    var url = "files/{folderId}/children";
    var urlParams = new Map();
    var queryParams = new Map();

    if (?folderId && folderId != null) urlParams["folderId"] = folderId;
    var response;
    response = _client._request(url, "POST", body: request.toString(), urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(new ChildReference.fromJson(data)));
    return completer.future;
  }

  /** Lists a folder's children. */
  Future<ChildList> list(String folderId, {int maxResults, String pageToken, String q}) {
    var completer = new Completer();
    var url = "files/{folderId}/children";
    var urlParams = new Map();
    var queryParams = new Map();

    if (?folderId && folderId != null) urlParams["folderId"] = folderId;
    if (?maxResults && maxResults != null) queryParams["maxResults"] = maxResults;
    if (?pageToken && pageToken != null) queryParams["pageToken"] = pageToken;
    if (?q && q != null) queryParams["q"] = q;
    var response;
    response = _client._request(url, "GET", urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(new ChildList.fromJson(data)));
    return completer.future;
  }
}

class CommentsResource extends Resource {

  CommentsResource._internal(Client client) : super(client) {
  }

  /** Deletes a comment. */
  Future<Map> delete(String fileId, String commentId) {
    var completer = new Completer();
    var url = "files/{fileId}/comments/{commentId}";
    var urlParams = new Map();
    var queryParams = new Map();

    if (?commentId && commentId != null) urlParams["commentId"] = commentId;
    if (?fileId && fileId != null) urlParams["fileId"] = fileId;
    var response;
    response = _client._request(url, "DELETE", urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(data));
    return completer.future;
  }

  /** Gets a comment by ID. */
  Future<Comment> get(String fileId, String commentId, {bool includeDeleted}) {
    var completer = new Completer();
    var url = "files/{fileId}/comments/{commentId}";
    var urlParams = new Map();
    var queryParams = new Map();

    if (?commentId && commentId != null) urlParams["commentId"] = commentId;
    if (?fileId && fileId != null) urlParams["fileId"] = fileId;
    if (?includeDeleted && includeDeleted != null) queryParams["includeDeleted"] = includeDeleted;
    var response;
    response = _client._request(url, "GET", urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(new Comment.fromJson(data)));
    return completer.future;
  }

  /** Creates a new comment on the given file. */
  Future<Comment> insert(Comment request, String fileId) {
    var completer = new Completer();
    var url = "files/{fileId}/comments";
    var urlParams = new Map();
    var queryParams = new Map();

    if (?fileId && fileId != null) urlParams["fileId"] = fileId;
    var response;
    response = _client._request(url, "POST", body: request.toString(), urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(new Comment.fromJson(data)));
    return completer.future;
  }

  /** Lists a file's comments. */
  Future<CommentList> list(String fileId, {bool includeDeleted, int maxResults, String pageToken, String updatedMin}) {
    var completer = new Completer();
    var url = "files/{fileId}/comments";
    var urlParams = new Map();
    var queryParams = new Map();

    if (?fileId && fileId != null) urlParams["fileId"] = fileId;
    if (?includeDeleted && includeDeleted != null) queryParams["includeDeleted"] = includeDeleted;
    if (?maxResults && maxResults != null) queryParams["maxResults"] = maxResults;
    if (?pageToken && pageToken != null) queryParams["pageToken"] = pageToken;
    if (?updatedMin && updatedMin != null) queryParams["updatedMin"] = updatedMin;
    var response;
    response = _client._request(url, "GET", urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(new CommentList.fromJson(data)));
    return completer.future;
  }

  /** Updates an existing comment. This method supports patch semantics. */
  Future<Comment> patch(Comment request, String fileId, String commentId) {
    var completer = new Completer();
    var url = "files/{fileId}/comments/{commentId}";
    var urlParams = new Map();
    var queryParams = new Map();

    if (?commentId && commentId != null) urlParams["commentId"] = commentId;
    if (?fileId && fileId != null) urlParams["fileId"] = fileId;
    var response;
    response = _client._request(url, "PATCH", body: request.toString(), urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(new Comment.fromJson(data)));
    return completer.future;
  }

  /** Updates an existing comment. */
  Future<Comment> update(Comment request, String fileId, String commentId) {
    var completer = new Completer();
    var url = "files/{fileId}/comments/{commentId}";
    var urlParams = new Map();
    var queryParams = new Map();

    if (?commentId && commentId != null) urlParams["commentId"] = commentId;
    if (?fileId && fileId != null) urlParams["fileId"] = fileId;
    var response;
    response = _client._request(url, "PUT", body: request.toString(), urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(new Comment.fromJson(data)));
    return completer.future;
  }
}

class FilesResource extends Resource {

  FilesResource._internal(Client client) : super(client) {
  }

  /** Creates a copy of the specified file. */
  Future<File> copy(File request, String fileId, {bool convert, bool ocr, String ocrLanguage, bool pinned, String timedTextLanguage, String timedTextTrackName}) {
    var completer = new Completer();
    var url = "files/{fileId}/copy";
    var urlParams = new Map();
    var queryParams = new Map();

    if (?convert && convert != null) queryParams["convert"] = convert;
    if (?fileId && fileId != null) urlParams["fileId"] = fileId;
    if (?ocr && ocr != null) queryParams["ocr"] = ocr;
    if (?ocrLanguage && ocrLanguage != null) queryParams["ocrLanguage"] = ocrLanguage;
    if (?pinned && pinned != null) queryParams["pinned"] = pinned;
    if (?timedTextLanguage && timedTextLanguage != null) queryParams["timedTextLanguage"] = timedTextLanguage;
    if (?timedTextTrackName && timedTextTrackName != null) queryParams["timedTextTrackName"] = timedTextTrackName;
    var response;
    response = _client._request(url, "POST", body: request.toString(), urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(new File.fromJson(data)));
    return completer.future;
  }

  /** Permanently deletes a file by ID. Skips the trash. */
  Future<Map> delete(String fileId) {
    var completer = new Completer();
    var url = "files/{fileId}";
    var urlParams = new Map();
    var queryParams = new Map();

    if (?fileId && fileId != null) urlParams["fileId"] = fileId;
    var response;
    response = _client._request(url, "DELETE", urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(data));
    return completer.future;
  }

  /** Gets a file's metadata by ID. */
  Future<File> get(String fileId, {String projection, bool updateViewedDate}) {
    var completer = new Completer();
    var url = "files/{fileId}";
    var urlParams = new Map();
    var queryParams = new Map();

    if (?fileId && fileId != null) urlParams["fileId"] = fileId;
    if (?projection && projection != null) queryParams["projection"] = projection;
    if (?updateViewedDate && updateViewedDate != null) queryParams["updateViewedDate"] = updateViewedDate;
    var response;
    response = _client._request(url, "GET", urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(new File.fromJson(data)));
    return completer.future;
  }

  /** Insert a new file. */
  Future<File> insert(File request, {String content, String contentType, bool convert, bool ocr, String ocrLanguage, bool pinned, String timedTextLanguage, String timedTextTrackName}) {
    var completer = new Completer();
    var url = "files";
    var uploadUrl = "/upload/drive/v2/files";
    var urlParams = new Map();
    var queryParams = new Map();

    if (?convert && convert != null) queryParams["convert"] = convert;
    if (?ocr && ocr != null) queryParams["ocr"] = ocr;
    if (?ocrLanguage && ocrLanguage != null) queryParams["ocrLanguage"] = ocrLanguage;
    if (?pinned && pinned != null) queryParams["pinned"] = pinned;
    if (?timedTextLanguage && timedTextLanguage != null) queryParams["timedTextLanguage"] = timedTextLanguage;
    if (?timedTextTrackName && timedTextTrackName != null) queryParams["timedTextTrackName"] = timedTextTrackName;
    var response;
    if (?content && content != null) {
      response = _client._upload(uploadUrl, "POST", request.toString(), content, contentType, urlParams: urlParams, queryParams: queryParams);
    } else {
      response = _client._request(url, "POST", body: request.toString(), urlParams: urlParams, queryParams: queryParams);
    }
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(new File.fromJson(data)));
    return completer.future;
  }

  /** Lists the user's files. */
  Future<FileList> list({int maxResults, String pageToken, String projection, String q}) {
    var completer = new Completer();
    var url = "files";
    var urlParams = new Map();
    var queryParams = new Map();

    if (?maxResults && maxResults != null) queryParams["maxResults"] = maxResults;
    if (?pageToken && pageToken != null) queryParams["pageToken"] = pageToken;
    if (?projection && projection != null) queryParams["projection"] = projection;
    if (?q && q != null) queryParams["q"] = q;
    var response;
    response = _client._request(url, "GET", urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(new FileList.fromJson(data)));
    return completer.future;
  }

  /** Updates file metadata and/or content. This method supports patch semantics. */
  Future<File> patch(File request, String fileId, {bool convert, bool newRevision, bool ocr, String ocrLanguage, bool pinned, bool setModifiedDate, String timedTextLanguage, String timedTextTrackName, bool updateViewedDate}) {
    var completer = new Completer();
    var url = "files/{fileId}";
    var urlParams = new Map();
    var queryParams = new Map();

    if (?convert && convert != null) queryParams["convert"] = convert;
    if (?fileId && fileId != null) urlParams["fileId"] = fileId;
    if (?newRevision && newRevision != null) queryParams["newRevision"] = newRevision;
    if (?ocr && ocr != null) queryParams["ocr"] = ocr;
    if (?ocrLanguage && ocrLanguage != null) queryParams["ocrLanguage"] = ocrLanguage;
    if (?pinned && pinned != null) queryParams["pinned"] = pinned;
    if (?setModifiedDate && setModifiedDate != null) queryParams["setModifiedDate"] = setModifiedDate;
    if (?timedTextLanguage && timedTextLanguage != null) queryParams["timedTextLanguage"] = timedTextLanguage;
    if (?timedTextTrackName && timedTextTrackName != null) queryParams["timedTextTrackName"] = timedTextTrackName;
    if (?updateViewedDate && updateViewedDate != null) queryParams["updateViewedDate"] = updateViewedDate;
    var response;
    response = _client._request(url, "PATCH", body: request.toString(), urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(new File.fromJson(data)));
    return completer.future;
  }

  /** Set the file's updated time to the current server time. */
  Future<File> touch(String fileId) {
    var completer = new Completer();
    var url = "files/{fileId}/touch";
    var urlParams = new Map();
    var queryParams = new Map();

    if (?fileId && fileId != null) urlParams["fileId"] = fileId;
    var response;
    response = _client._request(url, "POST", urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(new File.fromJson(data)));
    return completer.future;
  }

  /** Moves a file to the trash. */
  Future<File> trash(String fileId) {
    var completer = new Completer();
    var url = "files/{fileId}/trash";
    var urlParams = new Map();
    var queryParams = new Map();

    if (?fileId && fileId != null) urlParams["fileId"] = fileId;
    var response;
    response = _client._request(url, "POST", urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(new File.fromJson(data)));
    return completer.future;
  }

  /** Restores a file from the trash. */
  Future<File> untrash(String fileId) {
    var completer = new Completer();
    var url = "files/{fileId}/untrash";
    var urlParams = new Map();
    var queryParams = new Map();

    if (?fileId && fileId != null) urlParams["fileId"] = fileId;
    var response;
    response = _client._request(url, "POST", urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(new File.fromJson(data)));
    return completer.future;
  }

  /** Updates file metadata and/or content */
  Future<File> update(File request, String fileId, {String content, String contentType, bool convert, bool newRevision, bool ocr, String ocrLanguage, bool pinned, bool setModifiedDate, String timedTextLanguage, String timedTextTrackName, bool updateViewedDate}) {
    var completer = new Completer();
    var url = "files/{fileId}";
    var uploadUrl = "/upload/drive/v2/files/{fileId}";
    var urlParams = new Map();
    var queryParams = new Map();

    if (?convert && convert != null) queryParams["convert"] = convert;
    if (?fileId && fileId != null) urlParams["fileId"] = fileId;
    if (?newRevision && newRevision != null) queryParams["newRevision"] = newRevision;
    if (?ocr && ocr != null) queryParams["ocr"] = ocr;
    if (?ocrLanguage && ocrLanguage != null) queryParams["ocrLanguage"] = ocrLanguage;
    if (?pinned && pinned != null) queryParams["pinned"] = pinned;
    if (?setModifiedDate && setModifiedDate != null) queryParams["setModifiedDate"] = setModifiedDate;
    if (?timedTextLanguage && timedTextLanguage != null) queryParams["timedTextLanguage"] = timedTextLanguage;
    if (?timedTextTrackName && timedTextTrackName != null) queryParams["timedTextTrackName"] = timedTextTrackName;
    if (?updateViewedDate && updateViewedDate != null) queryParams["updateViewedDate"] = updateViewedDate;
    var response;
    if (?content && content != null) {
      response = _client._upload(uploadUrl, "PUT", request.toString(), content, contentType, urlParams: urlParams, queryParams: queryParams);
    } else {
      response = _client._request(url, "PUT", body: request.toString(), urlParams: urlParams, queryParams: queryParams);
    }
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(new File.fromJson(data)));
    return completer.future;
  }
}

class ParentsResource extends Resource {

  ParentsResource._internal(Client client) : super(client) {
  }

  /** Removes a parent from a file. */
  Future<Map> delete(String fileId, String parentId) {
    var completer = new Completer();
    var url = "files/{fileId}/parents/{parentId}";
    var urlParams = new Map();
    var queryParams = new Map();

    if (?fileId && fileId != null) urlParams["fileId"] = fileId;
    if (?parentId && parentId != null) urlParams["parentId"] = parentId;
    var response;
    response = _client._request(url, "DELETE", urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(data));
    return completer.future;
  }

  /** Gets a specific parent reference. */
  Future<ParentReference> get(String fileId, String parentId) {
    var completer = new Completer();
    var url = "files/{fileId}/parents/{parentId}";
    var urlParams = new Map();
    var queryParams = new Map();

    if (?fileId && fileId != null) urlParams["fileId"] = fileId;
    if (?parentId && parentId != null) urlParams["parentId"] = parentId;
    var response;
    response = _client._request(url, "GET", urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(new ParentReference.fromJson(data)));
    return completer.future;
  }

  /** Adds a parent folder for a file. */
  Future<ParentReference> insert(ParentReference request, String fileId) {
    var completer = new Completer();
    var url = "files/{fileId}/parents";
    var urlParams = new Map();
    var queryParams = new Map();

    if (?fileId && fileId != null) urlParams["fileId"] = fileId;
    var response;
    response = _client._request(url, "POST", body: request.toString(), urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(new ParentReference.fromJson(data)));
    return completer.future;
  }

  /** Lists a file's parents. */
  Future<ParentList> list(String fileId) {
    var completer = new Completer();
    var url = "files/{fileId}/parents";
    var urlParams = new Map();
    var queryParams = new Map();

    if (?fileId && fileId != null) urlParams["fileId"] = fileId;
    var response;
    response = _client._request(url, "GET", urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(new ParentList.fromJson(data)));
    return completer.future;
  }
}

class PermissionsResource extends Resource {

  PermissionsResource._internal(Client client) : super(client) {
  }

  /** Deletes a permission from a file. */
  Future<Map> delete(String fileId, String permissionId) {
    var completer = new Completer();
    var url = "files/{fileId}/permissions/{permissionId}";
    var urlParams = new Map();
    var queryParams = new Map();

    if (?fileId && fileId != null) urlParams["fileId"] = fileId;
    if (?permissionId && permissionId != null) urlParams["permissionId"] = permissionId;
    var response;
    response = _client._request(url, "DELETE", urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(data));
    return completer.future;
  }

  /** Gets a permission by ID. */
  Future<Permission> get(String fileId, String permissionId) {
    var completer = new Completer();
    var url = "files/{fileId}/permissions/{permissionId}";
    var urlParams = new Map();
    var queryParams = new Map();

    if (?fileId && fileId != null) urlParams["fileId"] = fileId;
    if (?permissionId && permissionId != null) urlParams["permissionId"] = permissionId;
    var response;
    response = _client._request(url, "GET", urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(new Permission.fromJson(data)));
    return completer.future;
  }

  /** Inserts a permission for a file. */
  Future<Permission> insert(Permission request, String fileId, {bool sendNotificationEmails}) {
    var completer = new Completer();
    var url = "files/{fileId}/permissions";
    var urlParams = new Map();
    var queryParams = new Map();

    if (?fileId && fileId != null) urlParams["fileId"] = fileId;
    if (?sendNotificationEmails && sendNotificationEmails != null) queryParams["sendNotificationEmails"] = sendNotificationEmails;
    var response;
    response = _client._request(url, "POST", body: request.toString(), urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(new Permission.fromJson(data)));
    return completer.future;
  }

  /** Lists a file's permissions. */
  Future<PermissionList> list(String fileId) {
    var completer = new Completer();
    var url = "files/{fileId}/permissions";
    var urlParams = new Map();
    var queryParams = new Map();

    if (?fileId && fileId != null) urlParams["fileId"] = fileId;
    var response;
    response = _client._request(url, "GET", urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(new PermissionList.fromJson(data)));
    return completer.future;
  }

  /** Updates a permission. This method supports patch semantics. */
  Future<Permission> patch(Permission request, String fileId, String permissionId) {
    var completer = new Completer();
    var url = "files/{fileId}/permissions/{permissionId}";
    var urlParams = new Map();
    var queryParams = new Map();

    if (?fileId && fileId != null) urlParams["fileId"] = fileId;
    if (?permissionId && permissionId != null) urlParams["permissionId"] = permissionId;
    var response;
    response = _client._request(url, "PATCH", body: request.toString(), urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(new Permission.fromJson(data)));
    return completer.future;
  }

  /** Updates a permission. */
  Future<Permission> update(Permission request, String fileId, String permissionId) {
    var completer = new Completer();
    var url = "files/{fileId}/permissions/{permissionId}";
    var urlParams = new Map();
    var queryParams = new Map();

    if (?fileId && fileId != null) urlParams["fileId"] = fileId;
    if (?permissionId && permissionId != null) urlParams["permissionId"] = permissionId;
    var response;
    response = _client._request(url, "PUT", body: request.toString(), urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(new Permission.fromJson(data)));
    return completer.future;
  }
}

class RepliesResource extends Resource {

  RepliesResource._internal(Client client) : super(client) {
  }

  /** Deletes a reply. */
  Future<Map> delete(String fileId, String commentId, String replyId) {
    var completer = new Completer();
    var url = "files/{fileId}/comments/{commentId}/replies/{replyId}";
    var urlParams = new Map();
    var queryParams = new Map();

    if (?commentId && commentId != null) urlParams["commentId"] = commentId;
    if (?fileId && fileId != null) urlParams["fileId"] = fileId;
    if (?replyId && replyId != null) urlParams["replyId"] = replyId;
    var response;
    response = _client._request(url, "DELETE", urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(data));
    return completer.future;
  }

  /** Gets a reply. */
  Future<CommentReply> get(String fileId, String commentId, String replyId, {bool includeDeleted}) {
    var completer = new Completer();
    var url = "files/{fileId}/comments/{commentId}/replies/{replyId}";
    var urlParams = new Map();
    var queryParams = new Map();

    if (?commentId && commentId != null) urlParams["commentId"] = commentId;
    if (?fileId && fileId != null) urlParams["fileId"] = fileId;
    if (?includeDeleted && includeDeleted != null) queryParams["includeDeleted"] = includeDeleted;
    if (?replyId && replyId != null) urlParams["replyId"] = replyId;
    var response;
    response = _client._request(url, "GET", urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(new CommentReply.fromJson(data)));
    return completer.future;
  }

  /** Creates a new reply to the given comment. */
  Future<CommentReply> insert(CommentReply request, String fileId, String commentId) {
    var completer = new Completer();
    var url = "files/{fileId}/comments/{commentId}/replies";
    var urlParams = new Map();
    var queryParams = new Map();

    if (?commentId && commentId != null) urlParams["commentId"] = commentId;
    if (?fileId && fileId != null) urlParams["fileId"] = fileId;
    var response;
    response = _client._request(url, "POST", body: request.toString(), urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(new CommentReply.fromJson(data)));
    return completer.future;
  }

  /** Lists all of the replies to a comment. */
  Future<CommentReplyList> list(String fileId, String commentId, {bool includeDeleted, int maxResults, String pageToken}) {
    var completer = new Completer();
    var url = "files/{fileId}/comments/{commentId}/replies";
    var urlParams = new Map();
    var queryParams = new Map();

    if (?commentId && commentId != null) urlParams["commentId"] = commentId;
    if (?fileId && fileId != null) urlParams["fileId"] = fileId;
    if (?includeDeleted && includeDeleted != null) queryParams["includeDeleted"] = includeDeleted;
    if (?maxResults && maxResults != null) queryParams["maxResults"] = maxResults;
    if (?pageToken && pageToken != null) queryParams["pageToken"] = pageToken;
    var response;
    response = _client._request(url, "GET", urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(new CommentReplyList.fromJson(data)));
    return completer.future;
  }

  /** Updates an existing reply. This method supports patch semantics. */
  Future<CommentReply> patch(CommentReply request, String fileId, String commentId, String replyId) {
    var completer = new Completer();
    var url = "files/{fileId}/comments/{commentId}/replies/{replyId}";
    var urlParams = new Map();
    var queryParams = new Map();

    if (?commentId && commentId != null) urlParams["commentId"] = commentId;
    if (?fileId && fileId != null) urlParams["fileId"] = fileId;
    if (?replyId && replyId != null) urlParams["replyId"] = replyId;
    var response;
    response = _client._request(url, "PATCH", body: request.toString(), urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(new CommentReply.fromJson(data)));
    return completer.future;
  }

  /** Updates an existing reply. */
  Future<CommentReply> update(CommentReply request, String fileId, String commentId, String replyId) {
    var completer = new Completer();
    var url = "files/{fileId}/comments/{commentId}/replies/{replyId}";
    var urlParams = new Map();
    var queryParams = new Map();

    if (?commentId && commentId != null) urlParams["commentId"] = commentId;
    if (?fileId && fileId != null) urlParams["fileId"] = fileId;
    if (?replyId && replyId != null) urlParams["replyId"] = replyId;
    var response;
    response = _client._request(url, "PUT", body: request.toString(), urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(new CommentReply.fromJson(data)));
    return completer.future;
  }
}

class RevisionsResource extends Resource {

  RevisionsResource._internal(Client client) : super(client) {
  }

  /** Removes a revision. */
  Future<Map> delete(String fileId, String revisionId) {
    var completer = new Completer();
    var url = "files/{fileId}/revisions/{revisionId}";
    var urlParams = new Map();
    var queryParams = new Map();

    if (?fileId && fileId != null) urlParams["fileId"] = fileId;
    if (?revisionId && revisionId != null) urlParams["revisionId"] = revisionId;
    var response;
    response = _client._request(url, "DELETE", urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(data));
    return completer.future;
  }

  /** Gets a specific revision. */
  Future<Revision> get(String fileId, String revisionId) {
    var completer = new Completer();
    var url = "files/{fileId}/revisions/{revisionId}";
    var urlParams = new Map();
    var queryParams = new Map();

    if (?fileId && fileId != null) urlParams["fileId"] = fileId;
    if (?revisionId && revisionId != null) urlParams["revisionId"] = revisionId;
    var response;
    response = _client._request(url, "GET", urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(new Revision.fromJson(data)));
    return completer.future;
  }

  /** Lists a file's revisions. */
  Future<RevisionList> list(String fileId) {
    var completer = new Completer();
    var url = "files/{fileId}/revisions";
    var urlParams = new Map();
    var queryParams = new Map();

    if (?fileId && fileId != null) urlParams["fileId"] = fileId;
    var response;
    response = _client._request(url, "GET", urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(new RevisionList.fromJson(data)));
    return completer.future;
  }

  /** Updates a revision. This method supports patch semantics. */
  Future<Revision> patch(Revision request, String fileId, String revisionId) {
    var completer = new Completer();
    var url = "files/{fileId}/revisions/{revisionId}";
    var urlParams = new Map();
    var queryParams = new Map();

    if (?fileId && fileId != null) urlParams["fileId"] = fileId;
    if (?revisionId && revisionId != null) urlParams["revisionId"] = revisionId;
    var response;
    response = _client._request(url, "PATCH", body: request.toString(), urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(new Revision.fromJson(data)));
    return completer.future;
  }

  /** Updates a revision. */
  Future<Revision> update(Revision request, String fileId, String revisionId) {
    var completer = new Completer();
    var url = "files/{fileId}/revisions/{revisionId}";
    var urlParams = new Map();
    var queryParams = new Map();

    if (?fileId && fileId != null) urlParams["fileId"] = fileId;
    if (?revisionId && revisionId != null) urlParams["revisionId"] = revisionId;
    var response;
    response = _client._request(url, "PUT", body: request.toString(), urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(new Revision.fromJson(data)));
    return completer.future;
  }
}

