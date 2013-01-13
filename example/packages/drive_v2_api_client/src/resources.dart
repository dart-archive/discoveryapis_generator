part of drive_v2_api_client;

class AboutResource extends Resource {

  AboutResource._internal(Client client) : super(client) {
  }

  /**
   * Gets the information about the current user along with Drive API settings
   *
   * [includeSubscribed] - When calculating the number of remaining change IDs, whether to include shared files and public files the user has opened. When set to false, this counts only change IDs for owned files and any shared or public files that the user has explictly added to a folder in Drive.
   *   Default: true
   *
   * [maxChangeIdCount] - Maximum number of remaining change IDs to count
   *   Default: 1
   *
   * [startChangeId] - Change ID to start counting from when calculating number of remaining change IDs
   *
   * [optParams] - Additional query parameters
   */
  Future<About> get({bool includeSubscribed, String maxChangeIdCount, String startChangeId, Map optParams}) {
    var completer = new Completer();
    var url = "about";
    var urlParams = new Map();
    var queryParams = new Map();

    var paramErrors = new StringBuffer();
    if (includeSubscribed != null) queryParams["includeSubscribed"] = includeSubscribed;
    if (maxChangeIdCount != null) queryParams["maxChangeIdCount"] = maxChangeIdCount;
    if (startChangeId != null) queryParams["startChangeId"] = startChangeId;
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
    ..then((data) => completer.complete(new About.fromJson(data)));
    return completer.future;
  }
}

class AppsResource extends Resource {

  AppsResource._internal(Client client) : super(client) {
  }

  /**
   * Gets a specific app.
   *
   * [appId] - The ID of the app.
   *
   * [optParams] - Additional query parameters
   */
  Future<App> get(String appId, {Map optParams}) {
    var completer = new Completer();
    var url = "apps/{appId}";
    var urlParams = new Map();
    var queryParams = new Map();

    var paramErrors = new StringBuffer();
    if (appId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("appId is required");
    }
    if (appId != null) urlParams["appId"] = appId;
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
    ..then((data) => completer.complete(new App.fromJson(data)));
    return completer.future;
  }

  /**
   * Lists a user's apps.
   *
   * [optParams] - Additional query parameters
   */
  Future<AppList> list({Map optParams}) {
    var completer = new Completer();
    var url = "apps";
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

  /**
   * Gets a specific change.
   *
   * [changeId] - The ID of the change.
   *
   * [optParams] - Additional query parameters
   */
  Future<Change> get(String changeId, {Map optParams}) {
    var completer = new Completer();
    var url = "changes/{changeId}";
    var urlParams = new Map();
    var queryParams = new Map();

    var paramErrors = new StringBuffer();
    if (changeId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("changeId is required");
    }
    if (changeId != null) urlParams["changeId"] = changeId;
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
    ..then((data) => completer.complete(new Change.fromJson(data)));
    return completer.future;
  }

  /**
   * Lists the changes for a user.
   *
   * [includeDeleted] - Whether to include deleted items.
   *   Default: true
   *
   * [includeSubscribed] - Whether to include shared files and public files the user has opened. When set to false, the list will include owned files plus any shared or public files the user has explictly added to a folder in Drive.
   *   Default: true
   *
   * [maxResults] - Maximum number of changes to return.
   *   Default: 100
   *   Minimum: 0
   *
   * [pageToken] - Page token for changes.
   *
   * [startChangeId] - Change ID to start listing changes from.
   *
   * [optParams] - Additional query parameters
   */
  Future<ChangeList> list({bool includeDeleted, bool includeSubscribed, int maxResults, String pageToken, String startChangeId, Map optParams}) {
    var completer = new Completer();
    var url = "changes";
    var urlParams = new Map();
    var queryParams = new Map();

    var paramErrors = new StringBuffer();
    if (includeDeleted != null) queryParams["includeDeleted"] = includeDeleted;
    if (includeSubscribed != null) queryParams["includeSubscribed"] = includeSubscribed;
    if (maxResults != null) queryParams["maxResults"] = maxResults;
    if (pageToken != null) queryParams["pageToken"] = pageToken;
    if (startChangeId != null) queryParams["startChangeId"] = startChangeId;
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
    ..then((data) => completer.complete(new ChangeList.fromJson(data)));
    return completer.future;
  }
}

class ChildrenResource extends Resource {

  ChildrenResource._internal(Client client) : super(client) {
  }

  /**
   * Removes a child from a folder.
   *
   * [folderId] - The ID of the folder.
   *
   * [childId] - The ID of the child.
   *
   * [optParams] - Additional query parameters
   */
  Future<Map> delete(String folderId, String childId, {Map optParams}) {
    var completer = new Completer();
    var url = "files/{folderId}/children/{childId}";
    var urlParams = new Map();
    var queryParams = new Map();

    var paramErrors = new StringBuffer();
    if (childId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("childId is required");
    }
    if (childId != null) urlParams["childId"] = childId;
    if (folderId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("folderId is required");
    }
    if (folderId != null) urlParams["folderId"] = folderId;
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
    response = _client._request(url, "DELETE", urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(data));
    return completer.future;
  }

  /**
   * Gets a specific child reference.
   *
   * [folderId] - The ID of the folder.
   *
   * [childId] - The ID of the child.
   *
   * [optParams] - Additional query parameters
   */
  Future<ChildReference> get(String folderId, String childId, {Map optParams}) {
    var completer = new Completer();
    var url = "files/{folderId}/children/{childId}";
    var urlParams = new Map();
    var queryParams = new Map();

    var paramErrors = new StringBuffer();
    if (childId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("childId is required");
    }
    if (childId != null) urlParams["childId"] = childId;
    if (folderId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("folderId is required");
    }
    if (folderId != null) urlParams["folderId"] = folderId;
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
    ..then((data) => completer.complete(new ChildReference.fromJson(data)));
    return completer.future;
  }

