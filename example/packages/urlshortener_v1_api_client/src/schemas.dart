part of urlshortener_v1_api_client;

class AnalyticsSnapshot {

  /** Top browsers, e.g. "Chrome"; sorted by (descending) click counts. Only present if this data is available. */
  List<StringCount> browsers;

  /** Top countries (expressed as country codes), e.g. "US" or "DE"; sorted by (descending) click counts. Only present if this data is available. */
  List<StringCount> countries;

  /** Number of clicks on all goo.gl short URLs pointing to this long URL. */
  String longUrlClicks;

  /** Top platforms or OSes, e.g. "Windows"; sorted by (descending) click counts. Only present if this data is available. */
  List<StringCount> platforms;

  /** Top referring hosts, e.g. "www.google.com"; sorted by (descending) click counts. Only present if this data is available. */
  List<StringCount> referrers;

  /** Number of clicks on this short URL. */
  String shortUrlClicks;

  /** Create new AnalyticsSnapshot from JSON data */
  AnalyticsSnapshot.fromJson(Map json) {
    if (json.containsKey("browsers")) {
      browsers = [];
      json["browsers"].forEach((item) {
        browsers.add(new StringCount.fromJson(item));
      });
    }
    if (json.containsKey("countries")) {
      countries = [];
      json["countries"].forEach((item) {
        countries.add(new StringCount.fromJson(item));
      });
    }
    if (json.containsKey("longUrlClicks")) {
      longUrlClicks = json["longUrlClicks"];
    }
    if (json.containsKey("platforms")) {
      platforms = [];
      json["platforms"].forEach((item) {
        platforms.add(new StringCount.fromJson(item));
      });
    }
    if (json.containsKey("referrers")) {
      referrers = [];
      json["referrers"].forEach((item) {
        referrers.add(new StringCount.fromJson(item));
      });
    }
    if (json.containsKey("shortUrlClicks")) {
      shortUrlClicks = json["shortUrlClicks"];
    }
  }

  /** Create JSON Object for AnalyticsSnapshot */
  Map toJson() {
    var output = new Map();

    if (browsers != null) {
      output["browsers"] = new List();
      browsers.forEach((item) {
        output["browsers"].add(item.toJson());
      });
    }
    if (countries != null) {
      output["countries"] = new List();
      countries.forEach((item) {
        output["countries"].add(item.toJson());
      });
    }
    if (longUrlClicks != null) {
      output["longUrlClicks"] = longUrlClicks;
    }
    if (platforms != null) {
      output["platforms"] = new List();
      platforms.forEach((item) {
        output["platforms"].add(item.toJson());
      });
    }
    if (referrers != null) {
      output["referrers"] = new List();
      referrers.forEach((item) {
        output["referrers"].add(item.toJson());
      });
    }
    if (shortUrlClicks != null) {
      output["shortUrlClicks"] = shortUrlClicks;
    }

    return output;
  }

  /** Return String representation of AnalyticsSnapshot */
  String toString() => JSON.stringify(this.toJson());

}

class AnalyticsSummary {

  /** Click analytics over all time. */
  AnalyticsSnapshot allTime;

  /** Click analytics over the last day. */
  AnalyticsSnapshot day;

  /** Click analytics over the last month. */
  AnalyticsSnapshot month;

  /** Click analytics over the last two hours. */
  AnalyticsSnapshot twoHours;

  /** Click analytics over the last week. */
  AnalyticsSnapshot week;

  /** Create new AnalyticsSummary from JSON data */
  AnalyticsSummary.fromJson(Map json) {
    if (json.containsKey("allTime")) {
      allTime = new AnalyticsSnapshot.fromJson(json["allTime"]);
    }
    if (json.containsKey("day")) {
      day = new AnalyticsSnapshot.fromJson(json["day"]);
    }
    if (json.containsKey("month")) {
      month = new AnalyticsSnapshot.fromJson(json["month"]);
    }
    if (json.containsKey("twoHours")) {
      twoHours = new AnalyticsSnapshot.fromJson(json["twoHours"]);
    }
    if (json.containsKey("week")) {
      week = new AnalyticsSnapshot.fromJson(json["week"]);
    }
  }

  /** Create JSON Object for AnalyticsSummary */
  Map toJson() {
    var output = new Map();

    if (allTime != null) {
      output["allTime"] = allTime.toJson();
    }
    if (day != null) {
      output["day"] = day.toJson();
    }
    if (month != null) {
      output["month"] = month.toJson();
    }
    if (twoHours != null) {
      output["twoHours"] = twoHours.toJson();
    }
    if (week != null) {
      output["week"] = week.toJson();
    }

    return output;
  }

