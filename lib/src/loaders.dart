part of discovery_api_client_generator;

const _discoveryUrl = "https://www.googleapis.com/discovery/v1/apis";

// Workaround for Cloud Endpoints because they don't respond to requests from HttpClient
Future<String> loadCustomUrl(String url) {
  return Process.run("curl", ["-k", url]).then((p) => p.stdout);
}

Future<String> loadDocumentFromUrl(String url) {
  var client = new HttpClient();

  return client.getUrl(Uri.parse(url))
      .then((HttpClientRequest request) => request.close())
      .then((HttpClientResponse response) {
        return response
          .transform(new StringDecoder(Encoding.UTF_8))
          .fold(new StringBuffer(), (buffer, data) => buffer..write(data));
      })
      .then((StringBuffer buffer) => buffer.toString())
      .whenComplete(() {
        client.close();
      });
}

Future<String> loadDocumentFromGoogle(String api, String version) {
  final url = "$_discoveryUrl/${Uri.encodeComponent(api)}/${Uri.encodeComponent(version)}/rest";
  return loadDocumentFromUrl(url);
}

Future<String> loadDocumentFromFile(String fileName) {
  final file = new File(fileName);
  return file.readAsString();
}

Future<Map> loadGoogleAPIList() => loadDocumentFromUrl(_discoveryUrl)
  .then((data) => JSON.parse(data));
