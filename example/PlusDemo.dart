import "dart:html";
import "package:plus_v1_api_client/plus.dart";

String formatJson(Map data) {
  var html = new StringBuffer();
  html.add("<dl>");
  data.forEach((key, value) {
    html.add("<dt>$key:</dt><dd>");
    if (value is Map) {
      html.add(formatJson(value));
    } else if (value is List) {
      html.add("<dl>");
      for (var i = 0; i < value.length; i++) {
        html.add("<dt>$i:</dt><dd>");
        html.add(formatJson(value[i]));
        html.add("</dd>");
      }
      html.add("</dl>");
    } else {
      html.add("${value.toString().replaceAll("<", "&lt;").replaceAll(">", "&gt;")}");
    }
    html.add("</dd>");
  });
  html.add("</dl>");
  return html.toString();
}

void main() {
  // use your own API Key from the API Console here
  var plus = new Plus("AIzaSyDxnNu9Dm3eGxnDD72EF02IjRvR5v_eMPc");
  var container = query("#text");
  
  plus.activities.list("+FoldedSoft", "public", {"maxResults": 10}).then((ActivityFeed data) {
    data.items.forEach((item) {
      container.appendHtml("<a href=\"${item.url}\">${item.published}</a> - ${item.title}<br>");  
    });
  });
}
