import "dart:io";
import "dart:uri";
import "dart:json";
import "package:args/args.dart";

String fileDate(Date date) => "${date.year}${(date.month < 10) ? 0 : ""}${date.month}${(date.day < 10) ? 0 : ""}${date.day}_${(date.hour < 10) ? 0 : ""}${date.hour}${(date.minute < 10) ? 0 : ""}${date.minute}${(date.second < 10) ? 0 : ""}${date.second}";
String capitalize(String string) => "${string.substring(0,1).toUpperCase()}${string.substring(1)}";

class Generator {
  String _data;
  Map _json;
  String _name;
  String _version;

  Generator(this._data) {
    _json = JSON.parse(_data);
    _name = _json["name"];
    _version = _json["version"];
  }

  void generateClient(String outputDirectory) {
    var folderName = "$outputDirectory/${fileDate(new Date.now())}/${_name}_${_version}_api_client";
    (new Directory("$folderName/lib/src")).createSync(recursive: true);

    (new File("$folderName/pubspec.yaml")).writeAsStringSync(_createPubspec());

    (new File("$folderName/lib/$_name.dart")).writeAsStringSync(_createLibrary());
    
    (new File("$folderName/lib/src/client.dart")).writeAsStringSync(_createClientClass());

    (new File("$folderName/lib/src/schemas.dart")).writeAsStringSync(_createSchemas());

    (new File("$folderName/lib/src/resources.dart")).writeAsStringSync(_createResources());

    (new File("$folderName/lib/src/$_name.dart")).writeAsStringSync(_createMainClass());
  }

  String _createPubspec() {
    return """
name: ${_name}_${_version}_api_client
version: 0.0.1
description: Auto-generated client library for accessing the $_name $_version API
author: Gerwin Sturm (scarygami/+)

dependencies:
dart-google-oauth2-library:
git: git://github.com/Scarygami/dart-google-oauth2-library.git
""";
  }

  String _createLibrary() {
    return """
library $_name;

import "dart:html";
import "dart:uri";
import "dart:json";
import "package:dart-google-oauth2-library/oauth2.dart";

part "src/client.dart";
part "src/$_name.dart";
part "src/schemas.dart";
part "src/resources.dart";
""";
  }

  String _createSchemas() {
    var tmp = new StringBuffer();
 
    tmp.add("part of $_name;\n\n");

    if (_json.containsKey("schemas")) {
      _json["schemas"].forEach((key, schema) {
        tmp.add(_createSchemaClass(key, schema));
      });
    }    
    
    return tmp.toString();
  }

  String _createResources() {
    var tmp = new StringBuffer();
    
    tmp.add("part of $_name;\n\n");
    
    if (_json.containsKey("resources")) {
      _json["resources"].forEach((key, resource) {
        tmp.add(_createResourceClass(key, resource));
      });
    }
    
    return tmp.toString();
  }
  
  String _createMainClass() {
    var tmp = new StringBuffer();
    tmp.add("part of $_name;\n\n");
    tmp.add("/** Client to access the $_name $_version API */\n");
    if (_json.containsKey("description")) {
      tmp.add("/** ${_json["description"]} */\n");
    }
    tmp.add("class ${capitalize(_name)} extends Client {\n\n");
    if (_json.containsKey("resources")) {
      tmp.add("\n");
      _json["resources"].forEach((key, resource) {
        var subClassName = "${capitalize(key)}Resource";
        tmp.add("  $subClassName _$key;\n");
        tmp.add("  $subClassName get $key => _$key;\n");
      });
    }
    tmp.add("\n  ${capitalize(_name)}([String apiKey, OAuth2 auth]) : super(apiKey, auth) {\n");
    tmp.add("    _baseUrl = \"${_json["baseUrl"]}\";\n");
    tmp.add("    _rootUrl = \"${_json["rootUrl"]}\";\n");
    if (_json.containsKey("resources")) {
      _json["resources"].forEach((key, resource) {
        var subClassName = "${capitalize(key)}Resource";
        tmp.add("    _$key = new $subClassName._internal(this);\n");
      });
    }
    if (_json.containsKey("methods")) {
      _json["methods"].forEach((key, method) {
        tmp.add("\n");
        tmp.add(_createMethod(key, method));
      });
    }
    tmp.add("  }\n");
    tmp.add("}\n");

    return tmp.toString();
  }

