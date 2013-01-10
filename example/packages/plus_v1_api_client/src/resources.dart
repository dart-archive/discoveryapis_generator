part of plus;

class ActivitiesResource extends Resource {

  ActivitiesResource._internal(Client client) : super(client) {
  }

  /** Get an activity. */
  Future<Activity> get(String activityId, [Map optParams]) {
    var completer = new Completer();
    var url = "${_client._baseUrl}activities/{activityId}";
    var urlParams = new Map();
    if (optParams == null) optParams = new Map();

    urlParams["activityId"] = activityId;

    _client._getRequest(url, urlParams, optParams).then((data) {
      completer.complete(new Activity.fromJson(data));
    });

    return completer.future;
  }

  /** List all of the activities in the specified collection for a particular user. */
  Future<ActivityFeed> list(String userId, String collection, [Map optParams]) {
    var completer = new Completer();
    var url = "${_client._baseUrl}people/{userId}/activities/{collection}";
    var urlParams = new Map();
    if (optParams == null) optParams = new Map();

    urlParams["userId"] = userId;
    urlParams["collection"] = collection;

    _client._getRequest(url, urlParams, optParams).then((data) {
      completer.complete(new ActivityFeed.fromJson(data));
    });

    return completer.future;
  }

  /** Search public activities. */
  Future<ActivityFeed> search(String query, [Map optParams]) {
    var completer = new Completer();
    var url = "${_client._baseUrl}activities";
    var urlParams = new Map();
    if (optParams == null) optParams = new Map();

    optParams["query"] = query;

    _client._getRequest(url, urlParams, optParams).then((data) {
      completer.complete(new ActivityFeed.fromJson(data));
    });

    return completer.future;
  }
}

class CommentsResource extends Resource {

  CommentsResource._internal(Client client) : super(client) {
  }

  /** Get a comment. */
  Future<Comment> get(String commentId, [Map optParams]) {
    var completer = new Completer();
    var url = "${_client._baseUrl}comments/{commentId}";
    var urlParams = new Map();
    if (optParams == null) optParams = new Map();

    urlParams["commentId"] = commentId;

    _client._getRequest(url, urlParams, optParams).then((data) {
      completer.complete(new Comment.fromJson(data));
    });

    return completer.future;
  }

  /** List all of the comments for an activity. */
  Future<CommentFeed> list(String activityId, [Map optParams]) {
    var completer = new Completer();
    var url = "${_client._baseUrl}activities/{activityId}/comments";
    var urlParams = new Map();
    if (optParams == null) optParams = new Map();

    urlParams["activityId"] = activityId;

    _client._getRequest(url, urlParams, optParams).then((data) {
      completer.complete(new CommentFeed.fromJson(data));
    });

    return completer.future;
  }
}

class PeopleResource extends Resource {

  PeopleResource._internal(Client client) : super(client) {
  }

  /** Get a person's profile. */
  Future<Person> get(String userId, [Map optParams]) {
    var completer = new Completer();
    var url = "${_client._baseUrl}people/{userId}";
    var urlParams = new Map();
    if (optParams == null) optParams = new Map();

    urlParams["userId"] = userId;

    _client._getRequest(url, urlParams, optParams).then((data) {
      completer.complete(new Person.fromJson(data));
    });

    return completer.future;
  }

  /** List all of the people in the specified collection for a particular activity. */
  Future<PeopleFeed> listByActivity(String activityId, String collection, [Map optParams]) {
    var completer = new Completer();
    var url = "${_client._baseUrl}activities/{activityId}/people/{collection}";
    var urlParams = new Map();
    if (optParams == null) optParams = new Map();

    urlParams["activityId"] = activityId;
    urlParams["collection"] = collection;

    _client._getRequest(url, urlParams, optParams).then((data) {
      completer.complete(new PeopleFeed.fromJson(data));
    });

    return completer.future;
  }

  /** Search all public profiles. */
  Future<PeopleFeed> search(String query, [Map optParams]) {
    var completer = new Completer();
    var url = "${_client._baseUrl}people";
    var urlParams = new Map();
    if (optParams == null) optParams = new Map();

    optParams["query"] = query;

    _client._getRequest(url, urlParams, optParams).then((data) {
      completer.complete(new PeopleFeed.fromJson(data));
    });

    return completer.future;
  }
}

