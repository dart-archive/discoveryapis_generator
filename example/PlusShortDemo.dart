import "dart:html" as html;
import "package:plus_v1_api_client/plus.dart";
import "package:urlshortener_v1_api_client/urlshortener.dart";

void main() {
  // use your own API Key from the API Console here
  var plus = new Plus("AIzaSyDxnNu9Dm3eGxnDD72EF02IjRvR5v_eMPc");
  var shortener = new Urlshortener("AIzaSyDxnNu9Dm3eGxnDD72EF02IjRvR5v_eMPc");
  var container = html.query("#text");
  
  plus.activities.list("+FoldedSoft", "public", {"maxResults": 5}).then((ActivityFeed data) {
    data.items.forEach((item) {
      shortener.url.insert(new Url.fromJson({"longUrl": item.url})).then((url) {
        container.appendHtml("<a href=\"${url.id}\">${url.id}</a> ${item.published} - ${item.title}<br>");
      });
    });
  });
}
