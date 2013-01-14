part of plus_v1_api_client;

class ActivitiesResource extends Resource {

  ActivitiesResource._internal(Client client) : super(client) {
  }

  /**
   * Get an activity.
   *
   * [activityId] - The ID of the activity to get.
   *
   * [optParams] - Additional query parameters
   */
  Future<Activity> get(String activityId, {Map optParams}) {
    var completer = new Completer();
    var url = "activities/{activityId}";
    var urlParams = new Map();
    var queryParams = new Map();

    var paramErrors = new List();
    if (activityId == null) paramErrors.add("activityId is required");
    if (activityId != null) urlParams["activityId"] = activityId;
    if (optParams != null) {
      optParams.forEach((key, value) {
        if (value != null && queryParams[key] == null) {
          queryParams[key] = value;
        }
      });
    }

    if (!paramErrors.isEmpty) {
      completer.completeException(new ArgumentError(Strings.join(paramErrors, " / ")));
      return completer.future;
    }

    var response;
    response = _client._request(url, "GET", urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(new Activity.fromJson(data)));
    return completer.future;
  }

  /**
   * List all of the activities in the specified collection for a particular user.
   *
   * [userId] - The ID of the user to get activities for. The special value "me" can be used to indicate the authenticated user.
   *
   * [collection] - The collection of activities to list.
   *   Allowed values:
   *     public - All public activities created by the specified user.
   *
   * [maxResults] - The maximum number of activities to include in the response, which is used for paging. For any response, the actual number returned might be less than the specified maxResults.
   *   Default: 20
   *   Minimum: 1
   *   Maximum: 100
   *
   * [pageToken] - The continuation token, which is used to page through large result sets. To get the next page of results, set this parameter to the value of "nextPageToken" from the previous response.
   *
   * [optParams] - Additional query parameters
   */
  Future<ActivityFeed> list(String userId, String collection, {int maxResults, String pageToken, Map optParams}) {
    var completer = new Completer();
    var url = "people/{userId}/activities/{collection}";
    var urlParams = new Map();
    var queryParams = new Map();

    var paramErrors = new List();
    if (collection == null) paramErrors.add("collection is required");
    if (collection != null && !["public"].contains(collection)) {
      paramErrors.add("Allowed values for collection: public");
    }
    if (collection != null) urlParams["collection"] = collection;
    if (maxResults != null) queryParams["maxResults"] = maxResults;
    if (pageToken != null) queryParams["pageToken"] = pageToken;
    if (userId == null) paramErrors.add("userId is required");
    if (userId != null) urlParams["userId"] = userId;
    if (optParams != null) {
      optParams.forEach((key, value) {
        if (value != null && queryParams[key] == null) {
          queryParams[key] = value;
        }
      });
    }

    if (!paramErrors.isEmpty) {
      completer.completeException(new ArgumentError(Strings.join(paramErrors, " / ")));
      return completer.future;
    }

    var response;
    response = _client._request(url, "GET", urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(new ActivityFeed.fromJson(data)));
    return completer.future;
  }

  /**
   * Search public activities.
   *
   * [query] - Full-text search query string.
   *
   * [language] - Specify the preferred language to search with. See search language codes for available values.
   *   Default: en-US
   *
   * [maxResults] - The maximum number of activities to include in the response, which is used for paging. For any response, the actual number returned might be less than the specified maxResults.
   *   Default: 10
   *   Minimum: 1
   *   Maximum: 20
   *
   * [orderBy] - Specifies how to order search results.
   *   Default: recent
   *   Allowed values:
   *     best - Sort activities by relevance to the user, most relevant first.
   *     recent - Sort activities by published date, most recent first.
   *
   * [pageToken] - The continuation token, which is used to page through large result sets. To get the next page of results, set this parameter to the value of "nextPageToken" from the previous response. This token can be of any length.
   *
   * [optParams] - Additional query parameters
   */
  Future<ActivityFeed> search(String query, {String language, int maxResults, String orderBy, String pageToken, Map optParams}) {
    var completer = new Completer();
    var url = "activities";
    var urlParams = new Map();
    var queryParams = new Map();

    var paramErrors = new List();
    if (language != null) queryParams["language"] = language;
    if (maxResults != null) queryParams["maxResults"] = maxResults;
    if (orderBy != null && !["best", "recent"].contains(orderBy)) {
      paramErrors.add("Allowed values for orderBy: best, recent");
    }
    if (orderBy != null) queryParams["orderBy"] = orderBy;
    if (pageToken != null) queryParams["pageToken"] = pageToken;
    if (query == null) paramErrors.add("query is required");
    if (query != null) queryParams["query"] = query;
    if (optParams != null) {
      optParams.forEach((key, value) {
        if (value != null && queryParams[key] == null) {
          queryParams[key] = value;
        }
      });
    }

    if (!paramErrors.isEmpty) {
      completer.completeException(new ArgumentError(Strings.join(paramErrors, " / ")));
      return completer.future;
    }

    var response;
    response = _client._request(url, "GET", urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(new ActivityFeed.fromJson(data)));
    return completer.future;
  }
}