  /**
   * Inserts a file into a folder.
   *
   * [request] - ChildReference to send in this request
   *
   * [folderId] - The ID of the folder.
   *
   * [optParams] - Additional query parameters
   */
  Future<ChildReference> insert(ChildReference request, String folderId, {Map optParams}) {
    var completer = new Completer();
    var url = "files/{folderId}/children";
    var urlParams = new Map();
    var queryParams = new Map();

    var paramErrors = new StringBuffer();
    if (folderId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("folderId is required");
    }
    if (folderId != null) urlParams["folderId"] = folderId;
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
    ..then((data) => completer.complete(new ChildReference.fromJson(data)));
    return completer.future;
  }

  /**
   * Lists a folder's children.
   *
   * [folderId] - The ID of the folder.
   *
   * [maxResults] - Maximum number of children to return.
   *   Default: 100
   *   Minimum: 0
   *
   * [pageToken] - Page token for children.
   *
   * [q] - Query string for searching children.
   *
   * [optParams] - Additional query parameters
   */
  Future<ChildList> list(String folderId, {int maxResults, String pageToken, String q, Map optParams}) {
    var completer = new Completer();
    var url = "files/{folderId}/children";
    var urlParams = new Map();
    var queryParams = new Map();

    var paramErrors = new StringBuffer();
    if (folderId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("folderId is required");
    }
    if (folderId != null) urlParams["folderId"] = folderId;
    if (maxResults != null) queryParams["maxResults"] = maxResults;
    if (pageToken != null) queryParams["pageToken"] = pageToken;
    if (q != null) queryParams["q"] = q;
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
    ..then((data) => completer.complete(new ChildList.fromJson(data)));
    return completer.future;
  }
}

class CommentsResource extends Resource {

  CommentsResource._internal(Client client) : super(client) {
  }

  /**
   * Deletes a comment.
   *
   * [fileId] - The ID of the file.
   *
   * [commentId] - The ID of the comment.
   *
   * [optParams] - Additional query parameters
   */
  Future<Map> delete(String fileId, String commentId, {Map optParams}) {
    var completer = new Completer();
    var url = "files/{fileId}/comments/{commentId}";
    var urlParams = new Map();
    var queryParams = new Map();

    var paramErrors = new StringBuffer();
    if (commentId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("commentId is required");
    }
    if (commentId != null) urlParams["commentId"] = commentId;
    if (fileId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("fileId is required");
    }
    if (fileId != null) urlParams["fileId"] = fileId;
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
    response = _client._request(url, "DELETE", urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(data));
    return completer.future;
  }

  /**
   * Gets a comment by ID.
   *
   * [fileId] - The ID of the file.
   *
   * [commentId] - The ID of the comment.
   *
   * [includeDeleted] - If set, this will succeed when retrieving a deleted comment, and will include any deleted replies.
   *   Default: false
   *
   * [optParams] - Additional query parameters
   */
  Future<Comment> get(String fileId, String commentId, {bool includeDeleted, Map optParams}) {
    var completer = new Completer();
    var url = "files/{fileId}/comments/{commentId}";
    var urlParams = new Map();
    var queryParams = new Map();

    var paramErrors = new StringBuffer();
    if (commentId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("commentId is required");
    }
    if (commentId != null) urlParams["commentId"] = commentId;
    if (fileId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("fileId is required");
    }
    if (fileId != null) urlParams["fileId"] = fileId;
    if (includeDeleted != null) queryParams["includeDeleted"] = includeDeleted;
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
    ..then((data) => completer.complete(new Comment.fromJson(data)));
    return completer.future;
  }

  /**
   * Creates a new comment on the given file.
   *
   * [request] - Comment to send in this request
   *
   * [fileId] - The ID of the file.
   *
   * [optParams] - Additional query parameters
   */
  Future<Comment> insert(Comment request, String fileId, {Map optParams}) {
    var completer = new Completer();
    var url = "files/{fileId}/comments";
    var urlParams = new Map();
    var queryParams = new Map();

    var paramErrors = new StringBuffer();
    if (fileId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("fileId is required");
    }
    if (fileId != null) urlParams["fileId"] = fileId;
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
    ..then((data) => completer.complete(new Comment.fromJson(data)));
    return completer.future;
  }

  /**
   * Lists a file's comments.
   *
   * [fileId] - The ID of the file.
   *
   * [includeDeleted] - If set, all comments and replies, including deleted comments and replies (with content stripped) will be returned.
   *   Default: false
   *
   * [maxResults] - The maximum number of discussions to include in the response, used for paging.
   *   Default: 20
   *   Minimum: 0
   *   Maximum: 100
   *
   * [pageToken] - The continuation token, used to page through large result sets. To get the next page of results, set this parameter to the value of "nextPageToken" from the previous response.
   *
   * [updatedMin] - Only discussions that were updated after this timestamp will be returned. Formatted as an RFC 3339 timestamp.
   *
   * [optParams] - Additional query parameters
   */
  Future<CommentList> list(String fileId, {bool includeDeleted, int maxResults, String pageToken, String updatedMin, Map optParams}) {
    var completer = new Completer();
    var url = "files/{fileId}/comments";
    var urlParams = new Map();
    var queryParams = new Map();

    var paramErrors = new StringBuffer();
    if (fileId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("fileId is required");
    }
    if (fileId != null) urlParams["fileId"] = fileId;
    if (includeDeleted != null) queryParams["includeDeleted"] = includeDeleted;
    if (maxResults != null) queryParams["maxResults"] = maxResults;
    if (pageToken != null) queryParams["pageToken"] = pageToken;
    if (updatedMin != null) queryParams["updatedMin"] = updatedMin;
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
    ..then((data) => completer.complete(new CommentList.fromJson(data)));
    return completer.future;
  }

