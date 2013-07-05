part of discovery_api_client_generator;

// Workaround for Cloud Endpoints because they don't respond to requests from HttpClient
Future<String> loadCustomUrl(String url) {
  return Process.run("curl", ["-k", url]).then((p) => p.stdout);
}

Future<String> loadDocumentFromUrl(String url) {
  var client = new HttpClient();

  return client.getUrl(Uri.parse(url))
      .then((HttpClientRequest request) => request.close())
      .then((HttpClientResponse response) {
        var result = new StringBuffer();

        return response
            .forEach((List<int> data) {
              result.write(new String.fromCharCodes(data));
            })
            .then((_) => result.toString());
      })
      .whenComplete(() {
        client.close();
      });
}

Future<String> loadDocumentFromGoogle(String api, String version) {
  final url = "https://www.googleapis.com/discovery/v1/apis/${Uri.encodeComponent(api)}/${Uri.encodeComponent(version)}/rest";
  return loadDocumentFromUrl(url);
}

Future<String> loadDocumentFromFile(String fileName) {
  final file = new File(fileName);
  return file.readAsString();
}

Future<Map> loadGoogleAPIList() {
  final url = "https://www.googleapis.com/discovery/v1/apis";
  return loadDocumentFromUrl(url)
    .then((data) => JSON.parse(data));
}
