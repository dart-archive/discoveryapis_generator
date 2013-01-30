part of discovery_api_client_generator;

String fileDate(Date date) => "${date.year}${(date.month < 10) ? 0 : ""}${date.month}${(date.day < 10) ? 0 : ""}${date.day}_${(date.hour < 10) ? 0 : ""}${date.hour}${(date.minute < 10) ? 0 : ""}${date.minute}${(date.second < 10) ? 0 : ""}${date.second}";
String capitalize(String string) => "${string.substring(0,1).toUpperCase()}${string.substring(1)}";
String cleanName(String name) => name.replaceAll(new RegExp(r"(\W)"), "_");

const Map parameterType = const {
  "string": "String",
  "number": "num",
  "integer": "int",
  "boolean": "bool"
};

String createLicense() {
  return """
Copyright (c) 2013 Gerwin Sturm & Adam Singer

Licensed under the Apache License, Version 2.0 (the "License"); you may not
use this file except in compliance with the License. You may obtain a copy of
the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
License for the specific language governing permissions and limitations under
the License

------------------------
Based on http://code.google.com/p/google-api-dart-client

Copyright 2012 Google Inc.
Licensed under the Apache License, Version 2.0 (the "License"); you may not
use this file except in compliance with the License. You may obtain a copy of
the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
License for the specific language governing permissions and limitations under
the License

""";
}

String createContributors() {
  return """
Adam Singer (https://github.com/financeCoding)
Gerwin Sturm (https://github.com/Scarygami, http://scarygami.net/+)
""";
}

String createGitIgnore() {
  return """
packages/
pubspec.lock
""";
}

void createFullClient(Map apis, String outputDirectory) {

  String fullLibraryName = "api_client";

  String createFullPubspec() {
    return """
name: $fullLibraryName
version: $clientVersion.0
description: Auto-generated client library for accessing Google APIs
homepage: https://github.com/dart-gde/discovery_api_dart_client_generator
authors:
- Gerwin Sturm <scarygami@gmail.com>
- Adam Singer <financeCoding@gmail.com>

dependencies:
  js: '>=0.0.14'
  google_oauth2_client: '>=0.2.1'

""";
  }

  String createFullReadme() {
    var tmp = new StringBuffer();
    tmp.add("""
# $fullLibraryName

### Description

Auto-generated client library for accessing the Google APIs.

Examples for how to use these libraries can be found here: https://github.com/dart-gde/dart_api_client_examples

### Supported APIs

""");

    apis["items"].forEach((item) {
      var name = item["name"];
      var version = item["version"];
      var title = item["title"];
      var link = item["documentationLink"];
      var description = item["description"];

      var libraryBrowserName = cleanName("${name}_${version}_api_browser");
      var libraryConsoleName = cleanName("${name}_${version}_api_console");

      tmp.add("#### ");
      if (item.containsKey("icons") && item["icons"].containsKey("x16")) {
        tmp.add("![Logo](${item["icons"]["x16"]}) ");
      }
      tmp.add("$title - $name $version\n\n");
      tmp.add("$description\n\n");
      if (link != null) {
        tmp.add("[Official API Documentation]($link)\n\n");
      }
      tmp.add("For web applications:\n```\nimport \"package:api_client/$libraryBrowserName.dart\" as ${cleanName(name).toLowerCase()}client;\n```\n\n");
      tmp.add("For console application:\n```\nimport \"package:api_client/$libraryConsoleName.dart\" as ${cleanName(name).toLowerCase()}client;\n```\n\n");

      tmp.add("```\nvar ${cleanName(name).toLowerCase()} = new ${cleanName(name).toLowerCase()}client.${capitalize(name)}();\n```\n");

      tmp.add("\n");
    });

    tmp.add("### Licenses\n\n```\n");
    tmp.add(createLicense());
    tmp.add("```\n");
    return tmp.toString();
  };

  (new Directory("$outputDirectory/lib/src")).createSync(recursive: true);

  (new File("$outputDirectory/pubspec.yaml")).writeAsStringSync(createFullPubspec());
  (new File("$outputDirectory/README.md")).writeAsStringSync(createFullReadme());
  (new File("$outputDirectory/LICENSE")).writeAsStringSync(createLicense());
  (new File("$outputDirectory/CONTRIBUTORS")).writeAsStringSync(createContributors());
  (new File("$outputDirectory/.gitignore")).writeAsStringSync(createGitIgnore());

  apis["items"].forEach((item) {
    loadDocumentFromUrl(item["discoveryRestUrl"]).then((doc) {
      var generator = new Generator(doc);
      generator.generateClient(outputDirectory, fullLibrary: true);
    });
  });
}

void createAPIList(Map apis, String outputDirectory) {
  (new Directory("$outputDirectory")).createSync(recursive: true);
  /*var tmp = new StringBuffer();
  
  apis["items"].forEach((item) {
    var name = item["name"];
    var version = item["version"];
    tmp.add(name);
    tmp.add(" ");
    tmp.add(version);
    tmp.add(" ");
    tmp.add(cleanName("dart_${name}_${version}_api_client"));
    tmp.add("\n");
  });
  (new File("$outputDirectory/APIS")).writeAsStringSync(tmp.toString());*/
  
  var data = new Map();
  data["apis"] = new List();
  apis["items"].forEach((item) {
    var api = new Map();
    api["name"] = item["name"];
    api["version"] = item["version"];
    api["gitname"] = cleanName("dart_${item["name"]}_${item["version"]}_api_client");
    data["apis"].add(api);
  });
  (new File("$outputDirectory/APIS")).writeAsStringSync(JSON.stringify(data));
}

Future<String> loadDocumentFromUrl(String url) {
  var completer = new Completer();
  var client = new HttpClient();
  var connection = client.getUrl(Uri.parse(url));
  var result = new StringBuffer();

  connection.onError = (error) => completer.complete("Unexpected error: $error");

  connection.onRequest = (HttpClientRequest request) {
    request.outputStream.close();
  };

  connection.onResponse = (HttpClientResponse response) {
    response.inputStream.onData = () {
      result.add(new String.fromCharCodes(response.inputStream.read()));
    };
    response.inputStream.onClosed = () {
      client.shutdown();
      completer.complete(result.toString());
    };
  };

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