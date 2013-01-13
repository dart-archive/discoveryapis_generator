part of plus_v1_api_client;

class ActivitiesResource extends Resource {

  ActivitiesResource._internal(Client client) : super(client) {
  }

  /** Get an activity. */
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

  /** List all of the activities in the specified collection for a particular user. */
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

  /** Search public activities. */
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

  /** Get a comment. */
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

  /** List all of the comments for an activity. */
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

  /** Get a person's profile. */
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

  /** List all of the people in the specified collection for a particular activity. */
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

  /** Search all public profiles. */
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

