import "dart:io";
import "dart:uri";
import "dart:async";
import "dart:json" as JSON;
import "package:args/args.dart";

String fileDate(Date date) => "${date.year}${(date.month < 10) ? 0 : ""}${date.month}${(date.day < 10) ? 0 : ""}${date.day}_${(date.hour < 10) ? 0 : ""}${date.hour}${(date.minute < 10) ? 0 : ""}${date.minute}${(date.second < 10) ? 0 : ""}${date.second}";
String capitalize(String string) => "${string.substring(0,1).toUpperCase()}${string.substring(1)}";
String cleanName(String name) => name.replaceAll(new RegExp(r"(\W)"), "_");

const Map parameterType = const {
  "string": "String",
  "number": "num",
  "integer": "int",
  "boolean": "bool"
};

const String clientVersion = "0.1";

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

class Generator {
  String _data;
  Map _json;
  String _name;
  String _version;
  String _shortName;
  String _gitName;
  String _libraryName;
  String _libraryBrowserName;
  String _libraryConsoleName;
  String _libraryPubspecName;
  int _clientVersionBuild;

  Generator(this._data) {
    _json = JSON.parse(_data);
    _name = _json["name"];
    _version = _json["version"];
    _shortName = cleanName("${_name}_${_version}");
    _gitName = cleanName("dart_${_name}_${_version}_api_client");
    _libraryName = cleanName("${_name}_${_version}_api_client");
    _libraryBrowserName = cleanName("${_name}_${_version}_api_browser");
    _libraryConsoleName = cleanName("${_name}_${_version}_api_console");
    _libraryPubspecName = cleanName("${_name}_${_version}_api");
    _clientVersionBuild = 0;
  }

  void generateClient(String outputDirectory, {bool fullLibrary: false, bool check: false, bool force: false}) {
    var mainFolder, srcFolder, libFolder;
    if (fullLibrary) {
      mainFolder = outputDirectory;
      libFolder = "$outputDirectory/lib";
      srcFolder = "src/$_shortName";
    } else {
      mainFolder = "$outputDirectory/$_gitName";
      libFolder = "$mainFolder/lib";
      srcFolder = "src";
    }

    if (check) {
      var versionFile = new File("$mainFolder/VERSION");
      var pubFile = new File("$mainFolder/pubspec.yaml");
      if (versionFile.existsSync() && pubFile.existsSync()) {
        var etag = versionFile.readAsStringSync();
        var pub = pubFile.readAsLinesSync();
        var version = "";
        pub.forEach((String line) {
          if (line.startsWith("version: ")) {
            version = line.substring(9);
          }
        });
        if (force) {
          print("Forced rebuild");
          print("Regenerating library $_libraryName");
          _clientVersionBuild = int.parse(version.substring(clientVersion.length + 1)) + 1;
        } else {
          if (version.startsWith(clientVersion)) {
            if (etag == _json["etag"]) {
              print("Nothing changed for $_libraryName");
              return;
            } else {
              print("Changes for $_libraryName");
              print("Regenerating library $_libraryName");
              _clientVersionBuild = int.parse(version.substring(clientVersion.length + 1)) + 1;
            }
          } else {
            print("Generator version changed.");
            print("Regenerating library $_libraryName");
            _clientVersionBuild = 0;
          }
        }
      } else {
        print("Library $_libraryName does not exist yet.");
        print("Generating library $_libraryName");
        _clientVersionBuild = 0;
      }
    }

    // Clean contents of directory (except for .git folder)
    var tmpDir = new Directory(mainFolder);
    if (tmpDir.existsSync()) {
      print("Emptying folder before library generation.");
      tmpDir.listSync().forEach((f) {
        if (f is File) {
          f.deleteSync();
        } else if (f is Directory) {
          if (!f.path.endsWith(".git")) {
            f.deleteSync(recursive: true);
          }
        }
      });
    }

    (new Directory("$libFolder/$srcFolder/common")).createSync(recursive: true);
    (new Directory("$libFolder/$srcFolder/browser")).createSync(recursive: true);
    (new Directory("$libFolder/$srcFolder/console")).createSync(recursive: true);

    if (!fullLibrary) {
      (new Directory("$mainFolder/test")).createSync(recursive: true);

      (new File("$mainFolder/pubspec.yaml")).writeAsStringSync(_createPubspec());

      (new File("$mainFolder/LICENSE")).writeAsStringSync(createLicense());

      (new File("$mainFolder/README.md")).writeAsStringSync(_createReadme());

      (new File("$mainFolder/.gitignore")).writeAsStringSync(createGitIgnore());

      (new File("$mainFolder/CONTRIBUTORS")).writeAsStringSync(createContributors());

      (new File("$mainFolder/VERSION")).writeAsStringSync(_json["etag"]);

      (new File("$mainFolder/test/run.sh")).writeAsStringSync(_createTest());
    }

    // Create common library files

    (new File("$libFolder/$_libraryName.dart")).writeAsStringSync(_createLibrary(srcFolder));

    (new File("$libFolder/$srcFolder/common/client.dart")).writeAsStringSync(_createClientClass());

    (new File("$libFolder/$srcFolder/common/schemas.dart")).writeAsStringSync(_createSchemas());

    (new File("$libFolder/$srcFolder/common/resources.dart")).writeAsStringSync(_createResources());

    // Create browser versions of the libraries
    (new File("$libFolder/$_libraryBrowserName.dart")).writeAsStringSync(_createBrowserLibrary(srcFolder));

    (new File("$libFolder/$srcFolder/browser/browserclient.dart")).writeAsStringSync(_createBrowserClientClass());

    (new File("$libFolder/$srcFolder/browser/$_name.dart")).writeAsStringSync(_createBrowserMainClass());

    // Create console versions of the libraries
    (new File("$libFolder/$_libraryConsoleName.dart")).writeAsStringSync(_createConsoleLibrary(srcFolder));

    (new File("$libFolder/$srcFolder/console/consoleclient.dart")).writeAsStringSync(_createConsoleClientClass());

    (new File("$libFolder/$srcFolder/console/$_name.dart")).writeAsStringSync(_createConsoleMainClass());

    print("Library $_libraryName generated successfully.");
  }