  /**
   * Updates an existing comment. This method supports patch semantics.
   *
   * [request] - Comment to send in this request
   *
   * [fileId] - The ID of the file.
   *
   * [commentId] - The ID of the comment.
   *
   * [optParams] - Additional query parameters
   */
  Future<Comment> patch(Comment request, String fileId, String commentId, {Map optParams}) {
    var completer = new Completer();
    var url = "files/{fileId}/comments/{commentId}";
    var urlParams = new Map();
    var queryParams = new Map();

    var paramErrors = new StringBuffer();
    if (commentId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("commentId is required");
    }
    if (commentId != null) urlParams["commentId"] = commentId;
    if (fileId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("fileId is required");
    }
    if (fileId != null) urlParams["fileId"] = fileId;
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
    response = _client._request(url, "PATCH", body: request.toString(), urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(new Comment.fromJson(data)));
    return completer.future;
  }

  /**
   * Updates an existing comment.
   *
   * [request] - Comment to send in this request
   *
   * [fileId] - The ID of the file.
   *
   * [commentId] - The ID of the comment.
   *
   * [optParams] - Additional query parameters
   */
  Future<Comment> update(Comment request, String fileId, String commentId, {Map optParams}) {
    var completer = new Completer();
    var url = "files/{fileId}/comments/{commentId}";
    var urlParams = new Map();
    var queryParams = new Map();

    var paramErrors = new StringBuffer();
    if (commentId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("commentId is required");
    }
    if (commentId != null) urlParams["commentId"] = commentId;
    if (fileId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("fileId is required");
    }
    if (fileId != null) urlParams["fileId"] = fileId;
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

  /**
   * Creates a copy of the specified file.
   *
   * [request] - File to send in this request
   *
   * [fileId] - The ID of the file to copy.
   *
   * [convert] - Whether to convert this file to the corresponding Google Docs format.
   *   Default: false
   *
   * [ocr] - Whether to attempt OCR on .jpg, .png, .gif, or .pdf uploads.
   *   Default: false
   *
   * [ocrLanguage] - If ocr is true, hints at the language to use. Valid values are ISO 639-1 codes.
   *
   * [pinned] - Whether to pin the head revision of the new copy.
   *   Default: false
   *
   * [timedTextLanguage] - The language of the timed text.
   *
   * [timedTextTrackName] - The timed text track name.
   *
   * [optParams] - Additional query parameters
   */
  Future<File> copy(File request, String fileId, {bool convert, bool ocr, String ocrLanguage, bool pinned, String timedTextLanguage, String timedTextTrackName, Map optParams}) {
    var completer = new Completer();
    var url = "files/{fileId}/copy";
    var urlParams = new Map();
    var queryParams = new Map();

    var paramErrors = new StringBuffer();
    if (convert != null) queryParams["convert"] = convert;
    if (fileId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("fileId is required");
    }
    if (fileId != null) urlParams["fileId"] = fileId;
    if (ocr != null) queryParams["ocr"] = ocr;
    if (ocrLanguage != null) queryParams["ocrLanguage"] = ocrLanguage;
    if (pinned != null) queryParams["pinned"] = pinned;
    if (timedTextLanguage != null) queryParams["timedTextLanguage"] = timedTextLanguage;
    if (timedTextTrackName != null) queryParams["timedTextTrackName"] = timedTextTrackName;
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
    ..then((data) => completer.complete(new File.fromJson(data)));
    return completer.future;
  }

  /**
   * Permanently deletes a file by ID. Skips the trash.
   *
   * [fileId] - The ID of the file to delete.
   *
   * [optParams] - Additional query parameters
   */
  Future<Map> delete(String fileId, {Map optParams}) {
    var completer = new Completer();
    var url = "files/{fileId}";
    var urlParams = new Map();
    var queryParams = new Map();

    var paramErrors = new StringBuffer();
    if (fileId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("fileId is required");
    }
    if (fileId != null) urlParams["fileId"] = fileId;
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
    response = _client._request(url, "DELETE", urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(data));
    return completer.future;
  }

  /**
   * Gets a file's metadata by ID.
   *
   * [fileId] - The ID for the file in question.
   *
   * [projection] - This parameter is deprecated and has no function.
   *   Allowed values:
   *     BASIC - Deprecated
   *     FULL - Deprecated
   *
   * [updateViewedDate] - Whether to update the view date after successfully retrieving the file.
   *   Default: false
   *
   * [optParams] - Additional query parameters
   */
  Future<File> get(String fileId, {String projection, bool updateViewedDate, Map optParams}) {
    var completer = new Completer();
    var url = "files/{fileId}";
    var urlParams = new Map();
    var queryParams = new Map();

    var paramErrors = new StringBuffer();
    if (fileId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("fileId is required");
    }
    if (fileId != null) urlParams["fileId"] = fileId;
    if (!["BASIC", "FULL"].contains(projection)) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("Allowed values for projection: BASIC, FULL");
    }
    if (projection != null) queryParams["projection"] = projection;
    if (updateViewedDate != null) queryParams["updateViewedDate"] = updateViewedDate;
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
    ..then((data) => completer.complete(new File.fromJson(data)));
    return completer.future;
  }