  String _createSchemaClass(String name, Map data) {
    var tmp = new StringBuffer();
    Map subSchemas = new Map();

    if (data.containsKey("description")) {
      tmp.add("/** ${data["description"]} */\n");
    }

    tmp.add("class ${capitalize(name)} {\n");

    if (data.containsKey("properties")) {
      data["properties"].forEach((key, property) {
        var schemaType = property["type"];
        bool array = false;
        var type;
        if (schemaType == "array") {
          array = true;
          schemaType = property["items"]["type"];
        }
        switch(schemaType) {
          case "object":
            var subSchemaName = "${capitalize(name)}${capitalize(key)}";
            type = subSchemaName;
            if (array) {
              subSchemas[subSchemaName] = property["items"];
            } else {
              subSchemas[subSchemaName] = property;
            }
            break;
          case "string": type = "String"; break;
          case "number": type = "num"; break;
          case "integer": type = "int"; break;
          case "boolean": type = "bool"; break;
        }
        if (type == null) {
          if (array) {
            type = property["items"]["\$ref"];
          } else {
            type = property["\$ref"];
          }
        }
        if (type != null) {
          if (property.containsKey("description")) {
            tmp.add("\n  /** ${property["description"]} */\n");
          }
          if (array) {
            tmp.add("  List<$type> $key;\n");
          } else {
            tmp.add("  $type $key;\n");
          }
        }
      });
    }

    tmp.add("\n");
    tmp.add("  /** Create new $name from JSON data */\n");
    tmp.add("  ${capitalize(name)}.fromJson(Map json) {\n");
    if (data.containsKey("properties")) {
      data["properties"].forEach((key, property) {
        var schemaType = property["type"];
        bool array = false;
        bool object = false;
        var type;
        if (schemaType == "array") {
          array = true;
          schemaType = property["items"]["type"];
        }
        switch(schemaType) {
          case "object":
            type = "${capitalize(name)}${capitalize(key)}";
            object = true;
            break;
          case "string": type = "String"; break;
          case "number": type = "num"; break;
          case "integer": type = "int"; break;
          case "boolean": type = "bool"; break;
        }
        if (type == null) {
          object = true;
          if (array) {
            type = property["items"]["\$ref"];
          } else {
            type = property["\$ref"];
          }
        }
        if (type != null) {
          tmp.add("    if (json.containsKey(\"$key\")) {\n");
          if (array) {
            tmp.add("      $key = [];\n");
            tmp.add("      json[\"$key\"].forEach((item) {\n");
            if (object) {
              tmp.add("        $key.add(new $type.fromJson(item));\n");
            } else {
              tmp.add("        $key.add(item);\n");
            }
            tmp.add("      });\n");
          } else {
            if (object) {
              tmp.add("      $key = new $type.fromJson(json[\"$key\"]);\n");
            } else {
              tmp.add("      $key = json[\"$key\"];\n");
            }
          }
          tmp.add("    }\n");
        }
      });
    }
    tmp.add("  }\n\n");

    tmp.add("  /** Create JSON Object for $name */\n");
    tmp.add("  Map toJson() {\n");
    tmp.add("    var output = new Map();\n\n");
    if (data.containsKey("properties")) {
      data["properties"].forEach((key, property) {
        var schemaType = property["type"];
        bool array = false;
        bool object = false;
        var type;
        if (schemaType == "array") {
          array = true;
          schemaType = property["items"]["type"];
        }
        switch(schemaType) {
          case "object":
            type = "${capitalize(name)}${capitalize(key)}";
            object = true;
            break;
          case "string": type = "String"; break;
          case "number": type = "num"; break;
          case "integer": type = "int"; break;
          case "boolean": type = "bool"; break;
        }
        if (type == null) {
          object = true;
          if (array) {
            type = property["items"]["\$ref"];
          } else {
            type = property["\$ref"];
          }
        }
        if (type != null) {
          tmp.add("    if ($key != null) {\n");
          if (array) {
            tmp.add("      output[\"$key\"] = new List();\n");
            tmp.add("      $key.forEach((item) {\n");
            if (object) {
              tmp.add("        output[\"$key\"].add(item.toJson());\n");
            } else {
              tmp.add("        output[\"$key\"].add(item);\n");
            }
            tmp.add("      });\n");
          } else {
            if (object) {
              tmp.add("      output[\"$key\"] = $key.toJson();\n");
            } else {
              tmp.add("      output[\"$key\"] = $key;\n");
            }
          }
          tmp.add("    }\n");
        }
      });
    }
    tmp.add("\n    return output;\n");
    tmp.add("  }\n\n");

    tmp.add("  /** Return String representation of $name */\n");
    tmp.add("  String toString() => JSON.stringify(this.toJson());\n\n");

    tmp.add("}\n\n");

    subSchemas.forEach((subName, value) {
      tmp.add(_createSchemaClass(subName, value));
    });

    return tmp.toString();
  }

