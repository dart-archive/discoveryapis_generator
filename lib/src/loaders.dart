part of discovery_api_client_generator;

// Workaround for Cloud Endpoints because they don't respond to requests from HttpClient
Future<String> loadCustomUrl(String url) {
  var completer = new Completer();
  Process.run("curl", ["-k", url]).then((p) {
    completer.complete(p.stdout);
  });

  return completer.future;
}

Future<String> loadDocumentFromUrl(String url) {
  var completer = new Completer();
  var client = new HttpClient();

  Future<HttpClientRequest> connection = client.getUrl(Uri.parse(url));
  var result = new StringBuffer();

  connection.then((request){
    request.done.then((response){
      response.listen((data){
        result.write(new String.fromCharCodes(data));
      }, onDone:(){
        client.close();
        completer.complete(result.toString());
      });
    });
    request.close();
  }, onError:(error)=> completer.complete("Unexpected error: $error"));

  return completer.future;
}

Future<String> loadDocumentFromGoogle(String api, String version) {
  final url = "https://www.googleapis.com/discovery/v1/apis/${encodeUriComponent(api)}/${encodeUriComponent(version)}/rest";
  return loadDocumentFromUrl(url);
}

Future<String> loadDocumentFromFile(String fileName) {
  final file = new File(fileName);
  return file.readAsString();
}

Future<Map> loadGoogleAPIList() {
  var completer = new Completer();
  final url = "https://www.googleapis.com/discovery/v1/apis";
  loadDocumentFromUrl(url)
    .then((data) {
      var apis = JSON.parse(data);
      completer.complete(apis);
    })
    .catchError((e) => completer.completeError(e));
  return completer.future;
}