  /**
   * Insert a new file.
   *
   * [request] - File to send in this request
   *
   * [content] - Base64 Data of the file content to be uploaded
   *
   * [contentType] - MimeType of the file to be uploaded
   *
   * [convert] - Whether to convert this file to the corresponding Google Docs format.
   *   Default: false
   *
   * [ocr] - Whether to attempt OCR on .jpg, .png, .gif, or .pdf uploads.
   *   Default: false
   *
   * [ocrLanguage] - If ocr is true, hints at the language to use. Valid values are ISO 639-1 codes.
   *
   * [pinned] - Whether to pin the head revision of the uploaded file.
   *   Default: false
   *
   * [timedTextLanguage] - The language of the timed text.
   *
   * [timedTextTrackName] - The timed text track name.
   *
   * [optParams] - Additional query parameters
   */
  Future<File> insert(File request, {String content, String contentType, bool convert, bool ocr, String ocrLanguage, bool pinned, String timedTextLanguage, String timedTextTrackName, Map optParams}) {
    var completer = new Completer();
    var url = "files";
    var uploadUrl = "/upload/drive/v2/files";
    var urlParams = new Map();
    var queryParams = new Map();

    var paramErrors = new StringBuffer();
    if (convert != null) queryParams["convert"] = convert;
    if (ocr != null) queryParams["ocr"] = ocr;
    if (ocrLanguage != null) queryParams["ocrLanguage"] = ocrLanguage;
    if (pinned != null) queryParams["pinned"] = pinned;
    if (timedTextLanguage != null) queryParams["timedTextLanguage"] = timedTextLanguage;
    if (timedTextTrackName != null) queryParams["timedTextTrackName"] = timedTextTrackName;
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

  /**
   * Lists the user's files.
   *
   * [maxResults] - Maximum number of files to return.
   *   Default: 100
   *   Minimum: 0
   *
   * [pageToken] - Page token for files.
   *
   * [projection] - This parameter is deprecated and has no function.
   *   Allowed values:
   *     BASIC - Deprecated
   *     FULL - Deprecated
   *
   * [q] - Query string for searching files.
   *
   * [optParams] - Additional query parameters
   */
  Future<FileList> list({int maxResults, String pageToken, String projection, String q, Map optParams}) {
    var completer = new Completer();
    var url = "files";
    var urlParams = new Map();
    var queryParams = new Map();

    var paramErrors = new StringBuffer();
    if (maxResults != null) queryParams["maxResults"] = maxResults;
    if (pageToken != null) queryParams["pageToken"] = pageToken;
    if (!["BASIC", "FULL"].contains(projection)) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("Allowed values for projection: BASIC, FULL");
    }
    if (projection != null) queryParams["projection"] = projection;
    if (q != null) queryParams["q"] = q;
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
    ..then((data) => completer.complete(new FileList.fromJson(data)));
    return completer.future;
  }

  /**
   * Updates file metadata and/or content. This method supports patch semantics.
   *
   * [request] - File to send in this request
   *
   * [fileId] - The ID of the file to update.
   *
   * [convert] - Whether to convert this file to the corresponding Google Docs format.
   *   Default: false
   *
   * [newRevision] - Whether a blob upload should create a new revision. If false, the blob data in the current head revision will be replaced.
   *   Default: true
   *
   * [ocr] - Whether to attempt OCR on .jpg, .png, .gif, or .pdf uploads.
   *   Default: false
   *
   * [ocrLanguage] - If ocr is true, hints at the language to use. Valid values are ISO 639-1 codes.
   *
   * [pinned] - Whether to pin the new revision.
   *   Default: false
   *
   * [setModifiedDate] - Whether to set the modified date with the supplied modified date.
   *   Default: false
   *
   * [timedTextLanguage] - The language of the timed text.
   *
   * [timedTextTrackName] - The timed text track name.
   *
   * [updateViewedDate] - Whether to update the view date after successfully updating the file.
   *   Default: true
   *
   * [optParams] - Additional query parameters
   */
  Future<File> patch(File request, String fileId, {bool convert, bool newRevision, bool ocr, String ocrLanguage, bool pinned, bool setModifiedDate, String timedTextLanguage, String timedTextTrackName, bool updateViewedDate, Map optParams}) {
    var completer = new Completer();
    var url = "files/{fileId}";
    var urlParams = new Map();
    var queryParams = new Map();

    var paramErrors = new StringBuffer();
    if (convert != null) queryParams["convert"] = convert;
    if (fileId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("fileId is required");
    }
    if (fileId != null) urlParams["fileId"] = fileId;
    if (newRevision != null) queryParams["newRevision"] = newRevision;
    if (ocr != null) queryParams["ocr"] = ocr;
    if (ocrLanguage != null) queryParams["ocrLanguage"] = ocrLanguage;
    if (pinned != null) queryParams["pinned"] = pinned;
    if (setModifiedDate != null) queryParams["setModifiedDate"] = setModifiedDate;
    if (timedTextLanguage != null) queryParams["timedTextLanguage"] = timedTextLanguage;
    if (timedTextTrackName != null) queryParams["timedTextTrackName"] = timedTextTrackName;
    if (updateViewedDate != null) queryParams["updateViewedDate"] = updateViewedDate;
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
    response = _client._request(url, "PATCH", body: request.toString(), urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(new File.fromJson(data)));
    return completer.future;
  }