  /// Create a method with [name] inside of a class, based on [data]
  String _createMethod(String name, Map data) {
    var tmp = new StringBuffer();
    var upload = false;
    var uploadPath;

    if(data.containsKey("description")) {
      tmp.add("  /** ${data["description"]} */\n");
    }

    var params = new StringBuffer();
    if (data.containsKey("request")) {
      params.add("${data["request"]["\$ref"]} request");
    }
    if (data.containsKey("parameterOrder") && data.containsKey("parameters")) {
      data["parameterOrder"].forEach((param) {
        if (data["parameters"].containsKey(param)) {
          var type = null;
          switch(data["parameters"][param]["type"]) {
            case "string": type = "String"; break;
            case "number": type = "num"; break;
            case "integer": type = "int"; break;
            case "boolean": type = "bool"; break;
          }
          if (type != null) {
            if(!params.isEmpty) params.add(", ");
            params.add("$type $param");
          }
        }
      });
    }
    
    if (data.containsKey("mediaUpload")) {
      if (data["mediaUpload"].containsKey("protocols")) {
        if (data["mediaUpload"]["protocols"].containsKey("simple")) {
          if (data["mediaUpload"]["protocols"]["simple"].containsKey("multipart")) {
            if (data["mediaUpload"]["protocols"]["simple"]["multipart"] == true) {
              upload = true;
              uploadPath = data["mediaUpload"]["protocols"]["simple"]["path"];
            }
          }
        }
      }
    }
    
    var optParams = new StringBuffer();
    if (upload) {
      optParams.add("String content, String contentType");
    }
    if(!optParams.isEmpty) optParams.add(", ");
    optParams.add("Map optParams");

    if(!params.isEmpty) params.add(", ");
    params.add("{${optParams.toString()}}");
    
    var response = null;
    if (data.containsKey("response")) {
      response = "Future<${data["response"]["\$ref"]}>";
    } else {
      response = "Future<Map>";
    }

    tmp.add("  $response $name($params) {\n");
    tmp.add("    var completer = new Completer();\n");
    tmp.add("    var url = \"${data["path"]}\";\n");
    if (upload) {
      tmp.add("    var uploadUrl = \"$uploadPath\";\n");
    }
    tmp.add("    var urlParams = new Map();\n");
    tmp.add("    if (optParams == null) optParams = new Map();\n\n");
    
    if (data.containsKey("parameterOrder") && data.containsKey("parameters")) {
      data["parameterOrder"].forEach((param) {
        if (data["parameters"].containsKey(param)) {
          if (data["parameters"][param]["location"] == "path") {
            tmp.add("    urlParams[\"$param\"] = $param;\n");
          } else {
            tmp.add("    optParams[\"$param\"] = $param;\n");
          }
        }
      });
      tmp.add("\n");
    }

    params.clear();
    if (data.containsKey("request")) {
      params.add("body: request.toString(), ");
    }
    params.add("urlParams: urlParams, queryParams: optParams");
    
    
    tmp.add("    var response;\n");
    if (upload) {
      var uploadParams = new StringBuffer();
      if (data.containsKey("request")) {
        uploadParams.add("request.toString(), ");
      } else {
        uploadParams.add("\"\", ");
      }
      uploadParams.add("content, contentType, urlParams: urlParams, queryParams: optParams");
      tmp.add("    if (?content && content != null) {\n");
      tmp.add("      response = _client._upload(uploadUrl, \"${data["httpMethod"]}\", ${uploadParams.toString()});\n");
      tmp.add("    } else {\n");
      tmp.add("      response = _client._request(url, \"${data["httpMethod"]}\", ${params.toString()});\n");
      tmp.add("    }\n");
    } else {
      tmp.add("    response = _client._request(url, \"${data["httpMethod"]}\", ${params.toString()});\n");
    }
    
    tmp.add("    response.then((data) {\n");
    if (data.containsKey("response")) {
      tmp.add("      completer.complete(new ${data["response"]["\$ref"]}.fromJson(data));\n");
    } else {
      tmp.add("      completer.complete(data);\n");
    }
    tmp.add("    });\n\n");
    tmp.add("    return completer.future;\n");
    tmp.add("  }\n");

    return tmp.toString();
  }

