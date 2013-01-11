import "dart:html";
import "package:plus_v1_api_client/plus.dart";
import "package:urlshortener_v1_api_client/urlshortener.dart" as urllib;

void main() {
  // use your own API Key from the API Console here
  var plus = new Plus("AIzaSyDxnNu9Dm3eGxnDD72EF02IjRvR5v_eMPc");
  var shortener = new urllib.Urlshortener("AIzaSyDxnNu9Dm3eGxnDD72EF02IjRvR5v_eMPc");
  var container = query("#text");
  
  plus.activities.list("+FoldedSoft", "public", optParams: {"maxResults": 5}).then((ActivityFeed data) {
    data.items.forEach((item) {
      shortener.url.insert(new urllib.Url.fromJson({"longUrl": item.url})).then((url) {
        container.appendHtml("<a href=\"${url.id}\">${url.id}</a> ${item.published} - ${item.title}<br>");
      });
    });
  });
}