  String _createPubspec() {
    return """
name: $_libraryPubspecName
version: $clientVersion.$_clientVersionBuild
description: Auto-generated client library for accessing the $_name $_version API
homepage: https://github.com/dart-gde/discovery_api_dart_client_generator
authors:
- Gerwin Sturm <scarygami@gmail.com>
- Adam Singer <financeCoding@gmail.com>

dependencies:
  js: '>=0.0.14'
  google_oauth2_client: '>=0.2.1'
""";
  }

  String _createReadme() {
    var tmp = new StringBuffer();
    tmp.add("""
# $_libraryPubspecName

### Description

Auto-generated client library for accessing the $_name $_version API.

""");
    if (_json.containsKey("documentationLink")) {
      tmp.add("Official API documentation: ${_json["documentationLink"]}\n\n");
    }
    tmp.add("### Licenses\n\n```\n");
    tmp.add(createLicense());
    tmp.add("```\n");
    return tmp.toString();
  }

  String _createTest() {
    return """
#!/bin/bash

set -e

#####
# Type Analysis

echo
echo "dart_analyzer lib/*.dart"

results=`dart_analyzer lib/*.dart 2>&1`

echo "\$results"

if [ -n "\$results" ]; then
    exit 1
else
    echo "Passed analysis."
fi
""";
  }

  String _createLibrary(String srcFolder) {
    return """
library $_libraryName;

import "dart:async";
import "dart:uri";
import "dart:json" as JSON;

part "$srcFolder/common/client.dart";
part "$srcFolder/common/schemas.dart";
part "$srcFolder/common/resources.dart";

""";
  }

  String _createBrowserLibrary(String srcFolder) {
    return """
library $_libraryBrowserName;

import "$_libraryName.dart";
export "$_libraryName.dart";

import "dart:html";
import "dart:async";
import "dart:uri";
import "dart:json" as JSON;
import "package:js/js.dart" as js;
import "package:google_oauth2_client/google_oauth2_browser.dart";

part "$srcFolder/browser/browserclient.dart";
part "$srcFolder/browser/$_name.dart";

""";
  }

  String _createConsoleLibrary(String srcFolder) {
    return """
library $_libraryConsoleName;

import "$_libraryName.dart";
export "$_libraryName.dart";

import "dart:io";
import "dart:async";
import "dart:uri";
import "dart:json" as JSON;
import "package:http/http.dart" as http;
import "package:google_oauth2_client/google_oauth2_console.dart" as oauth2;

part "$srcFolder/console/consoleclient.dart";
part "$srcFolder/console/$_name.dart";

""";
  }

  String _createSchemas() {
    var tmp = new StringBuffer();

    tmp.add("part of $_libraryName;\n\n");

    if (_json.containsKey("schemas")) {
      _json["schemas"].forEach((key, schema) {
        tmp.add(_createSchemaClass(key, schema));
      });
    }

    return tmp.toString();
  }

  String _createResources() {
    var tmp = new StringBuffer();

    tmp.add("part of $_libraryName;\n\n");

    if (_json.containsKey("resources")) {
      _json["resources"].forEach((key, resource) {
        tmp.add(_createResourceClass(key, resource));
      });
    }

    return tmp.toString();
  }

