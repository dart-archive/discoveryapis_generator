import "dart:html";
import "package:plus_v1_api_client/plus.dart";

void main() {
  // use your own API Key from the API Console here
  var plus = new Plus("AIzaSyDxnNu9Dm3eGxnDD72EF02IjRvR5v_eMPc");
  var container = query("#text");
  
  plus.activities.list("+FoldedSoft", "public", optParams: {"maxResults": 10}).then((ActivityFeed data) {
    data.items.forEach((item) {
      container.appendHtml("<a href=\"${item.url}\">${item.published}</a> - ${item.title}<br>");  
    });
  });
}