  /** Return String representation of AnalyticsSummary */
  String toString() => JSON.stringify(this.toJson());

}

class StringCount {

  /** Number of clicks for this top entry, e.g. for this particular country or browser. */
  String count;

  /** Label assigned to this top entry, e.g. "US" or "Chrome". */
  String id;

  /** Create new StringCount from JSON data */
  StringCount.fromJson(Map json) {
    if (json.containsKey("count")) {
      count = json["count"];
    }
    if (json.containsKey("id")) {
      id = json["id"];
    }
  }

  /** Create JSON Object for StringCount */
  Map toJson() {
    var output = new Map();

    if (count != null) {
      output["count"] = count;
    }
    if (id != null) {
      output["id"] = id;
    }

    return output;
  }

  /** Return String representation of StringCount */
  String toString() => JSON.stringify(this.toJson());

}

class Url {

  /** A summary of the click analytics for the short and long URL. Might not be present if not requested or currently unavailable. */
  AnalyticsSummary analytics;

  /** Time the short URL was created; ISO 8601 representation using the yyyy-MM-dd'T'HH:mm:ss.SSSZZ format, e.g. "2010-10-14T19:01:24.944+00:00". */
  String created;

  /** Short URL, e.g. "http://goo.gl/l6MS". */
  String id;

  /** The fixed string "urlshortener#url". */
  String kind;

  /** Long URL, e.g. "http://www.google.com/". Might not be present if the status is "REMOVED". */
  String longUrl;

  /** Status of the target URL. Possible values: "OK", "MALWARE", "PHISHING", or "REMOVED". A URL might be marked "REMOVED" if it was flagged as spam, for example. */
  String status;

  /** Create new Url from JSON data */
  Url.fromJson(Map json) {
    if (json.containsKey("analytics")) {
      analytics = new AnalyticsSummary.fromJson(json["analytics"]);
    }
    if (json.containsKey("created")) {
      created = json["created"];
    }
    if (json.containsKey("id")) {
      id = json["id"];
    }
    if (json.containsKey("kind")) {
      kind = json["kind"];
    }
    if (json.containsKey("longUrl")) {
      longUrl = json["longUrl"];
    }
    if (json.containsKey("status")) {
      status = json["status"];
    }
  }

  /** Create JSON Object for Url */
  Map toJson() {
    var output = new Map();

    if (analytics != null) {
      output["analytics"] = analytics.toJson();
    }
    if (created != null) {
      output["created"] = created;
    }
    if (id != null) {
      output["id"] = id;
    }
    if (kind != null) {
      output["kind"] = kind;
    }
    if (longUrl != null) {
      output["longUrl"] = longUrl;
    }
    if (status != null) {
      output["status"] = status;
    }

    return output;
  }

  /** Return String representation of Url */
  String toString() => JSON.stringify(this.toJson());

}

class UrlHistory {

  /** A list of URL resources. */
  List<Url> items;

  /** Number of items returned with each full "page" of results. Note that the last page could have fewer items than the "itemsPerPage" value. */
  int itemsPerPage;

  /** The fixed string "urlshortener#urlHistory". */
  String kind;

  /** A token to provide to get the next page of results. */
  String nextPageToken;

  /** Total number of short URLs associated with this user (may be approximate). */
  int totalItems;

  /** Create new UrlHistory from JSON data */
  UrlHistory.fromJson(Map json) {
    if (json.containsKey("items")) {
      items = [];
      json["items"].forEach((item) {
        items.add(new Url.fromJson(item));
      });
    }
    if (json.containsKey("itemsPerPage")) {
      itemsPerPage = json["itemsPerPage"];
    }
    if (json.containsKey("kind")) {
      kind = json["kind"];
    }
    if (json.containsKey("nextPageToken")) {
      nextPageToken = json["nextPageToken"];
    }
    if (json.containsKey("totalItems")) {
      totalItems = json["totalItems"];
    }
  }

  /** Create JSON Object for UrlHistory */
  Map toJson() {
    var output = new Map();

    if (items != null) {
      output["items"] = new List();
      items.forEach((item) {
        output["items"].add(item.toJson());
      });
    }
    if (itemsPerPage != null) {
      output["itemsPerPage"] = itemsPerPage;
    }
    if (kind != null) {
      output["kind"] = kind;
    }
    if (nextPageToken != null) {
      output["nextPageToken"] = nextPageToken;
    }
    if (totalItems != null) {
      output["totalItems"] = totalItems;
    }

    return output;
  }

  /** Return String representation of UrlHistory */
  String toString() => JSON.stringify(this.toJson());

}