  String _createBrowserMainClass() {
    var tmp = new StringBuffer();
    tmp.add("part of $_libraryBrowserName;\n\n");
    tmp.add("/** Client to access the $_name $_version API */\n");
    if (_json.containsKey("description")) {
      tmp.add("/** ${_json["description"]} */\n");
    }
    tmp.add("class ${capitalize(_name)} extends BrowserClient {\n");
    if (_json.containsKey("resources")) {
      tmp.add("\n");
      _json["resources"].forEach((key, resource) {
        var subClassName = "${capitalize(key)}Resource";
        tmp.add("  $subClassName _$key;\n");
        tmp.add("  $subClassName get $key => _$key;\n");
      });
    }
    if(_json.containsKey("auth") && _json["auth"].containsKey("oauth2") && _json["auth"]["oauth2"].containsKey("scopes")) {
      _json["auth"]["oauth2"]["scopes"].forEach((scope, description) {
        var p = scope.lastIndexOf("/");
        var scopeName = scope.toUpperCase();
        if (p >= 0) scopeName = scopeName.substring(p+1);
        scopeName = cleanName(scopeName);
        tmp.add("\n");
        if (description.containsKey("description")) {
          tmp.add("  /** OAuth Scope2: ${description["description"]} */\n");
        } else {
          tmp.add("  /** OAuth Scope2 */\n");
        }
        tmp.add("  static const String ${scopeName}_SCOPE = \"$scope\";\n");
      });
    }
    if (_json.containsKey("parameters")) {
      _json["parameters"].forEach((key, param) {
        var type = parameterType[param["type"]];
        if (type != null) {
          tmp.add("\n");
          tmp.add("  /**\n");
          if (param.containsKey("description")) {
            tmp.add("   * ${param["description"]}\n");
          }
          tmp.add("   * Added as queryParameter for each request.\n");
          tmp.add("   */\n");
          tmp.add("  $type get $key => params[\"$key\"];\n");
          tmp.add("  set $key($type value) => params[\"$key\"] = value;\n");
        }
      });
    }
    tmp.add("\n  ${capitalize(_name)}([OAuth2 auth]) : super(auth) {\n");
    tmp.add("    basePath = \"${_json["basePath"]}\";\n");
    tmp.add("    rootUrl = \"${_json["rootUrl"]}\";\n");
    if (_json.containsKey("resources")) {
      _json["resources"].forEach((key, resource) {
        var subClassName = "${capitalize(key)}Resource";
        tmp.add("    _$key = new $subClassName(this);\n");
      });
    }
    tmp.add("  }\n");

    if (_json.containsKey("methods")) {
      _json["methods"].forEach((key, method) {
        tmp.add("\n");
        tmp.add(_createMethod(key, method));
      });
    }

    tmp.add("}\n");

    return tmp.toString();
  }

