part of plus;

/** Client to access the plus v1 API */
/** The Google+ API enables developers to build on top of the Google+ platform. */
class Plus extends Client {


  ActivitiesResource _activities;
  ActivitiesResource get activities => _activities;
  CommentsResource _comments;
  CommentsResource get comments => _comments;
  PeopleResource _people;
  PeopleResource get people => _people;

  Plus([String apiKey, OAuth2 auth]) : super(apiKey, auth) {
    _baseUrl = "https://www.googleapis.com:443/plus/v1/";
    _rootUrl = "https://www.googleapis.com:443/";
    _activities = new ActivitiesResource._internal(this);
    _comments = new CommentsResource._internal(this);
    _people = new PeopleResource._internal(this);
  }
}