  String _createResourceClass(String name, Map data) {
    var tmp = new StringBuffer();
    var className = "${capitalize(name)}Resource";

    tmp.add("class $className extends Resource {\n");

    if (data.containsKey("resources")) {
      tmp.add("\n");
      data["resources"].forEach((key, resource) {
        var subClassName = "${capitalize(name)}${capitalize(key)}Resource";
        tmp.add("  $subClassName _$key;\n");
        tmp.add("  $subClassName get $key => _$key;\n");
      });
    }

    tmp.add("\n  $className._internal(Client client) : super(client) {\n");
    if (data.containsKey("resources")) {
      data["resources"].forEach((key, resource) {
        var subClassName = "${capitalize(name)}${capitalize(key)}Resource";
        tmp.add("  _$key = new $subClassName._internal(client);\n");
      });
    }
    tmp.add("  }\n");

    if (data.containsKey("methods")) {
      data["methods"].forEach((key, method) {
        tmp.add("\n");
        tmp.add(_createMethod(key, method));
      });
    }

    tmp.add("}\n\n");

    if (data.containsKey("resources")) {
      data["resources"].forEach((key, resource) {
        tmp.add(_createResourceClass("${capitalize(name)}${capitalize(key)}", resource));
      });
    }

    return tmp.toString();
  }