  String _createConsoleMainClass() {
    var tmp = new StringBuffer();
    tmp.add("part of $_libraryConsoleName;\n\n");
    tmp.add("/** Client to access the $_name $_version API */\n");
    if (_json.containsKey("description")) {
      tmp.add("/** ${_json["description"]} */\n");
    }
    tmp.add("class ${capitalize(_name)} extends ConsoleClient {\n");
    if (_json.containsKey("resources")) {
      tmp.add("\n");
      _json["resources"].forEach((key, resource) {
        var subClassName = "${capitalize(key)}Resource";
        tmp.add("  $subClassName _$key;\n");
        tmp.add("  $subClassName get $key => _$key;\n");
      });
    }
    if(_json.containsKey("auth") && _json["auth"].containsKey("oauth2") && _json["auth"]["oauth2"].containsKey("scopes")) {
      _json["auth"]["oauth2"]["scopes"].forEach((scope, description) {
        var p = scope.lastIndexOf("/");
        var scopeName = scope.toUpperCase();
        if (p >= 0) scopeName = scopeName.substring(p+1);
        scopeName = cleanName(scopeName);
        tmp.add("\n");
        if (description.containsKey("description")) {
          tmp.add("  /** OAuth Scope2: ${description["description"]} */\n");
        } else {
          tmp.add("  /** OAuth Scope2 */\n");
        }
        tmp.add("  static const String ${scopeName}_SCOPE = \"$scope\";\n");
      });
    }
    if (_json.containsKey("parameters")) {
      _json["parameters"].forEach((key, param) {
        var type = parameterType[param["type"]];
        if (type != null) {
          tmp.add("\n");
          tmp.add("  /**\n");
          if (param.containsKey("description")) {
            tmp.add("   * ${param["description"]}\n");
          }
          tmp.add("   * Added as queryParameter for each request.\n");
          tmp.add("   */\n");
          tmp.add("  $type get $key => params[\"$key\"];\n");
          tmp.add("  set $key($type value) => params[\"$key\"] = value;\n");
        }
      });
    }
    // TODO: change this to correct OAuth class for console
    tmp.add("\n  ${capitalize(_name)}([Object auth]) : super(auth) {\n");
    tmp.add("    basePath = \"${_json["basePath"]}\";\n");
    tmp.add("    rootUrl = \"${_json["rootUrl"]}\";\n");
    if (_json.containsKey("resources")) {
      _json["resources"].forEach((key, resource) {
        var subClassName = "${capitalize(key)}Resource";
        tmp.add("    _$key = new $subClassName(this);\n");
      });
    }
    tmp.add("  }\n");

    if (_json.containsKey("methods")) {
      _json["methods"].forEach((key, method) {
        tmp.add("\n");
        tmp.add(_createMethod(key, method));
      });
    }

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

  String _createParamComment(name, description) {
    var tmp = new StringBuffer();
    tmp.add("   *\n");
    tmp.add("   * [$name]");
    if (description.containsKey("description")) {
      tmp.add(" - ${description["description"]}");
    }
    tmp.add("\n");
    if (description.containsKey("default")) {
      tmp.add("   *   Default: ${description["default"]}\n");
    }
    if (description.containsKey("minimum")) {
      tmp.add("   *   Minimum: ${description["minimum"]}\n");
    }
    if (description.containsKey("maximum")) {
      tmp.add("   *   Maximum: ${description["maximum"]}\n");
    }
    if (description.containsKey("enum")) {
      tmp.add("   *   Allowed values:\n");
      for (var i = 0; i < description["enum"].length; i++) {
        tmp.add("   *     ${description["enum"][i]}");
        if (description.containsKey("enumDescriptions")) {
          tmp.add(" - ${description["enumDescriptions"][i]}");
        }
        tmp.add("\n");
      }
    }

    return tmp.toString();
  }

  /// Create a method with [name] inside of a class, based on [data]
  String _createMethod(String name, Map data) {
    var tmp = new StringBuffer();
    var upload = false;
    var uploadPath;

    tmp.add("  /**\n");
    if (data.containsKey("description")) {
      tmp.add("   * ${data["description"]}\n");
    }

    var params = new List<String>();
    var optParams = new List<String>();

    if (data.containsKey("request")) {
      params.add("${data["request"]["\$ref"]} request");
      tmp.add(_createParamComment("request", {"description": "${data["request"]["\$ref"]} to send in this request"}));
    }
    if (data.containsKey("parameterOrder") && data.containsKey("parameters")) {
      data["parameterOrder"].forEach((param) {
        if (data["parameters"].containsKey(param)) {
          var type = parameterType[data["parameters"][param]["type"]];
          if (type != null) {
            var variable = cleanName(param);
            tmp.add(_createParamComment(variable, data["parameters"][param]));
            params.add("$type $variable");
            data["parameters"][param]["gen_included"] = true;
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

    if (upload) {
      optParams.add("String content");
      optParams.add("String contentType");
      tmp.add(_createParamComment("content", {"description": "Base64 Data of the file content to be uploaded"}));
      tmp.add(_createParamComment("contentType", {"description": "MimeType of the file to be uploaded"}));
    }
    if (data.containsKey("parameters")) {
      data["parameters"].forEach((name, description) {
        if (!description.containsKey("gen_included")) {
          var type = parameterType[description["type"]];
          if (type != null) {
            var variable = cleanName(name);
            tmp.add(_createParamComment(variable, description));
            optParams.add("$type $variable");
          }
        }
      });
    }

    optParams.add("Map optParams");
    tmp.add(_createParamComment("optParams", {"description": "Additional query parameters"}));

    params.add("{${optParams.join(", ")}}");

    tmp.add("   */\n");
    var response = null;
    if (data.containsKey("response")) {
      response = "Future<${data["response"]["\$ref"]}>";
    } else {
      response = "Future<Map>";
    }

    tmp.add("  $response $name(${params.join(", ")}) {\n");
    tmp.add("    var completer = new Completer();\n");
    tmp.add("    var url = \"${data["path"]}\";\n");
    if (upload) {
      tmp.add("    var uploadUrl = \"$uploadPath\";\n");
    }
    tmp.add("    var urlParams = new Map();\n");
    tmp.add("    var queryParams = new Map();\n\n");
    tmp.add("    var paramErrors = new List();\n");

    if (data.containsKey("parameters")) {
      data["parameters"].forEach((name, description) {
        var variable = cleanName(name);
        var location = "queryParams";
        if (description["location"] == "path") { location = "urlParams"; }
        if (description["required"] == true) {
          tmp.add("    if ($variable == null) paramErrors.add(\"$variable is required\");\n");
        }
        if (description["enum"] != null) {
          var list = new StringBuffer();
          var values = new StringBuffer();
          description["enum"].forEach((value) {
            if (!list.isEmpty) list.add(", ");
            if (!values.isEmpty) values.add(", ");
            list.add("\"$value\"");
            values.add(value);
          });
          tmp.add("    if ($variable != null && ![$list].contains($variable)) {\n");
          tmp.add("      paramErrors.add(\"Allowed values for $variable: $values\");\n");
          tmp.add("    }\n");
        }
        tmp.add("    if ($variable != null) $location[\"$name\"] = $variable;\n");
      });
    }

    tmp.add("""
    if (optParams != null) {
      optParams.forEach((key, value) {
        if (value != null && queryParams[key] == null) {
          queryParams[key] = value;
        }
      });
    }

    if (!paramErrors.isEmpty) {
      completer.completeError(new ArgumentError(paramErrors.join(" / ")));
      return completer.future;
    }

""");

    var call, uploadCall;
    if (data.containsKey("request")) {
      call = "body: request.toString(), urlParams: urlParams, queryParams: queryParams";
      uploadCall = "request.toString(), content, contentType, urlParams: urlParams, queryParams: queryParams";
    } else {
      call = "urlParams: urlParams, queryParams: queryParams";
      uploadCall = "null, content, contentType, urlParams: urlParams, queryParams: queryParams";
    }

    tmp.add("    var response;\n");
    if (upload) {
      tmp.add("    if (?content && content != null) {\n");
      tmp.add("      response = _client.upload(uploadUrl, \"${data["httpMethod"]}\", $uploadCall);\n");
      tmp.add("    } else {\n");
      tmp.add("      response = _client.request(url, \"${data["httpMethod"]}\", $call);\n");
      tmp.add("    }\n");
    } else {
      tmp.add("    response = _client.request(url, \"${data["httpMethod"]}\", $call);\n");
    }

    tmp.add("    response\n");
    tmp.add("      .then((data) => ");
    if (data.containsKey("response")) {
      tmp.add("completer.complete(new ${data["response"]["\$ref"]}.fromJson(data)))\n");
    } else {
      tmp.add("completer.complete(data))\n");
    }
    tmp.add("      .catchError((e) { completer.completeError(e); return true; });\n");
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

    tmp.add("\n  $className(Client client) : super(client) {\n");
    if (data.containsKey("resources")) {
      data["resources"].forEach((key, resource) {
        var subClassName = "${capitalize(name)}${capitalize(key)}Resource";
        tmp.add("  _$key = new $subClassName(client);\n");
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
part of $_libraryName;

/**
 * Base class for all API clients, offering generic methods for HTTP Requests to the API
 */
abstract class Client {
  String basePath;
  String rootUrl;
  bool makeAuthRequests;
  Map params;

  static const _boundary = "-------314159265358979323846";
  static const _delimiter = "\\r\\n--\$_boundary\\r\\n";
  static const _closeDelim = "\\r\\n--\$_boundary--";

  Client() {
    params = new Map();
    makeAuthRequests = false;
  }

  /**
   * Sends a HTTPRequest using [method] (usually GET or POST) to [requestUrl] using the specified [urlParams] and [queryParams]. Optionally include a [body] in the request.
   */
  Future request(String requestUrl, String method, {String body, String contentType:"application/json", Map urlParams, Map queryParams});

  /**
   * Joins [content] (encoded as Base64-String) with specified [contentType] and additional request [body] into one multipart-body and send a HTTPRequest with [method] (usually POST) to [requestUrl]
   */
  Future upload(String requestUrl, String method, String body, String content, String contentType, {Map urlParams, Map queryParams}) {
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
    ..add(content)
    ..add(_closeDelim);

    return request(requestUrl, method, body: multiPartBody.toString(), contentType: "multipart/mixed; boundary=\\"\$_boundary\\"", urlParams: urlParams, queryParams: queryParams);
  }
}

/// Base-class for all API Resources
abstract class Resource {
  /// The [Client] to be used for all requests
  Client _client;

  /// Create a new Resource, using the specified [Client] for requests
  Resource(Client this._client);
}

/// Exception thrown when the HTTP Request to the API failed
class APIRequestException implements Exception {
  final String msg;
  const APIRequestException([this.msg]);
  String toString() => (msg == null) ? "APIRequestException" : "APIRequestException: \$msg";
}

""";
  }

  String _createBrowserClientClass() {
    return """
part of $_libraryBrowserName;

/**
 * Base class for all Browser API clients, offering generic methods for HTTP Requests to the API
 */
abstract class BrowserClient extends Client {

  OAuth2 _auth;
  bool _jsClientLoaded = false;

  BrowserClient([OAuth2 this._auth]) : super();

  /**
   * Loads the JS Client Library to make CORS-Requests
   */
  Future<bool> _loadJsClient() {
    var completer = new Completer();
    
    if (_jsClientLoaded) {
      completer.complete(true);
      return completer.future;
    }
    
    js.scoped((){
      js.context.handleClientLoad =  new js.Callback.once(() {
        _jsClientLoaded = true;
        completer.complete(true);
      });
    });
    
    ScriptElement script = new ScriptElement();
    script.src = "http://apis.google.com/js/client.js?onload=handleClientLoad";
    script.type = "text/javascript";
    document.body.children.add(script);
    
    return completer.future;
  }
  
  /**
   * Makes a request via the JS Client Library to circumvent CORS-problems
   */
  Future _makeJsClientRequest(String requestUrl, String method, {String body, String contentType, Map queryParams}) {
    var completer = new Completer();
    var requestData = new Map();
    requestData["path"] = requestUrl;
    requestData["method"] = method;
    requestData["headers"] = new Map();
    
    if (queryParams != null) {
      requestData["params"] = queryParams;
    }
    
    if (body != null) {
      requestData["body"] = body;
      requestData["headers"]["Content-Type"] = contentType;
    }
    if (makeAuthRequests && _auth != null && _auth.token != null) {
      requestData["headers"]["Authorization"] = "\${_auth.token.type} \${_auth.token.data}";
    }
    
    js.scoped(() {
      var request = js.context.gapi.client.request(js.map(requestData));
      var callback = new js.Callback.once((jsonResp, rawResp) {
        if (jsonResp is bool && jsonResp == false) {
          var raw = JSON.parse(rawResp);
          if (raw["gapiRequest"]["data"]["status"] >= 400) {
            completer.completeError(new APIRequestException("JS Client - \${raw["gapiRequest"]["data"]["status"]} \${raw["gapiRequest"]["data"]["statusText"]} - \${raw["gapiRequest"]["data"]["body"]}"));
          } else {
            completer.complete({});              
          }
        } else {
          completer.complete(js.context.JSON.stringify(jsonResp));
        }
      });
      request.execute(callback);
    });
    
    return completer.future;
  }

  /**
   * Sends a HTTPRequest using [method] (usually GET or POST) to [requestUrl] using the specified [urlParams] and [queryParams]. Optionally include a [body] in the request.
   */
  Future request(String requestUrl, String method, {String body, String contentType:"application/json", Map urlParams, Map queryParams}) {
    var request = new HttpRequest();
    var completer = new Completer();

    if (urlParams == null) urlParams = {};
    if (queryParams == null) queryParams = {};

    params.forEach((key, param) {
      if (param != null && queryParams[key] == null) {
        queryParams[key] = param;
      }
    });

    var path;
    if (requestUrl.substring(0,1) == "/") {
      path ="\$rootUrl\${requestUrl.substring(1)}";
    } else {
      path ="\$rootUrl\${basePath.substring(1)}\$requestUrl";
    }
    var url = new UrlPattern(path).generate(urlParams, queryParams);

    request.on.loadEnd.add((Event e) {
      if (request.status == 200) {
        var data = JSON.parse(request.responseText);
        completer.complete(data);
      } else {
        if (request.status == 0) {
          _loadJsClient().then((v) {
            if (requestUrl.substring(0,1) == "/") {
              path = requestUrl;
            } else {
              path ="\$basePath\$requestUrl";
            }
            url = new UrlPattern(path).generate(urlParams, {});
            _makeJsClientRequest(url, method, body: body, contentType: contentType, queryParams: queryParams)
              .then((response) {
                var data = JSON.parse(response);
                completer.complete(data);
              })
              .catchError((e) {
                completer.completeError(e);
                return true;
              });
          });
        } else {
          var error = "";
          if (request.responseText != null) {
            var errorJson;
            try {
              errorJson = JSON.parse(request.responseText); 
            } on FormatException {
              errorJson = null;
            }
            if (errorJson != null && errorJson.containsKey("error")) {
              error = "\${errorJson["error"]["code"]} \${errorJson["error"]["message"]}";
            }
          }
          if (error == "") {
            error = "\${request.status} \${request.statusText}";
          }
          completer.completeError(new APIRequestException(error));
        }
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
}

""";
  }

  String _createConsoleClientClass() {
    return """
part of $_libraryConsoleName;

/**
 * Base class for all Console API clients, offering generic methods for HTTP Requests to the API
 */
abstract class ConsoleClient extends Client {

  oauth2.OAuth2Console _auth; 

  ConsoleClient([oauth2.OAuth2Console this._auth]) : super();

  /**
   * Sends a HTTPRequest using [method] (usually GET or POST) to [requestUrl] using the specified [urlParams] and [queryParams]. Optionally include a [body] in the request.
   */
  Future request(String requestUrl, String method, {String body, String contentType:"application/json", Map urlParams, Map queryParams}) {
    var completer = new Completer();

    if (urlParams == null) urlParams = {};
    if (queryParams == null) queryParams = {};

    params.forEach((key, param) {
      if (param != null && queryParams[key] == null) {
        queryParams[key] = param;
      }
    });

    var path;
    if (requestUrl.substring(0,1) == "/") {
      path ="\$rootUrl\${requestUrl.substring(1)}";
    } else {
      path ="\$rootUrl\${basePath.substring(1)}\$requestUrl";
    }

    var url = new oauth2.UrlPattern(path).generate(urlParams, queryParams);

    Future clientCallback(http.Client client) {
      // A dummy completer is used for the 'withClient' method, this should
      // go away after refactoring withClient in oauth2 package
      var clientDummyCompleter = new Completer();

      if (method.toLowerCase() == "get") {
        client.get(url).then((http.Response response) {
          var data = JSON.parse(response.body);
          completer.complete(data);
          clientDummyCompleter.complete(null);
        }, onError: (AsyncError error) {
          completer.completeError(new APIRequestException("onError: \$error"));
        });

      } else if (method.toLowerCase() == "post" || method.toLowerCase() == "put" || method.toLowerCase() == "patch") {
        // Workaround since http.Client does not properly support post for google apis
        var postHttpClient = new HttpClient();
        HttpClientConnection postConnection = postHttpClient.openUrl(method, Uri.parse(url));


        // On connection request set the content type and key if available.
        postConnection.onRequest = (HttpClientRequest request) {
          request.headers.set(HttpHeaders.CONTENT_TYPE, contentType);
          if (makeAuthRequests && _auth != null) {
            request.headers.set(HttpHeaders.AUTHORIZATION, "Bearer \${_auth.credentials.accessToken}");
          }

          request.outputStream.writeString(body);
          request.outputStream.close();
        };

        // On connection response read in data from stream, on close parse as json and return.
        postConnection.onResponse = (HttpClientResponse response) {
          StringInputStream stream = new StringInputStream(response.inputStream);
          StringBuffer onResponseBody = new StringBuffer();
          stream.onData = () {
            onResponseBody.add(stream.read());
          };

          stream.onClosed = () {
            var data = JSON.parse(onResponseBody.toString());
            completer.complete(data);
            clientDummyCompleter.complete(null);
            postHttpClient.shutdown();
          };

          // Handle stream error
          stream.onError = (error) {
            completer.completeError(new APIRequestException("POST stream error: \$error"));
          };

        };

        // Handle post error
        postConnection.onError = (error) {
          completer.completeError(new APIRequestException("POST error: \$error"));
        };
      } else if (method.toLowerCase() == "delete") {
        var deleteHttpClient = new HttpClient();
        HttpClientConnection deleteConnection = deleteHttpClient.openUrl(method, Uri.parse(url));

        // On connection request set the content type and key if available.
        deleteConnection.onRequest = (HttpClientRequest request) {
          request.headers.set(HttpHeaders.CONTENT_TYPE, contentType);
          if (makeAuthRequests && _auth != null) {
            request.headers.set(HttpHeaders.AUTHORIZATION, "Bearer \${_auth.credentials.accessToken}");
          }

          request.outputStream.close();
        };

        // On connection response read in data from stream, on close parse as json and return.
        deleteConnection.onResponse = (HttpClientResponse response) {
          // TODO: response.statusCode should be checked for errors.
          completer.complete({});
          clientDummyCompleter.complete(null);
          deleteHttpClient.shutdown();
        };

        // Handle delete error
        deleteConnection.onError = (error) {
          completer.completeError(new APIRequestException("DELETE error: \$error"));
        };
      } else {
        // Method has not been implemented yet error
        completer.completeError(new APIRequestException("\$method Not implemented"));
      }

      return clientDummyCompleter.future;
    };

    if (makeAuthRequests && _auth != null) {
      // Client wants an authenticated request.
      _auth.withClient(clientCallback); // Should not care about the future here.
    } else {
      // Client wants a non authenticated request.
      clientCallback(new http.Client()); // Should not care about the future here.
    }

    return completer.future;
  }
}

""";
  }
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

void printUsage(parser) {
  print("discovery_api_dart_client_generator: creates a Client library based on a discovery document\n");
  print("Usage:");
  print("   generator.dart -a <API> - v <Version> [-o <Directory>] (to load from Google Discovery API)");
  print("or generator.dart -u <URL> [-o <Directory>] (to load discovery document from specified URL)");
  print("or generator.dart -i <File> [-o <Directory>] (to load discovery document from local file)");
  print("or generator.dart --all [-o <Directory>] (to create libraries for all Google APIs)");
  print("or generator.dart --full [-o <Directory>] (to create one library including all Google APIs)\n");
  print("or generator.dart --list [-o <Directory>] (to create a list of available APIs for scripting)\n");
  print(parser.getUsage());
}

void main() {
  final options = new Options();
  var parser = new ArgParser();
  parser.addOption("api", abbr: "a", help: "Short name of the Google API (plus, drive, ...)");
  parser.addOption("version", abbr: "v", help: "Google API version (v1, v2, v1alpha, ...)");
  parser.addOption("input", abbr: "i", help: "Local Discovery document file");
  parser.addOption("url", abbr: "u", help: "URL of a Discovery document");
  parser.addFlag("all", help: "Create client libraries for all Google APIs", negatable: false);
  parser.addFlag("full", help: "Create one library including all Google APIs", negatable: false);
  parser.addFlag("list", help: "Create a list of available APIs for scripting", negatable: false);
  parser.addOption("output", abbr: "o", help: "Output Directory", defaultsTo: "output/");
  parser.addFlag("date", help: "Create sub folder with current date", negatable: false);
  parser.addFlag("check", help: "Check for changes against existing version if available", negatable: false);
  parser.addFlag("force", help: "Force client version update even if no changes", negatable: false);
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

  if ((result["api"] == null || result["version"] == null)
      && result["input"] == null && result["url"] == null
      && (result["all"] == null || result["all"] == false)
      && (result["full"] == null || result["full"] == false)
      && (result["list"] == null || result["list"] == false)) {
    print("Missing arguments\n");
    printUsage(parser);
    return;
  }

  var argumentErrors = false;
  argumentErrors = argumentErrors ||
      (result["api"] != null &&
        (result["input"] != null ||
         result["url"] != null ||
         (result["all"] != null && result["all"] == true) ||
         (result["full"] != null && result["full"] == true) ||
         (result["list"] != null && result["full"] == true))
      );
  argumentErrors = argumentErrors||
      (result["input"] != null &&
        (result["url"] != null ||
         (result["all"] != null && result["all"] == true) ||
         (result["full"] != null && result["full"] == true) ||
         (result["list"] != null && result["full"] == true))
      );
  argumentErrors = argumentErrors ||
      (result["url"] != null &&
        ((result["all"] != null && result["all"] == true) ||
         (result["full"] != null && result["full"] == true) ||
         (result["list"] != null && result["full"] == true))
      );
  argumentErrors = argumentErrors ||
      (result["all"] != null && result["all"] == true &&
        ((result["full"] != null && result["full"] == true) ||
         (result["list"] != null && result["full"] == true))
      );
  argumentErrors = argumentErrors ||
      (result["full"] != null && result["full"] == true &&
        ((result["list"] != null && result["full"] == true))
      );
  if (argumentErrors) {
    print("You can only define one kind of operation.\n");
    printUsage(parser);
    return;
  }

  var output = result["output"];
  if (result["date"] != null && result["date"] == true) {
    output = "$output/${fileDate(new Date.now())}";
  }

  var check = false;
  if (result["check"] != null && result["check"] == true) {
    check = true;
  }

  var force = false;
  if (result["force"] != null && result["force"] == true) {
    force = true;
  }

  if ((result["all"] == null || result["all"] == false) &&
      (result["full"] == null || result["full"] == false) &&
      (result["list"] == null || result["list"] == false)) {
    var loader;
    if (result["api"] !=null)
      loader = loadDocumentFromGoogle(result["api"], result["version"]);
    else if (result["url"] != null)
      loader = loadDocumentFromUrl(result["url"]);
    else if (result["input"] != null)
      loader = loadDocumentFromFile(result["input"]);

    loader.then((doc) {
      var generator = new Generator(doc);
      generator.generateClient(output, check: check, force: force);
    });
  } else {
    loadDocumentFromUrl("https://www.googleapis.com/discovery/v1/apis").then((data) {
      var apis = JSON.parse(data);
      if (result["full"] != null && result["full"] == true) {
        createFullClient(apis, output);
      }
      if (result["list"] != null && result["list"] == true) {
        createAPIList(apis, output);
      }
      if (result["all"] != null && result["all"] == true) {
        apis["items"].forEach((item) {
          loadDocumentFromUrl(item["discoveryRestUrl"]).then((doc) {
            var generator = new Generator(doc);
            generator.generateClient(output, check: check, force: force);
          });
        });
      }
    });
  }
}