  /**
   * Set the file's updated time to the current server time.
   *
   * [fileId] - The ID of the file to update.
   *
   * [optParams] - Additional query parameters
   */
  Future<File> touch(String fileId, {Map optParams}) {
    var completer = new Completer();
    var url = "files/{fileId}/touch";
    var urlParams = new Map();
    var queryParams = new Map();

    var paramErrors = new StringBuffer();
    if (fileId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("fileId is required");
    }
    if (fileId != null) urlParams["fileId"] = fileId;
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
    response = _client._request(url, "POST", urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(new File.fromJson(data)));
    return completer.future;
  }

  /**
   * Moves a file to the trash.
   *
   * [fileId] - The ID of the file to trash.
   *
   * [optParams] - Additional query parameters
   */
  Future<File> trash(String fileId, {Map optParams}) {
    var completer = new Completer();
    var url = "files/{fileId}/trash";
    var urlParams = new Map();
    var queryParams = new Map();

    var paramErrors = new StringBuffer();
    if (fileId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("fileId is required");
    }
    if (fileId != null) urlParams["fileId"] = fileId;
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
    response = _client._request(url, "POST", urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(new File.fromJson(data)));
    return completer.future;
  }

  /**
   * Restores a file from the trash.
   *
   * [fileId] - The ID of the file to untrash.
   *
   * [optParams] - Additional query parameters
   */
  Future<File> untrash(String fileId, {Map optParams}) {
    var completer = new Completer();
    var url = "files/{fileId}/untrash";
    var urlParams = new Map();
    var queryParams = new Map();

    var paramErrors = new StringBuffer();
    if (fileId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("fileId is required");
    }
    if (fileId != null) urlParams["fileId"] = fileId;
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
    response = _client._request(url, "POST", urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(new File.fromJson(data)));
    return completer.future;
  }

  /**
   * Updates file metadata and/or content
   *
   * [request] - File to send in this request
   *
   * [fileId] - The ID of the file to update.
   *
   * [content] - Base64 Data of the file content to be uploaded
   *
   * [contentType] - MimeType of the file to be uploaded
   *
   * [convert] - Whether to convert this file to the corresponding Google Docs format.
   *   Default: false
   *
   * [newRevision] - Whether a blob upload should create a new revision. If false, the blob data in the current head revision will be replaced.
   *   Default: true
   *
   * [ocr] - Whether to attempt OCR on .jpg, .png, .gif, or .pdf uploads.
   *   Default: false
   *
   * [ocrLanguage] - If ocr is true, hints at the language to use. Valid values are ISO 639-1 codes.
   *
   * [pinned] - Whether to pin the new revision.
   *   Default: false
   *
   * [setModifiedDate] - Whether to set the modified date with the supplied modified date.
   *   Default: false
   *
   * [timedTextLanguage] - The language of the timed text.
   *
   * [timedTextTrackName] - The timed text track name.
   *
   * [updateViewedDate] - Whether to update the view date after successfully updating the file.
   *   Default: true
   *
   * [optParams] - Additional query parameters
   */
  Future<File> update(File request, String fileId, {String content, String contentType, bool convert, bool newRevision, bool ocr, String ocrLanguage, bool pinned, bool setModifiedDate, String timedTextLanguage, String timedTextTrackName, bool updateViewedDate, Map optParams}) {
    var completer = new Completer();
    var url = "files/{fileId}";
    var uploadUrl = "/upload/drive/v2/files/{fileId}";
    var urlParams = new Map();
    var queryParams = new Map();

    var paramErrors = new StringBuffer();
    if (convert != null) queryParams["convert"] = convert;
    if (fileId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("fileId is required");
    }
    if (fileId != null) urlParams["fileId"] = fileId;
    if (newRevision != null) queryParams["newRevision"] = newRevision;
    if (ocr != null) queryParams["ocr"] = ocr;
    if (ocrLanguage != null) queryParams["ocrLanguage"] = ocrLanguage;
    if (pinned != null) queryParams["pinned"] = pinned;
    if (setModifiedDate != null) queryParams["setModifiedDate"] = setModifiedDate;
    if (timedTextLanguage != null) queryParams["timedTextLanguage"] = timedTextLanguage;
    if (timedTextTrackName != null) queryParams["timedTextTrackName"] = timedTextTrackName;
    if (updateViewedDate != null) queryParams["updateViewedDate"] = updateViewedDate;
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

  /**
   * Removes a parent from a file.
   *
   * [fileId] - The ID of the file.
   *
   * [parentId] - The ID of the parent.
   *
   * [optParams] - Additional query parameters
   */
  Future<Map> delete(String fileId, String parentId, {Map optParams}) {
    var completer = new Completer();
    var url = "files/{fileId}/parents/{parentId}";
    var urlParams = new Map();
    var queryParams = new Map();

    var paramErrors = new StringBuffer();
    if (fileId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("fileId is required");
    }
    if (fileId != null) urlParams["fileId"] = fileId;
    if (parentId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("parentId is required");
    }
    if (parentId != null) urlParams["parentId"] = parentId;
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
    response = _client._request(url, "DELETE", urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(data));
    return completer.future;
  }

  /**
   * Gets a specific parent reference.
   *
   * [fileId] - The ID of the file.
   *
   * [parentId] - The ID of the parent.
   *
   * [optParams] - Additional query parameters
   */
  Future<ParentReference> get(String fileId, String parentId, {Map optParams}) {
    var completer = new Completer();
    var url = "files/{fileId}/parents/{parentId}";
    var urlParams = new Map();
    var queryParams = new Map();

    var paramErrors = new StringBuffer();
    if (fileId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("fileId is required");
    }
    if (fileId != null) urlParams["fileId"] = fileId;
    if (parentId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("parentId is required");
    }
    if (parentId != null) urlParams["parentId"] = parentId;
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
    ..then((data) => completer.complete(new ParentReference.fromJson(data)));
    return completer.future;
  }

  /**
   * Adds a parent folder for a file.
   *
   * [request] - ParentReference to send in this request
   *
   * [fileId] - The ID of the file.
   *
   * [optParams] - Additional query parameters
   */
  Future<ParentReference> insert(ParentReference request, String fileId, {Map optParams}) {
    var completer = new Completer();
    var url = "files/{fileId}/parents";
    var urlParams = new Map();
    var queryParams = new Map();

    var paramErrors = new StringBuffer();
    if (fileId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("fileId is required");
    }
    if (fileId != null) urlParams["fileId"] = fileId;
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
    ..then((data) => completer.complete(new ParentReference.fromJson(data)));
    return completer.future;
  }

  /**
   * Lists a file's parents.
   *
   * [fileId] - The ID of the file.
   *
   * [optParams] - Additional query parameters
   */
  Future<ParentList> list(String fileId, {Map optParams}) {
    var completer = new Completer();
    var url = "files/{fileId}/parents";
    var urlParams = new Map();
    var queryParams = new Map();

    var paramErrors = new StringBuffer();
    if (fileId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("fileId is required");
    }
    if (fileId != null) urlParams["fileId"] = fileId;
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
    ..then((data) => completer.complete(new ParentList.fromJson(data)));
    return completer.future;
  }
}

class PermissionsResource extends Resource {

