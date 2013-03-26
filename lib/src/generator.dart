part of discovery_api_client_generator;

const String clientVersion = "0.1";
const String dartEnvironmentVersionConstraint = '>=0.4.3+1.r20444';
const String jsDependenciesVersionConstraint = '>=0.0.18';
const String googleOAuth2ClientVersionConstraint = '>=0.2.8';

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
  String _prefix;
  int _clientVersionBuild;

  Generator(String this._data, [String this._prefix = "google"]) {
    _json = JSON.parse(_data);
    _name = _json["name"];
    _version = _json["version"];
    _shortName = cleanName("${_name}_${_version}").toLowerCase();
    _gitName = cleanName("dart_${_name}_${_version}_api_client").toLowerCase();
    _libraryName = cleanName("${_name}_${_version}_api_client").toLowerCase();
    _libraryBrowserName = cleanName("${_name}_${_version}_api_browser").toLowerCase();
    _libraryConsoleName = cleanName("${_name}_${_version}_api_console").toLowerCase();
    _libraryPubspecName = cleanName("${_prefix}_${_name}_${_version}_api").toLowerCase();
    _clientVersionBuild = 0;
  }

  bool generateClient(String outputDirectory, {bool fullLibrary: false, bool check: false, bool force: false, int forceVersion}) {
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
          _clientVersionBuild = (forceVersion != null) ? forceVersion : int.parse(version.substring(clientVersion.length + 1)) + 1;
        } else {
          if (version.startsWith(clientVersion)) {
            if (etag == _json["etag"]) {
              print("Nothing changed for $_libraryName");
              return false;
            } else {
              print("Changes for $_libraryName");
              print("Regenerating library $_libraryName");
              _clientVersionBuild = (forceVersion != null) ? forceVersion : int.parse(version.substring(clientVersion.length + 1)) + 1;
            }
          } else {
            print("Generator version changed.");
            print("Regenerating library $_libraryName");
            _clientVersionBuild = (forceVersion != null) ? forceVersion : 0;
          }
        }
      } else {
        print("Library $_libraryName does not exist yet.");
        print("Generating library $_libraryName");
        _clientVersionBuild = (forceVersion != null) ? forceVersion : 0;
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
    return true;
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
environment:
  sdk: '${dartEnvironmentVersionConstraint}'
dependencies:
  js: '${jsDependenciesVersionConstraint}'
  google_oauth2_client: '${googleOAuth2ClientVersionConstraint}'
""";
  }

  String _createReadme() {
    var tmp = new StringBuffer();
    tmp.write("""
# $_libraryPubspecName

### Description

Auto-generated client library for accessing the $_name $_version API.

""");
    tmp.write("#### ");
    if (_json.containsKey("icons") && _json["icons"].containsKey("x16")) {
      tmp.write("![Logo](${_json["icons"]["x16"]}) ");
    }
    tmp.write("${_json["title"]} - $_name $_version\n\n");
    tmp.write("${_json["description"]}\n\n");
    if (_json.containsKey("documentationLink")) {
      tmp.write("Official API documentation: ${_json["documentationLink"]}\n\n");
    }
    tmp.write("For web applications:\n```\nimport \"package:$_libraryPubspecName/$_libraryBrowserName.dart\" as ${cleanName(_name).toLowerCase()}client;\n```\n\n");
    tmp.write("For console application:\n```\nimport \"package:$_libraryPubspecName/$_libraryConsoleName.dart\" as ${cleanName(_name).toLowerCase()}client;\n```\n\n");

    tmp.write("```\nvar ${cleanName(_name).toLowerCase()} = new ${cleanName(_name).toLowerCase()}client.${capitalize(_name)}();\n```\n\n");
    tmp.write("### Licenses\n\n```\n");
    tmp.write(createLicense());
    tmp.write("```\n");
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

    tmp.write("part of $_libraryName;\n\n");

    if (_json.containsKey("schemas")) {
      _json["schemas"].forEach((key, schema) {
        tmp.write(_createSchemaClass(key, schema));
      });
    }

    return tmp.toString();
  }

  String _createResources() {
    var tmp = new StringBuffer();

    tmp.write("part of $_libraryName;\n\n");

    if (_json.containsKey("resources")) {
      _json["resources"].forEach((key, resource) {
        tmp.write(_createResourceClass(key, resource));
      });
    }

    return tmp.toString();
  }

  String _createBrowserMainClass() {
    var tmp = new StringBuffer();
    tmp.write("part of $_libraryBrowserName;\n\n");
    tmp.write("/** Client to access the $_name $_version API */\n");
    if (_json.containsKey("description")) {
      tmp.write("/** ${_json["description"]} */\n");
    }
    tmp.write("class ${capitalize(_name)} extends BrowserClient {\n");
    if (_json.containsKey("resources")) {
      tmp.write("\n");
      _json["resources"].forEach((key, resource) {
        var subClassName = "${capitalize(key)}Resource";
        tmp.write("  $subClassName _$key;\n");
        tmp.write("  $subClassName get $key => _$key;\n");
      });
    }
    if(_json.containsKey("auth") && _json["auth"].containsKey("oauth2") && _json["auth"]["oauth2"].containsKey("scopes")) {
      _json["auth"]["oauth2"]["scopes"].forEach((scope, description) {
        var p = scope.lastIndexOf("/");
        var scopeName = scope.toUpperCase();
        if (p >= 0) scopeName = scopeName.substring(p+1);
        scopeName = cleanName(scopeName);
        tmp.write("\n");
        if (description.containsKey("description")) {
          tmp.write("  /** OAuth Scope2: ${description["description"]} */\n");
        } else {
          tmp.write("  /** OAuth Scope2 */\n");
        }
        tmp.write("  static const String ${scopeName}_SCOPE = \"$scope\";\n");
      });
    }
    if (_json.containsKey("parameters")) {
      _json["parameters"].forEach((key, param) {
        var type = parameterType[param["type"]];
        if (type != null) {
          tmp.write("\n");
          tmp.write("  /**\n");
          if (param.containsKey("description")) {
            tmp.write("   * ${param["description"]}\n");
          }
          tmp.write("   * Added as queryParameter for each request.\n");
          tmp.write("   */\n");
          tmp.write("  $type get $key => params[\"$key\"];\n");
          tmp.write("  set $key($type value) => params[\"$key\"] = value;\n");
        }
      });
    }
    tmp.write("\n  ${capitalize(_name)}([OAuth2 auth]) : super(auth) {\n");
    tmp.write("    basePath = \"${_json["basePath"]}\";\n");
    var uri = Uri.parse(_json["rootUrl"]);
    tmp.write("    rootUrl = \"${uri.origin}/\";\n");
    if (_json.containsKey("resources")) {
      _json["resources"].forEach((key, resource) {
        var subClassName = "${capitalize(key)}Resource";
        tmp.write("    _$key = new $subClassName(this);\n");
      });
    }
    tmp.write("  }\n");

    if (_json.containsKey("methods")) {
      _json["methods"].forEach((key, method) {
        tmp.write("\n");
        tmp.write(_createMethod(key, method));
      });
    }

    tmp.write("}\n");

    return tmp.toString();
  }

  String _createConsoleMainClass() {
    var tmp = new StringBuffer();
    tmp.write("part of $_libraryConsoleName;\n\n");
    tmp.write("/** Client to access the $_name $_version API */\n");
    if (_json.containsKey("description")) {
      tmp.write("/** ${_json["description"]} */\n");
    }
    tmp.write("class ${capitalize(_name)} extends ConsoleClient {\n");
    if (_json.containsKey("resources")) {
      tmp.write("\n");
      _json["resources"].forEach((key, resource) {
        var subClassName = "${capitalize(key)}Resource";
        tmp.write("  $subClassName _$key;\n");
        tmp.write("  $subClassName get $key => _$key;\n");
      });
    }
    if(_json.containsKey("auth") && _json["auth"].containsKey("oauth2") && _json["auth"]["oauth2"].containsKey("scopes")) {
      _json["auth"]["oauth2"]["scopes"].forEach((scope, description) {
        var p = scope.lastIndexOf("/");
        var scopeName = scope.toUpperCase();
        if (p >= 0) scopeName = scopeName.substring(p+1);
        scopeName = cleanName(scopeName);
        tmp.write("\n");
        if (description.containsKey("description")) {
          tmp.write("  /** OAuth Scope2: ${description["description"]} */\n");
        } else {
          tmp.write("  /** OAuth Scope2 */\n");
        }
        tmp.write("  static const String ${scopeName}_SCOPE = \"$scope\";\n");
      });
    }
    if (_json.containsKey("parameters")) {
      _json["parameters"].forEach((key, param) {
        var type = parameterType[param["type"]];
        if (type != null) {
          tmp.write("\n");
          tmp.write("  /**\n");
          if (param.containsKey("description")) {
            tmp.write("   * ${param["description"]}\n");
          }
          tmp.write("   * Added as queryParameter for each request.\n");
          tmp.write("   */\n");
          tmp.write("  $type get $key => params[\"$key\"];\n");
          tmp.write("  set $key($type value) => params[\"$key\"] = value;\n");
        }
      });
    }
    // TODO: change this to correct OAuth class for console
    tmp.write("\n  ${capitalize(_name)}([Object auth]) : super(auth) {\n");
    tmp.write("    basePath = \"${_json["basePath"]}\";\n");
    var uri = Uri.parse(_json["rootUrl"]);
    tmp.write("    rootUrl = \"${uri.origin}/\";\n");
    if (_json.containsKey("resources")) {
      _json["resources"].forEach((key, resource) {
        var subClassName = "${capitalize(key)}Resource";
        tmp.write("    _$key = new $subClassName(this);\n");
      });
    }
    tmp.write("  }\n");

    if (_json.containsKey("methods")) {
      _json["methods"].forEach((key, method) {
        tmp.write("\n");
        tmp.write(_createMethod(key, method));
      });
    }

    tmp.write("}\n");

    return tmp.toString();
  }

  String _createSchemaClass(String name, Map data) {
    var tmp = new StringBuffer();
    Map subSchemas = new Map();

    if (data.containsKey("description")) {
      tmp.write("/** ${data["description"]} */\n");
    }

    tmp.write("class ${capitalize(name)} {\n");

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
            tmp.write("\n  /** ${property["description"]} */\n");
          }
          if (array) {
            tmp.write("  List<$type> $key;\n");
          } else {
            tmp.write("  $type $key;\n");
          }
        }
      });
    }

    tmp.write("\n");
    tmp.write("  /** Create new $name from JSON data */\n");
    tmp.write("  ${capitalize(name)}.fromJson(Map json) {\n");
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
          tmp.write("    if (json.containsKey(\"$key\")) {\n");
          if (array) {
            tmp.write("      $key = [];\n");
            tmp.write("      json[\"$key\"].forEach((item) {\n");
            if (object) {
              tmp.write("        $key.add(new $type.fromJson(item));\n");
            } else {
              tmp.write("        $key.add(item);\n");
            }
            tmp.write("      });\n");
          } else {
            if (object) {
              tmp.write("      $key = new $type.fromJson(json[\"$key\"]);\n");
            } else {
              tmp.write("      $key = json[\"$key\"];\n");
            }
          }
          tmp.write("    }\n");
        }
      });
    }
    tmp.write("  }\n\n");

    tmp.write("  /** Create JSON Object for $name */\n");
    tmp.write("  Map toJson() {\n");
    tmp.write("    var output = new Map();\n\n");
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
          tmp.write("    if ($key != null) {\n");
          if (array) {
            tmp.write("      output[\"$key\"] = new List();\n");
            tmp.write("      $key.forEach((item) {\n");
            if (object) {
              tmp.write("        output[\"$key\"].add(item.toJson());\n");
            } else {
              tmp.write("        output[\"$key\"].add(item);\n");
            }
            tmp.write("      });\n");
          } else {
            if (object) {
              tmp.write("      output[\"$key\"] = $key.toJson();\n");
            } else {
              tmp.write("      output[\"$key\"] = $key;\n");
            }
          }
          tmp.write("    }\n");
        }
      });
    }
    tmp.write("\n    return output;\n");
    tmp.write("  }\n\n");

    tmp.write("  /** Return String representation of $name */\n");
    tmp.write("  String toString() => JSON.stringify(this.toJson());\n\n");

    tmp.write("}\n\n");

    subSchemas.forEach((subName, value) {
      tmp.write(_createSchemaClass(subName, value));
    });

    return tmp.toString();
  }

  String _createParamComment(name, description) {
    var tmp = new StringBuffer();
    tmp.write("   *\n");
    tmp.write("   * [$name]");
    if (description.containsKey("description")) {
      tmp.write(" - ${description["description"]}");
    }
    tmp.write("\n");
    if (description.containsKey("default")) {
      tmp.write("   *   Default: ${description["default"]}\n");
    }
    if (description.containsKey("minimum")) {
      tmp.write("   *   Minimum: ${description["minimum"]}\n");
    }
    if (description.containsKey("maximum")) {
      tmp.write("   *   Maximum: ${description["maximum"]}\n");
    }
    if (description.containsKey("enum")) {
      tmp.write("   *   Allowed values:\n");
      for (var i = 0; i < description["enum"].length; i++) {
        tmp.write("   *     ${description["enum"][i]}");
        if (description.containsKey("enumDescriptions")) {
          tmp.write(" - ${description["enumDescriptions"][i]}");
        }
        tmp.write("\n");
      }
    }

    return tmp.toString();
  }

  /// Create a method with [name] inside of a class, based on [data]
  String _createMethod(String name, Map data) {
    var tmp = new StringBuffer();
    var upload = false;
    var uploadPath;

    tmp.write("  /**\n");
    if (data.containsKey("description")) {
      tmp.write("   * ${data["description"]}\n");
    }

    var params = new List<String>();
    var optParams = new List<String>();

    if (data.containsKey("request")) {
      params.add("${data["request"]["\$ref"]} request");
      tmp.write(_createParamComment("request", {"description": "${data["request"]["\$ref"]} to send in this request"}));
    }
    if (data.containsKey("parameterOrder") && data.containsKey("parameters")) {
      data["parameterOrder"].forEach((param) {
        if (data["parameters"].containsKey(param)) {
          var type = parameterType[data["parameters"][param]["type"]];
          if (type != null) {
            var variable = cleanName(param);
            tmp.write(_createParamComment(variable, data["parameters"][param]));
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
      tmp.write(_createParamComment("content", {"description": "Base64 Data of the file content to be uploaded"}));
      tmp.write(_createParamComment("contentType", {"description": "MimeType of the file to be uploaded"}));
    }
    if (data.containsKey("parameters")) {
      data["parameters"].forEach((name, description) {
        if (!description.containsKey("gen_included")) {
          var type = parameterType[description["type"]];
          if (type != null) {
            var variable = cleanName(name);
            tmp.write(_createParamComment(variable, description));
            optParams.add("$type $variable");
          }
        }
      });
    }

    optParams.add("Map optParams");
    tmp.write(_createParamComment("optParams", {"description": "Additional query parameters"}));

    params.add("{${optParams.join(", ")}}");

    tmp.write("   */\n");
    var response = null;
    if (data.containsKey("response")) {
      response = "Future<${data["response"]["\$ref"]}>";
    } else {
      response = "Future<Map>";
    }

    tmp.write("  $response $name(${params.join(", ")}) {\n");
    tmp.write("    var completer = new Completer();\n");
    tmp.write("    var url = \"${data["path"]}\";\n");
    if (upload) {
      tmp.write("    var uploadUrl = \"$uploadPath\";\n");
    }
    tmp.write("    var urlParams = new Map();\n");
    tmp.write("    var queryParams = new Map();\n\n");
    tmp.write("    var paramErrors = new List();\n");

    if (data.containsKey("parameters")) {
      data["parameters"].forEach((name, description) {
        var variable = cleanName(name);
        var location = "queryParams";
        if (description["location"] == "path") { location = "urlParams"; }
        if (description["required"] == true) {
          tmp.write("    if ($variable == null) paramErrors.add(\"$variable is required\");\n");
        }
        if (description["enum"] != null) {
          var list = new StringBuffer();
          var values = new StringBuffer();
          description["enum"].forEach((value) {
            if (!list.isEmpty) list.write(", ");
            if (!values.isEmpty) values.write(", ");
            list.write("\"$value\"");
            values.write(value);
          });
          tmp.write("    if ($variable != null && ![$list].contains($variable)) {\n");
          tmp.write("      paramErrors.add(\"Allowed values for $variable: $values\");\n");
          tmp.write("    }\n");
        }
        tmp.write("    if ($variable != null) $location[\"$name\"] = $variable;\n");
      });
    }

    tmp.write("""
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

    tmp.write("    var response;\n");
    if (upload) {
      tmp.write("    if (?content && content != null) {\n");
      tmp.write("      response = _client.upload(uploadUrl, \"${data["httpMethod"]}\", $uploadCall);\n");
      tmp.write("    } else {\n");
      tmp.write("      response = _client.request(url, \"${data["httpMethod"]}\", $call);\n");
      tmp.write("    }\n");
    } else {
      tmp.write("    response = _client.request(url, \"${data["httpMethod"]}\", $call);\n");
    }

    tmp.write("    response\n");
    tmp.write("      .then((data) => ");
    if (data.containsKey("response")) {
      tmp.write("completer.complete(new ${data["response"]["\$ref"]}.fromJson(data)))\n");
    } else {
      tmp.write("completer.complete(data))\n");
    }
    tmp.write("      .catchError((e) { completer.completeError(e); return true; });\n");
    tmp.write("    return completer.future;\n");
    tmp.write("  }\n");

    return tmp.toString();
  }

  String _createResourceClass(String name, Map data) {
    var tmp = new StringBuffer();
    var className = "${capitalize(name)}Resource";

    tmp.write("class $className extends Resource {\n");

    if (data.containsKey("resources")) {
      tmp.write("\n");
      data["resources"].forEach((key, resource) {
        var subClassName = "${capitalize(name)}${capitalize(key)}Resource";
        tmp.write("  $subClassName _$key;\n");
        tmp.write("  $subClassName get $key => _$key;\n");
      });
    }

    tmp.write("\n  $className(Client client) : super(client) {\n");
    if (data.containsKey("resources")) {
      data["resources"].forEach((key, resource) {
        var subClassName = "${capitalize(name)}${capitalize(key)}Resource";
        tmp.write("  _$key = new $subClassName(client);\n");
      });
    }
    tmp.write("  }\n");

    if (data.containsKey("methods")) {
      data["methods"].forEach((key, method) {
        tmp.write("\n");
        tmp.write(_createMethod(key, method));
      });
    }

    tmp.write("}\n\n");

    if (data.containsKey("resources")) {
      data["resources"].forEach((key, resource) {
        tmp.write(_createResourceClass("${capitalize(name)}${capitalize(key)}", resource));
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
    ..write(_delimiter)
    ..write("Content-Type: application/json\\r\\n\\r\\n")
    ..write(body)
    ..write(_delimiter)
    ..write("Content-Type: ")
    ..write(contentType)
    ..write("\\r\\n")
    ..write("Content-Transfer-Encoding: base64\\r\\n")
    ..write("\\r\\n")
    ..write(content)
    ..write(_closeDelim);

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

    request.onLoadEnd.listen((Event e) {
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

        // On connection request set the content type and key if available.
        postHttpClient.openUrl(method, Uri.parse(url)).then((HttpClientRequest request) {
          request.headers.set(HttpHeaders.CONTENT_TYPE, contentType);
          if (makeAuthRequests && _auth != null) {
            request.headers.set(HttpHeaders.AUTHORIZATION, "Bearer \${_auth.credentials.accessToken}");
          }

          request.write(body);
          return request.close();
        }, onError: (error) => completer.completeError(new APIRequestException("POST HttpClientRequest error: \$error")))
        .then((HttpClientResponse response) {
          // On connection response read in data from stream, on close parse as json and return.
          StringBuffer onResponseBody = new StringBuffer();
          response.transform(new StringDecoder()).listen((String data) => onResponseBody.write(data), 
              onError: (error) => completer.completeError(new APIRequestException("POST stream error: \$error")), 
              onDone: () {
                var data = JSON.parse(onResponseBody.toString());
                completer.complete(data);
                clientDummyCompleter.complete(null);
                postHttpClient.close();
              });
        }, onError: (error) => completer.completeError(new APIRequestException("POST HttpClientResponse error: \$error")));
      } else if (method.toLowerCase() == "delete") {
        var deleteHttpClient = new HttpClient();

        deleteHttpClient.openUrl(method, Uri.parse(url)).then((HttpClientRequest request) {
          // On connection request set the content type and key if available.
          request.headers.set(HttpHeaders.CONTENT_TYPE, contentType);
          if (makeAuthRequests && _auth != null) {
            request.headers.set(HttpHeaders.AUTHORIZATION, "Bearer \${_auth.credentials.accessToken}");
          }

          return request.close();
        }, onError: (error) => completer.completeError(new APIRequestException("DELETE HttpClientRequest error: \$error")))
        .then((HttpClientResponse response) {
          // On connection response read in data from stream, on close parse as json and return.
          // TODO: response.statusCode should be checked for errors.
          completer.complete({});
          clientDummyCompleter.complete(null);
          deleteHttpClient.close();
        }, onError: (error) => completer.completeError(new APIRequestException("DELETE HttpClientResponse error: \$error")));
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