  String _createClientClass() {
    return """
part of $_name;

abstract class Client {
  String _apiKey;
  OAuth2 _auth;
  String _baseUrl;
  String _rootUrl;
  bool makeAuthRequests = false;

  static const _boundary = "-------314159265358979323846";
  static const _delimiter = "\\r\\n--\$_boundary\\r\\n";
  static const _closeDelim = "\\r\\n--\$_boundary--";

  Client([String this._apiKey, OAuth2 this._auth]);

  Future _request(String requestUrl, String method, {String body, String contentType:"application/json", Map urlParams, Map queryParams}) {
    var request = new HttpRequest();
    var completer = new Completer();

    if (urlParams == null) urlParams = {};
    if (queryParams == null) queryParams = {};

    if (_apiKey != null) {
      queryParams["key"] = _apiKey;
    }

    var path;
    if (requestUrl.substring(0,1) == "/") {
      path ="\$_rootUrl\${requestUrl.substring(1)}";
    } else {
      path = "\$_baseUrl\$requestUrl";
    }
    final url = new UrlPattern(path).generate(urlParams, queryParams);

    request.on.loadEnd.add((Event e) {
      if (request.status == 200) {
        var data = JSON.parse(request.responseText);
        completer.complete(data);
      } else {
        completer.complete({"error": "Error \${request.status}: \${request.statusText}"});
      }
    });

    request.open(method, url);
    request.setRequestHeader("Content-Type", contentType);
    if (makeAuthRequests && _auth != null) {
      _auth.authenticate(request).then((request) => request.send(body));
    } else {
      request.send(body);
    }

    return completer.future;
  }

  Future _upload(String requestUrl, String method, String body, String content, String contentType, {Map urlParams, Map queryParams}) {
    var multiPartBody = new StringBuffer();
    if (contentType == null || contentType.isEmpty) {
      contentType = "application/octet-stream";
    }
    multiPartBody
    ..add(_delimiter)
    ..add("Content-Type: application/json\\r\\n\\r\\n")
    ..add(body)
    ..add(_delimiter)
    ..add("Content-Type: ")
    ..add(contentType)
    ..add("\\r\\n")
    ..add("Content-Transfer-Encoding: base64\\r\\n")
    ..add("\\r\\n")
    ..add(contentType)
    ..add(_closeDelim);

    return _request(requestUrl, method, body: multiPartBody.toString(), contentType: "multipart/mixed; boundary=\\"\$_boundary\\"", urlParams: urlParams, queryParams: queryParams);
  }
}


abstract class Resource {
  Client _client;

  Resource(Client this._client);
}
""";
  }
}


Future<String> loadDocumentFromUrl(String url) {
  var completer = new Completer();
  var client = new HttpClient();
  var connection = client.getUrl(new Uri.fromString(url));
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

void printUsage(parser) {
  print("discovery_api_dart_client_generator: creates a Client library based on a discovery document\n");
  print("Usage:");
  print("   generator.dart -a <API> - v <Version> [-o <Directory>] (to load from Google Discovery API)");
  print("or generator.dart -u <URL> [-o <Directory>] (to load discovery document from specified URL)");
  print("or generator.dart -i <File> [-o <Directory>] (to load discovery document from local file)\n");
  print(parser.getUsage());
}

void main() {
  final options = new Options();
  var parser = new ArgParser();
  parser.addOption("api", abbr: "a", help: "Short name of the Google API (plus, drive, ...)");
  parser.addOption("version", abbr: "v", help: "Google API version (v1, v2, v1alpha, ...)");
  parser.addOption("input", abbr: "i", help: "Local Discovery document file");
  parser.addOption("url", abbr: "u", help: "URL of a Discovery document");
  parser.addOption("output", abbr: "o", help: "Output Directory", defaultsTo: "output/");
  parser.addFlag("help", abbr: "h", help: "Display this information and exit", negatable: false);
  var result;
  try {
    result = parser.parse(options.arguments);
  } on FormatException catch(e) {
    print("Error parsing arguments:\n${e.message}\n");
    printUsage(parser);
    return;
  }

  if (result["help"] != null && result["help"] == true) {
    printUsage(parser);
    return;
  }

  if ((result["api"] == null || result["version"] == null) && result["input"] == null && result["url"] == null) {
    print("Missing arguments\n");
    printUsage(parser);
    return;
  }

  var loader;
  if (result["api"] !=null)
    loader = loadDocumentFromGoogle(result["api"], result["version"]);
  else if (result["url"] != null)
    loader = loadDocumentFromUrl(result["url"]);
  else if (result["input"] != null)
    loader = loadDocumentFromFile(result["input"]);

  loader.then((doc) {
    var generator = new Generator(doc);
    generator.generateClient(result["output"]);
  });
}