  PermissionsResource._internal(Client client) : super(client) {
  }

  /**
   * Deletes a permission from a file.
   *
   * [fileId] - The ID for the file.
   *
   * [permissionId] - The ID for the permission.
   *
   * [optParams] - Additional query parameters
   */
  Future<Map> delete(String fileId, String permissionId, {Map optParams}) {
    var completer = new Completer();
    var url = "files/{fileId}/permissions/{permissionId}";
    var urlParams = new Map();
    var queryParams = new Map();

    var paramErrors = new StringBuffer();
    if (fileId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("fileId is required");
    }
    if (fileId != null) urlParams["fileId"] = fileId;
    if (permissionId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("permissionId is required");
    }
    if (permissionId != null) urlParams["permissionId"] = permissionId;
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
    response = _client._request(url, "DELETE", urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(data));
    return completer.future;
  }

  /**
   * Gets a permission by ID.
   *
   * [fileId] - The ID for the file.
   *
   * [permissionId] - The ID for the permission.
   *
   * [optParams] - Additional query parameters
   */
  Future<Permission> get(String fileId, String permissionId, {Map optParams}) {
    var completer = new Completer();
    var url = "files/{fileId}/permissions/{permissionId}";
    var urlParams = new Map();
    var queryParams = new Map();

    var paramErrors = new StringBuffer();
    if (fileId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("fileId is required");
    }
    if (fileId != null) urlParams["fileId"] = fileId;
    if (permissionId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("permissionId is required");
    }
    if (permissionId != null) urlParams["permissionId"] = permissionId;
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
    ..then((data) => completer.complete(new Permission.fromJson(data)));
    return completer.future;
  }

  /**
   * Inserts a permission for a file.
   *
   * [request] - Permission to send in this request
   *
   * [fileId] - The ID for the file.
   *
   * [sendNotificationEmails] - Whether to send notification emails.
   *   Default: true
   *
   * [optParams] - Additional query parameters
   */
  Future<Permission> insert(Permission request, String fileId, {bool sendNotificationEmails, Map optParams}) {
    var completer = new Completer();
    var url = "files/{fileId}/permissions";
    var urlParams = new Map();
    var queryParams = new Map();

    var paramErrors = new StringBuffer();
    if (fileId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("fileId is required");
    }
    if (fileId != null) urlParams["fileId"] = fileId;
    if (sendNotificationEmails != null) queryParams["sendNotificationEmails"] = sendNotificationEmails;
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
    ..then((data) => completer.complete(new Permission.fromJson(data)));
    return completer.future;
  }

  /**
   * Lists a file's permissions.
   *
   * [fileId] - The ID for the file.
   *
   * [optParams] - Additional query parameters
   */
  Future<PermissionList> list(String fileId, {Map optParams}) {
    var completer = new Completer();
    var url = "files/{fileId}/permissions";
    var urlParams = new Map();
    var queryParams = new Map();

    var paramErrors = new StringBuffer();
    if (fileId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("fileId is required");
    }
    if (fileId != null) urlParams["fileId"] = fileId;
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
    ..then((data) => completer.complete(new PermissionList.fromJson(data)));
    return completer.future;
  }

  /**
   * Updates a permission. This method supports patch semantics.
   *
   * [request] - Permission to send in this request
   *
   * [fileId] - The ID for the file.
   *
   * [permissionId] - The ID for the permission.
   *
   * [optParams] - Additional query parameters
   */
  Future<Permission> patch(Permission request, String fileId, String permissionId, {Map optParams}) {
    var completer = new Completer();
    var url = "files/{fileId}/permissions/{permissionId}";
    var urlParams = new Map();
    var queryParams = new Map();

    var paramErrors = new StringBuffer();
    if (fileId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("fileId is required");
    }
    if (fileId != null) urlParams["fileId"] = fileId;
    if (permissionId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("permissionId is required");
    }
    if (permissionId != null) urlParams["permissionId"] = permissionId;
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
    response = _client._request(url, "PATCH", body: request.toString(), urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(new Permission.fromJson(data)));
    return completer.future;
  }

