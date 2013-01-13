part of plus_v1_api_client;

class ActivitiesResource extends Resource {

  ActivitiesResource._internal(Client client) : super(client) {
  }

  /**
   * Get an activity.
   *
   * [activityId] - The ID of the activity to get.
   */
  Future<Activity> get(String activityId) {
    var completer = new Completer();
    var url = "activities/{activityId}";
    var urlParams = new Map();
    var queryParams = new Map();

    if (?activityId && activityId != null) urlParams["activityId"] = activityId;
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
   */
  Future<ActivityFeed> list(String userId, String collection, {int maxResults, String pageToken}) {
    var completer = new Completer();
    var url = "people/{userId}/activities/{collection}";
    var urlParams = new Map();
    var queryParams = new Map();

    if (?collection && collection != null) urlParams["collection"] = collection;
    if (?maxResults && maxResults != null) queryParams["maxResults"] = maxResults;
    if (?pageToken && pageToken != null) queryParams["pageToken"] = pageToken;
    if (?userId && userId != null) urlParams["userId"] = userId;
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
   */
  Future<ActivityFeed> search(String query, {String language, int maxResults, String orderBy, String pageToken}) {
    var completer = new Completer();
    var url = "activities";
    var urlParams = new Map();
    var queryParams = new Map();

    if (?language && language != null) queryParams["language"] = language;
    if (?maxResults && maxResults != null) queryParams["maxResults"] = maxResults;
    if (?orderBy && orderBy != null) queryParams["orderBy"] = orderBy;
    if (?pageToken && pageToken != null) queryParams["pageToken"] = pageToken;
    if (?query && query != null) queryParams["query"] = query;
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
   */
  Future<Comment> get(String commentId) {
    var completer = new Completer();
    var url = "comments/{commentId}";
    var urlParams = new Map();
    var queryParams = new Map();

    if (?commentId && commentId != null) urlParams["commentId"] = commentId;
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
   */
  Future<CommentFeed> list(String activityId, {int maxResults, String pageToken, String sortOrder}) {
    var completer = new Completer();
    var url = "activities/{activityId}/comments";
    var urlParams = new Map();
    var queryParams = new Map();

    if (?activityId && activityId != null) urlParams["activityId"] = activityId;
    if (?maxResults && maxResults != null) queryParams["maxResults"] = maxResults;
    if (?pageToken && pageToken != null) queryParams["pageToken"] = pageToken;
    if (?sortOrder && sortOrder != null) queryParams["sortOrder"] = sortOrder;
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
   */
  Future<Person> get(String userId) {
    var completer = new Completer();
    var url = "people/{userId}";
    var urlParams = new Map();
    var queryParams = new Map();

    if (?userId && userId != null) urlParams["userId"] = userId;
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
   */
  Future<PeopleFeed> listByActivity(String activityId, String collection, {int maxResults, String pageToken}) {
    var completer = new Completer();
    var url = "activities/{activityId}/people/{collection}";
    var urlParams = new Map();
    var queryParams = new Map();

    if (?activityId && activityId != null) urlParams["activityId"] = activityId;
    if (?collection && collection != null) urlParams["collection"] = collection;
    if (?maxResults && maxResults != null) queryParams["maxResults"] = maxResults;
    if (?pageToken && pageToken != null) queryParams["pageToken"] = pageToken;
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
   */
  Future<PeopleFeed> search(String query, {String language, int maxResults, String pageToken}) {
    var completer = new Completer();
    var url = "people";
    var urlParams = new Map();
    var queryParams = new Map();

    if (?language && language != null) queryParams["language"] = language;
    if (?maxResults && maxResults != null) queryParams["maxResults"] = maxResults;
    if (?pageToken && pageToken != null) queryParams["pageToken"] = pageToken;
    if (?query && query != null) queryParams["query"] = query;
    var response;
    response = _client._request(url, "GET", urlParams: urlParams, queryParams: queryParams);
    response
    ..handleException((e) { completer.completeException(e); return true; })
    ..then((data) => completer.complete(new PeopleFeed.fromJson(data)));
    return completer.future;
  }
}