class CommentsResource extends Resource {

  CommentsResource._internal(Client client) : super(client) {
  }

  /**
   * Get a comment.
   *
   * [commentId] - The ID of the comment to get.
   *
   * [optParams] - Additional query parameters
   */
  Future<Comment> get(String commentId, {Map optParams}) {
    var completer = new Completer();
    var url = "comments/{commentId}";
    var urlParams = new Map();
    var queryParams = new Map();

    var paramErrors = new List();
    if (commentId == null) paramErrors.add("commentId is required");
    if (commentId != null) urlParams["commentId"] = commentId;
    if (optParams != null) {
      optParams.forEach((key, value) {
        if (value != null && queryParams[key] == null) {
          queryParams[key] = value;
        }
      });
    }

    if (!paramErrors.isEmpty) {
      completer.completeException(new ArgumentError(Strings.join(paramErrors, " / ")));
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
   * List all of the comments for an activity.
   *
   * [activityId] - The ID of the activity to get comments for.
   *
   * [maxResults] - The maximum number of comments to include in the response, which is used for paging. For any response, the actual number returned might be less than the specified maxResults.
   *   Default: 20
   *   Minimum: 0
   *   Maximum: 500
   *
   * [pageToken] - The continuation token, which is used to page through large result sets. To get the next page of results, set this parameter to the value of "nextPageToken" from the previous response.
   *
   * [sortOrder] - The order in which to sort the list of comments.
   *   Default: ascending
   *   Allowed values:
   *     ascending - Sort oldest comments first.
   *     descending - Sort newest comments first.
   *
   * [optParams] - Additional query parameters
   */
  Future<CommentFeed> list(String activityId, {int maxResults, String pageToken, String sortOrder, Map optParams}) {
    var completer = new Completer();
    var url = "activities/{activityId}/comments";
    var urlParams = new Map();
    var queryParams = new Map();

    var paramErrors = new List();
    if (activityId == null) paramErrors.add("activityId is required");
    if (activityId != null) urlParams["activityId"] = activityId;
    if (maxResults != null) queryParams["maxResults"] = maxResults;
    if (pageToken != null) queryParams["pageToken"] = pageToken;
    if (sortOrder != null && !["ascending", "descending"].contains(sortOrder)) {
      paramErrors.add("Allowed values for sortOrder: ascending, descending");
    }
    if (sortOrder != null) queryParams["sortOrder"] = sortOrder;
    if (optParams != null) {
      optParams.forEach((key, value) {
        if (value != null && queryParams[key] == null) {
          queryParams[key] = value;
        }
      });
    }

    if (!paramErrors.isEmpty) {
      completer.completeException(new ArgumentError(Strings.join(paramErrors, " / ")));
      return completer.future;
    }

    var response;
    response = _client._request(url, "GET", urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(new CommentFeed.fromJson(data)));
    return completer.future;
  }
}

class PeopleResource extends Resource {

  PeopleResource._internal(Client client) : super(client) {
  }

  /**
   * Get a person's profile.
   *
   * [userId] - The ID of the person to get the profile for. The special value "me" can be used to indicate the authenticated user.
   *
   * [optParams] - Additional query parameters
   */
  Future<Person> get(String userId, {Map optParams}) {
    var completer = new Completer();
    var url = "people/{userId}";
    var urlParams = new Map();
    var queryParams = new Map();

    var paramErrors = new List();
    if (userId == null) paramErrors.add("userId is required");
    if (userId != null) urlParams["userId"] = userId;
    if (optParams != null) {
      optParams.forEach((key, value) {
        if (value != null && queryParams[key] == null) {
          queryParams[key] = value;
        }
      });
    }

    if (!paramErrors.isEmpty) {
      completer.completeException(new ArgumentError(Strings.join(paramErrors, " / ")));
      return completer.future;
    }

    var response;
    response = _client._request(url, "GET", urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(new Person.fromJson(data)));
    return completer.future;
  }

  /**
   * List all of the people in the specified collection for a particular activity.
   *
   * [activityId] - The ID of the activity to get the list of people for.
   *
   * [collection] - The collection of people to list.
   *   Allowed values:
   *     plusoners - List all people who have +1'd this activity.
   *     resharers - List all people who have reshared this activity.
   *
   * [maxResults] - The maximum number of people to include in the response, which is used for paging. For any response, the actual number returned might be less than the specified maxResults.
   *   Default: 20
   *   Minimum: 1
   *   Maximum: 100
   *
   * [pageToken] - The continuation token, which is used to page through large result sets. To get the next page of results, set this parameter to the value of "nextPageToken" from the previous response.
   *
   * [optParams] - Additional query parameters
   */
  Future<PeopleFeed> listByActivity(String activityId, String collection, {int maxResults, String pageToken, Map optParams}) {
    var completer = new Completer();
    var url = "activities/{activityId}/people/{collection}";
    var urlParams = new Map();
    var queryParams = new Map();

    var paramErrors = new List();
    if (activityId == null) paramErrors.add("activityId is required");
    if (activityId != null) urlParams["activityId"] = activityId;
    if (collection == null) paramErrors.add("collection is required");
    if (collection != null && !["plusoners", "resharers"].contains(collection)) {
      paramErrors.add("Allowed values for collection: plusoners, resharers");
    }
    if (collection != null) urlParams["collection"] = collection;
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
      completer.completeException(new ArgumentError(Strings.join(paramErrors, " / ")));
      return completer.future;
    }

    var response;
    response = _client._request(url, "GET", urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(new PeopleFeed.fromJson(data)));
    return completer.future;
  }

  /**
   * Search all public profiles.
   *
   * [query] - Specify a query string for full text search of public text in all profiles.
   *
   * [language] - Specify the preferred language to search with. See search language codes for available values.
   *   Default: en-US
   *
   * [maxResults] - The maximum number of people to include in the response, which is used for paging. For any response, the actual number returned might be less than the specified maxResults.
   *   Default: 10
   *   Minimum: 1
   *   Maximum: 20
   *
   * [pageToken] - The continuation token, which is used to page through large result sets. To get the next page of results, set this parameter to the value of "nextPageToken" from the previous response. This token can be of any length.
   *
   * [optParams] - Additional query parameters
   */
  Future<PeopleFeed> search(String query, {String language, int maxResults, String pageToken, Map optParams}) {
    var completer = new Completer();
    var url = "people";
    var urlParams = new Map();
    var queryParams = new Map();

    var paramErrors = new List();
    if (language != null) queryParams["language"] = language;
    if (maxResults != null) queryParams["maxResults"] = maxResults;
    if (pageToken != null) queryParams["pageToken"] = pageToken;
    if (query == null) paramErrors.add("query is required");
    if (query != null) queryParams["query"] = query;
    if (optParams != null) {
      optParams.forEach((key, value) {
        if (value != null && queryParams[key] == null) {
          queryParams[key] = value;
        }
      });
    }

    if (!paramErrors.isEmpty) {
      completer.completeException(new ArgumentError(Strings.join(paramErrors, " / ")));
      return completer.future;
    }

    var response;
    response = _client._request(url, "GET", urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(new PeopleFeed.fromJson(data)));
    return completer.future;
  }
}