  /**
   * Updates a permission.
   *
   * [request] - Permission to send in this request
   *
   * [fileId] - The ID for the file.
   *
   * [permissionId] - The ID for the permission.
   *
   * [optParams] - Additional query parameters
   */
  Future<Permission> update(Permission request, String fileId, String permissionId, {Map optParams}) {
    var completer = new Completer();
    var url = "files/{fileId}/permissions/{permissionId}";
    var urlParams = new Map();
    var queryParams = new Map();

    var paramErrors = new StringBuffer();
    if (fileId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("fileId is required");
    }
    if (fileId != null) urlParams["fileId"] = fileId;
    if (permissionId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("permissionId is required");
    }
    if (permissionId != null) urlParams["permissionId"] = permissionId;
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

  /**
   * Deletes a reply.
   *
   * [fileId] - The ID of the file.
   *
   * [commentId] - The ID of the comment.
   *
   * [replyId] - The ID of the reply.
   *
   * [optParams] - Additional query parameters
   */
  Future<Map> delete(String fileId, String commentId, String replyId, {Map optParams}) {
    var completer = new Completer();
    var url = "files/{fileId}/comments/{commentId}/replies/{replyId}";
    var urlParams = new Map();
    var queryParams = new Map();

    var paramErrors = new StringBuffer();
    if (commentId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("commentId is required");
    }
    if (commentId != null) urlParams["commentId"] = commentId;
    if (fileId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("fileId is required");
    }
    if (fileId != null) urlParams["fileId"] = fileId;
    if (replyId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("replyId is required");
    }
    if (replyId != null) urlParams["replyId"] = replyId;
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
    response = _client._request(url, "DELETE", urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(data));
    return completer.future;
  }

  /**
   * Gets a reply.
   *
   * [fileId] - The ID of the file.
   *
   * [commentId] - The ID of the comment.
   *
   * [replyId] - The ID of the reply.
   *
   * [includeDeleted] - If set, this will succeed when retrieving a deleted reply.
   *   Default: false
   *
   * [optParams] - Additional query parameters
   */
  Future<CommentReply> get(String fileId, String commentId, String replyId, {bool includeDeleted, Map optParams}) {
    var completer = new Completer();
    var url = "files/{fileId}/comments/{commentId}/replies/{replyId}";
    var urlParams = new Map();
    var queryParams = new Map();

    var paramErrors = new StringBuffer();
    if (commentId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("commentId is required");
    }
    if (commentId != null) urlParams["commentId"] = commentId;
    if (fileId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("fileId is required");
    }
    if (fileId != null) urlParams["fileId"] = fileId;
    if (includeDeleted != null) queryParams["includeDeleted"] = includeDeleted;
    if (replyId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("replyId is required");
    }
    if (replyId != null) urlParams["replyId"] = replyId;
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
    ..then((data) => completer.complete(new CommentReply.fromJson(data)));
    return completer.future;
  }

  /**
   * Creates a new reply to the given comment.
   *
   * [request] - CommentReply to send in this request
   *
   * [fileId] - The ID of the file.
   *
   * [commentId] - The ID of the comment.
   *
   * [optParams] - Additional query parameters
   */
  Future<CommentReply> insert(CommentReply request, String fileId, String commentId, {Map optParams}) {
    var completer = new Completer();
    var url = "files/{fileId}/comments/{commentId}/replies";
    var urlParams = new Map();
    var queryParams = new Map();

    var paramErrors = new StringBuffer();
    if (commentId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("commentId is required");
    }
    if (commentId != null) urlParams["commentId"] = commentId;
    if (fileId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("fileId is required");
    }
    if (fileId != null) urlParams["fileId"] = fileId;
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
    ..then((data) => completer.complete(new CommentReply.fromJson(data)));
    return completer.future;
  }

  /**
   * Lists all of the replies to a comment.
   *
   * [fileId] - The ID of the file.
   *
   * [commentId] - The ID of the comment.
   *
   * [includeDeleted] - If set, all replies, including deleted replies (with content stripped) will be returned.
   *   Default: false
   *
   * [maxResults] - The maximum number of replies to include in the response, used for paging.
   *   Default: 20
   *   Minimum: 0
   *   Maximum: 100
   *
   * [pageToken] - The continuation token, used to page through large result sets. To get the next page of results, set this parameter to the value of "nextPageToken" from the previous response.
   *
   * [optParams] - Additional query parameters
   */
  Future<CommentReplyList> list(String fileId, String commentId, {bool includeDeleted, int maxResults, String pageToken, Map optParams}) {
    var completer = new Completer();
    var url = "files/{fileId}/comments/{commentId}/replies";
    var urlParams = new Map();
    var queryParams = new Map();

    var paramErrors = new StringBuffer();
    if (commentId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("commentId is required");
    }
    if (commentId != null) urlParams["commentId"] = commentId;
    if (fileId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("fileId is required");
    }
    if (fileId != null) urlParams["fileId"] = fileId;
    if (includeDeleted != null) queryParams["includeDeleted"] = includeDeleted;
    if (maxResults != null) queryParams["maxResults"] = maxResults;
    if (pageToken != null) queryParams["pageToken"] = pageToken;
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
    ..then((data) => completer.complete(new CommentReplyList.fromJson(data)));
    return completer.future;
  }

  /**
   * Updates an existing reply. This method supports patch semantics.
   *
   * [request] - CommentReply to send in this request
   *
   * [fileId] - The ID of the file.
   *
   * [commentId] - The ID of the comment.
   *
   * [replyId] - The ID of the reply.
   *
   * [optParams] - Additional query parameters
   */
  Future<CommentReply> patch(CommentReply request, String fileId, String commentId, String replyId, {Map optParams}) {
    var completer = new Completer();
    var url = "files/{fileId}/comments/{commentId}/replies/{replyId}";
    var urlParams = new Map();
    var queryParams = new Map();

    var paramErrors = new StringBuffer();
    if (commentId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("commentId is required");
    }
    if (commentId != null) urlParams["commentId"] = commentId;
    if (fileId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("fileId is required");
    }
    if (fileId != null) urlParams["fileId"] = fileId;
    if (replyId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("replyId is required");
    }
    if (replyId != null) urlParams["replyId"] = replyId;
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
    response = _client._request(url, "PATCH", body: request.toString(), urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(new CommentReply.fromJson(data)));
    return completer.future;
  }

  /**
   * Updates an existing reply.
   *
   * [request] - CommentReply to send in this request
   *
   * [fileId] - The ID of the file.
   *
   * [commentId] - The ID of the comment.
   *
   * [replyId] - The ID of the reply.
   *
   * [optParams] - Additional query parameters
   */
  Future<CommentReply> update(CommentReply request, String fileId, String commentId, String replyId, {Map optParams}) {
    var completer = new Completer();
    var url = "files/{fileId}/comments/{commentId}/replies/{replyId}";
    var urlParams = new Map();
    var queryParams = new Map();

    var paramErrors = new StringBuffer();
    if (commentId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("commentId is required");
    }
    if (commentId != null) urlParams["commentId"] = commentId;
    if (fileId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("fileId is required");
    }
    if (fileId != null) urlParams["fileId"] = fileId;
    if (replyId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("replyId is required");
    }
    if (replyId != null) urlParams["replyId"] = replyId;
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

  /**
   * Removes a revision.
   *
   * [fileId] - The ID of the file.
   *
   * [revisionId] - The ID of the revision.
   *
   * [optParams] - Additional query parameters
   */
  Future<Map> delete(String fileId, String revisionId, {Map optParams}) {
    var completer = new Completer();
    var url = "files/{fileId}/revisions/{revisionId}";
    var urlParams = new Map();
    var queryParams = new Map();

    var paramErrors = new StringBuffer();
    if (fileId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("fileId is required");
    }
    if (fileId != null) urlParams["fileId"] = fileId;
    if (revisionId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("revisionId is required");
    }
    if (revisionId != null) urlParams["revisionId"] = revisionId;
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
    response = _client._request(url, "DELETE", urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(data));
    return completer.future;
  }

  /**
   * Gets a specific revision.
   *
   * [fileId] - The ID of the file.
   *
   * [revisionId] - The ID of the revision.
   *
   * [optParams] - Additional query parameters
   */
  Future<Revision> get(String fileId, String revisionId, {Map optParams}) {
    var completer = new Completer();
    var url = "files/{fileId}/revisions/{revisionId}";
    var urlParams = new Map();
    var queryParams = new Map();

    var paramErrors = new StringBuffer();
    if (fileId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("fileId is required");
    }
    if (fileId != null) urlParams["fileId"] = fileId;
    if (revisionId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("revisionId is required");
    }
    if (revisionId != null) urlParams["revisionId"] = revisionId;
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
    ..then((data) => completer.complete(new Revision.fromJson(data)));
    return completer.future;
  }

  /**
   * Lists a file's revisions.
   *
   * [fileId] - The ID of the file.
   *
   * [optParams] - Additional query parameters
   */
  Future<RevisionList> list(String fileId, {Map optParams}) {
    var completer = new Completer();
    var url = "files/{fileId}/revisions";
    var urlParams = new Map();
    var queryParams = new Map();

    var paramErrors = new StringBuffer();
    if (fileId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("fileId is required");
    }
    if (fileId != null) urlParams["fileId"] = fileId;
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
    ..then((data) => completer.complete(new RevisionList.fromJson(data)));
    return completer.future;
  }

  /**
   * Updates a revision. This method supports patch semantics.
   *
   * [request] - Revision to send in this request
   *
   * [fileId] - The ID for the file.
   *
   * [revisionId] - The ID for the revision.
   *
   * [optParams] - Additional query parameters
   */
  Future<Revision> patch(Revision request, String fileId, String revisionId, {Map optParams}) {
    var completer = new Completer();
    var url = "files/{fileId}/revisions/{revisionId}";
    var urlParams = new Map();
    var queryParams = new Map();

    var paramErrors = new StringBuffer();
    if (fileId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("fileId is required");
    }
    if (fileId != null) urlParams["fileId"] = fileId;
    if (revisionId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("revisionId is required");
    }
    if (revisionId != null) urlParams["revisionId"] = revisionId;
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
    response = _client._request(url, "PATCH", body: request.toString(), urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(new Revision.fromJson(data)));
    return completer.future;
  }

  /**
   * Updates a revision.
   *
   * [request] - Revision to send in this request
   *
   * [fileId] - The ID for the file.
   *
   * [revisionId] - The ID for the revision.
   *
   * [optParams] - Additional query parameters
   */
  Future<Revision> update(Revision request, String fileId, String revisionId, {Map optParams}) {
    var completer = new Completer();
    var url = "files/{fileId}/revisions/{revisionId}";
    var urlParams = new Map();
    var queryParams = new Map();

    var paramErrors = new StringBuffer();
    if (fileId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("fileId is required");
    }
    if (fileId != null) urlParams["fileId"] = fileId;
    if (revisionId == null) {
      if (!paramErrors.isEmpty) paramErrors.add(" / ");
      paramErrors.add("revisionId is required");
    }
    if (revisionId != null) urlParams["revisionId"] = revisionId;
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
    response = _client._request(url, "PUT", body: request.toString(), urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(new Revision.fromJson(data)));
    return completer.future;
  }
}

