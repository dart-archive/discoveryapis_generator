part of discovery_api_client_generator;

const String clientVersion = "0.1";
const String dartEnvironmentVersionConstraint = '>=0.5.20';
const String jsDependenciesVersionConstraint = '>=0.0.23';
const String googleOAuth2ClientVersionConstraint = '>=0.2.15';

class Generator {
  final Map<String, dynamic> _json;
  final String _name;
  final String _version;
  final String _etag;

  final String _shortName;
  final String _gitName;
  final String _libraryName;
  final String _libraryBrowserName;
  final String _libraryConsoleName;
  final String _prefix;

  String get _libraryPubspecName {
    var prefix = (_prefix.isEmpty) ? '' : _prefix + "_";
    return cleanName("${prefix}${_name}_${_version}_api").toLowerCase();
  }

  factory Generator(String data, [String prefix = "google"]) {
    var json = JSON.parse(data);
    String name = json["name"];
    String version = json["version"];
    String etag = json["etag"];

    return new Generator.core(json, name, version, prefix, etag);
  }

  Generator.core(this._json, String name, String version, this._prefix, this._etag) :
    _name = name,
    _version = version,
    _shortName = cleanName("${name}_${version}").toLowerCase(),
    _gitName = cleanName("dart_${name}_${version}_api_client").toLowerCase(),
    _libraryName = cleanName("${name}_${version}_api_client").toLowerCase(),
    _libraryBrowserName = cleanName("${name}_${version}_api_browser").toLowerCase(),
    _libraryConsoleName = cleanName("${name}_${version}_api_console").toLowerCase();


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

    int clientVersionBuild = 0;
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
          clientVersionBuild = (forceVersion != null) ? forceVersion : int.parse(version.substring(clientVersion.length + 1)) + 1;
        } else {
          if (version.startsWith(clientVersion)) {
            if (etag == _etag) {
              print("Nothing changed for $_libraryName");
              return false;
            } else {
              print("Changes for $_libraryName");
              print("Regenerating library $_libraryName");
              clientVersionBuild = (forceVersion != null) ? forceVersion : int.parse(version.substring(clientVersion.length + 1)) + 1;
            }
          } else {
            print("Generator version changed.");
            print("Regenerating library $_libraryName");
            clientVersionBuild = (forceVersion != null) ? forceVersion : 0;
          }
        }
      } else {
        print("Library $_libraryName does not exist yet.");
        print("Generating library $_libraryName");
        clientVersionBuild = (forceVersion != null) ? forceVersion : 0;
      }
    }

    // Clean contents of directory (except for .git folder)
    if (!fullLibrary) {
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
    }
    (new Directory("$libFolder/$srcFolder/client")).createSync(recursive: true);
    (new Directory("$libFolder/$srcFolder/browser")).createSync(recursive: true);
    (new Directory("$libFolder/$srcFolder/console")).createSync(recursive: true);
    (new Directory("$mainFolder/tool")).createSync(recursive: true);

    if (!fullLibrary) {
      _writeString("$mainFolder/pubspec.yaml", _createPubspec(clientVersionBuild));

      _writeString("$mainFolder/LICENSE", _license);

      _writeFile("$mainFolder/README.md", _writeReadme);

      _writeString("$mainFolder/.gitignore", _gitIgnore);

      _writeString("$mainFolder/CONTRIBUTORS", _contributors);

      _writeString("$mainFolder/VERSION", _etag);
    }

    // Create common library files

    _writeString("$libFolder/$_libraryName.dart", _createLibrary(srcFolder));

    _writeString("$libFolder/$srcFolder/client/client.dart", _createClientClass);

    _writeFile("$libFolder/$srcFolder/client/schemas.dart", _writeSchemas);

    _writeFile("$libFolder/$srcFolder/client/resources.dart", _writeResources);

    // Create browser versions of the libraries
    _writeString("$libFolder/$_libraryBrowserName.dart", _createBrowserLibrary(srcFolder));

    _writeString("$libFolder/$srcFolder/browser/browser_client.dart", _createBrowserClientClass);

    _writeFile("$libFolder/$srcFolder/browser/$_name.dart", _writeBrowserMainClass);

    // Create console versions of the libraries
    _writeString("$libFolder/$_libraryConsoleName.dart", _createConsoleLibrary(srcFolder));

    _writeString("$libFolder/$srcFolder/console/console_client.dart", _createConsoleClientClass);

    _writeFile("$libFolder/$srcFolder/console/$_name.dart", _writeConsoleMainClass);

    // Create hop_runner for the libraries
    _writeString("$mainFolder/tool/hop_runner.dart", _createHopRunner);

    print("Library $_libraryName generated successfully.");
    return true;
  }

  String _createPubspec(int clientVersionBuild) => """
name: $_libraryPubspecName
version: $clientVersion.$clientVersionBuild
authors:
- Gerwin Sturm <scarygami@gmail.com>
- Adam Singer <financeCoding@gmail.com>
description: Auto-generated client library for accessing the $_name $_version API
homepage: https://github.com/dart-gde/discovery_api_dart_client_generator
environment:
  sdk: '${dartEnvironmentVersionConstraint}'
dependencies:
  google_oauth2_client: '${googleOAuth2ClientVersionConstraint}'
  js: '${jsDependenciesVersionConstraint}'
dev_dependencies:
  hop: any
""";

  void _writeReadme(StringSink sink) {
    sink.write("""
# $_libraryPubspecName

### Description

Auto-generated client library for accessing the $_name $_version API.

""");
    sink.write("#### ");
    if (_json.containsKey("icons") && _json["icons"].containsKey("x16")) {
      sink.write("![Logo](${_json["icons"]["x16"]}) ");
    }
    sink.write("${_json["title"]} - $_name $_version\n\n");
    sink.write("${_json["description"]}\n\n");
    if (_json.containsKey("documentationLink")) {
      sink.write("Official API documentation: ${_json["documentationLink"]}\n\n");
    }
    sink.write("For web applications:\n```\nimport \"package:$_libraryPubspecName/$_libraryBrowserName.dart\" as ${cleanName(_name).toLowerCase()}client;\n```\n\n");
    sink.write("For console application:\n```\nimport \"package:$_libraryPubspecName/$_libraryConsoleName.dart\" as ${cleanName(_name).toLowerCase()}client;\n```\n\n");

    sink.write("```\nvar ${cleanName(_name).toLowerCase()} = new ${cleanName(_name).toLowerCase()}client.${capitalize(_name)}();\n```\n\n");
    sink.write("### Licenses\n\n```\n");
    sink.write(_license);
    sink.write("```\n");
  }

  String _createLibrary(String srcFolder) => """
library $_libraryName;

import "dart:core" as core;
import "dart:async" as async;
import "dart:json" as JSON;

part "$srcFolder/client/client.dart";
part "$srcFolder/client/schemas.dart";
part "$srcFolder/client/resources.dart";
""";

  String _createBrowserLibrary(String srcFolder) => """
library $_libraryBrowserName;

import "$_libraryName.dart";
export "$_libraryName.dart";

import "dart:core" as core;
import "dart:html" as html;
import "dart:async" as async;
import "dart:json" as JSON;
import "package:js/js.dart" as js;
import "package:google_oauth2_client/google_oauth2_browser.dart" as oauth;

part "$srcFolder/browser/browser_client.dart";
part "$srcFolder/browser/$_name.dart";
""";

  String _createConsoleLibrary(String srcFolder) => """
library $_libraryConsoleName;

import "$_libraryName.dart";
export "$_libraryName.dart";

import "dart:core" as core;
import "dart:io" as io;
import "dart:async" as async;
import "dart:json" as JSON;
import "package:http/http.dart" as http;
import "package:google_oauth2_client/google_oauth2_console.dart" as oauth2;

part "$srcFolder/console/console_client.dart";
part "$srcFolder/console/$_name.dart";
""";

  void _writeSchemas(StringSink sink) {
    sink.write("part of $_libraryName;\n\n");

    if (_json.containsKey("schemas")) {
      _json["schemas"].forEach((key, schema) {
        _writeSchemaClass(sink, key, schema);
      });
    }
  }

  void _writeResources(StringSink sink) {
    sink.write("part of $_libraryName;\n\n");

    if (_json.containsKey("resources")) {
      _json["resources"].forEach((key, resource) {
        _writeResourceClass(sink, key, resource);
      });
    }
  }

  void _writeBrowserMainClass(StringSink sink) {
    sink.write("part of $_libraryBrowserName;\n\n");
    sink.write("/** Client to access the $_name $_version API */\n");
    if (_json.containsKey("description")) {
      sink.write("/** ${_json["description"]} */\n");
    }
    sink.write("class ${capitalize(_name)} extends BrowserClient {\n");
    if (_json.containsKey("resources")) {
      sink.write("\n");
      _json["resources"].forEach((key, resource) {
        var subClassName = "${capitalize(key)}Resource_";
        sink.write("  $subClassName _$key;\n");
        sink.write("  $subClassName get $key => _$key;\n");
      });
    }
    if(_json.containsKey("auth") && _json["auth"].containsKey("oauth2") && _json["auth"]["oauth2"].containsKey("scopes")) {
      _json["auth"]["oauth2"]["scopes"].forEach((scope, description) {
        var p = scope.lastIndexOf("/");
        var scopeName = scope.toUpperCase();
        if (p >= 0) scopeName = scopeName.substring(p+1);
        scopeName = cleanName(scopeName);
        sink.write("\n");
        if (description.containsKey("description")) {
          sink.write("  /** OAuth Scope2: ${description["description"]} */\n");
        } else {
          sink.write("  /** OAuth Scope2 */\n");
        }
        sink.write("  static const core.String ${scopeName}_SCOPE = \"$scope\";\n");
      });
    }
    if (_json.containsKey("parameters")) {
      _json["parameters"].forEach((key, param) {
        var type = parameterType[param["type"]];
        if (param.containsKey("format")) {
          if (param["type"] == "string" && param["format"] == "int64") {
            type = "core.int";
          }
        }
        if (type != null) {
          sink.write("\n");
          sink.write("  /**\n");
          if (param.containsKey("description")) {
            sink.write("   * ${param["description"]}\n");
          }
          sink.write("   * Added as queryParameter for each request.\n");
          sink.write("   */\n");
          sink.write("  $type get $key => params[\"$key\"];\n");
          sink.write("  set $key($type value) => params[\"$key\"] = value;\n");
        }
      });
    }
    sink.writeln();
    sink.writeln('  final oauth.OAuth2 auth;');
    sink.writeln();
    sink.writeln("  ${capitalize(_name)}([oauth.OAuth2 this.auth]) {");
    if (_json.containsKey("resources")) {
      _json["resources"].forEach((key, resource) {
        var subClassName = "${capitalize(key)}Resource_";
        sink.write("    _$key = new $subClassName(this);\n");
      });
    }
    sink.write("  }\n");

    if (_json.containsKey("methods")) {
      _json["methods"].forEach((key, method) {
        sink.write("\n");
        _writeMethod(sink, key, method, true);
      });
    }

    sink.write("}\n");
  }

  void _writeConsoleMainClass(StringSink sink) {
    sink.write("part of $_libraryConsoleName;\n\n");
    sink.write("/** Client to access the $_name $_version API */\n");
    if (_json.containsKey("description")) {
      sink.write("/** ${_json["description"]} */\n");
    }
    sink.write("class ${capitalize(_name)} extends ConsoleClient {\n");
    if (_json.containsKey("resources")) {
      sink.write("\n");
      _json["resources"].forEach((key, resource) {
        var subClassName = "${capitalize(key)}Resource_";
        sink.write("  $subClassName _$key;\n");
        sink.write("  $subClassName get $key => _$key;\n");
      });
    }
    if(_json.containsKey("auth") && _json["auth"].containsKey("oauth2") && _json["auth"]["oauth2"].containsKey("scopes")) {
      _json["auth"]["oauth2"]["scopes"].forEach((scope, description) {
        var p = scope.lastIndexOf("/");
        var scopeName = scope.toUpperCase();
        if (p >= 0) scopeName = scopeName.substring(p+1);
        scopeName = cleanName(scopeName);
        sink.write("\n");
        if (description.containsKey("description")) {
          sink.write("  /** OAuth Scope2: ${description["description"]} */\n");
        } else {
          sink.write("  /** OAuth Scope2 */\n");
        }
        sink.write("  static const core.String ${scopeName}_SCOPE = \"$scope\";\n");
      });
    }
    if (_json.containsKey("parameters")) {
      _json["parameters"].forEach((key, param) {
        var type = parameterType[param["type"]];
        if (param.containsKey("format")) {
          if (param["type"] == "string" && param["format"] == "int64") {
            type = "core.int";
          }
        }
        if (type != null) {
          sink.write("\n");
          sink.write("  /**\n");
          if (param.containsKey("description")) {
            sink.write("   * ${param["description"]}\n");
          }
          sink.write("   * Added as queryParameter for each request.\n");
          sink.write("   */\n");
          sink.write("  $type get $key => params[\"$key\"];\n");
          sink.write("  set $key($type value) => params[\"$key\"] = value;\n");
        }
      });
    }
    // TODO: change this to correct OAuth class for console
    sink.writeln();
    sink.writeln('  final oauth2.OAuth2Console auth;');
    sink.writeln();
    sink.writeln("  ${capitalize(_name)}([oauth2.OAuth2Console this.auth]) {");
    if (_json.containsKey("resources")) {
      _json["resources"].forEach((key, resource) {
        var subClassName = "${capitalize(key)}Resource_";
        sink.write("    _$key = new $subClassName(this);\n");
      });
    }
    sink.write("  }\n");

    if (_json.containsKey("methods")) {
      _json["methods"].forEach((key, method) {
        sink.write("\n");
        _writeMethod(sink, key, method, true);
      });
    }

    sink.write("}\n");
  }

  void _writeSchemaClass(StringSink sink, String name, Map data) {
    Map subSchemas = new Map();

    if (data.containsKey("description")) {
      sink.write("/** ${data["description"]} */\n");
    }

    sink.write("class ${capitalize(name)} {\n");

    if (data.containsKey("properties")) {
      data["properties"].forEach((key, property) {
        var schemaType = property["type"];
        var schemaFormat = "";
        if (property.containsKey("format")) {
          schemaFormat = property["format"];
        }
        bool array = false;
        var type;
        if (schemaType == "array") {
          array = true;
          schemaType = property["items"]["type"];
          schemaFormat = "";
          if (property["items"].containsKey("format")) {
            schemaFormat = property["items"]["format"];
          }
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
          case "string":
            type = "core.String";
            if (schemaFormat == "int64") {
              type = "core.int";
            }
            break;
          case "number": type = "core.num"; break;
          case "integer": type = "core.int"; break;
          case "boolean": type = "core.bool"; break;
        }
        if (type == null) {
          if (array) {
            type = property["items"]["\$ref"];
          } else {
            type = property["\$ref"];
          }
        }
        if (type != null) {
          String propName = escapeProperty(cleanName(key));
          if (property.containsKey("description")) {
            sink.write("\n  /** ${property["description"]} */\n");
          }
          if (array) {
            sink.write("  core.List<$type> $propName;\n");
          } else {
            sink.write("  $type $propName;\n");
          }
        }
      });
    }

    sink.write("\n");
    sink.write("  /** Create new $name from JSON data */\n");
    sink.write("  ${capitalize(name)}.fromJson(core.Map json) {\n");
    if (data.containsKey("properties")) {
      data["properties"].forEach((key, property) {
        var schemaType = property["type"];
        var schemaFormat = "";
        if (property.containsKey("format")) {
          schemaFormat = property["format"];
        }
        bool array = false;
        bool object = false;
        var type;
        if (schemaType == "array") {
          array = true;
          schemaType = property["items"]["type"];
          schemaFormat = "";
          if (property["items"].containsKey("format")) {
            schemaFormat = property["items"]["format"];
          }
        }
        switch(schemaType) {
          case "object":
            type = "${capitalize(name)}${capitalize(key)}";
            object = true;
            break;
          case "string":
            type = "core.String";
            if (schemaFormat == "int64") {
              type = "core.int";
            }
            break;
          case "number": type = "core.num"; break;
          case "integer": type = "core.int"; break;
          case "boolean": type = "core.bool"; break;
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
          String propName = escapeProperty(cleanName(key));
          String jsonName = key.replaceAll("\$", "\\\$");
          sink.write("    if (json.containsKey(\"$jsonName\")) {\n");
          if (array) {
            sink.write("      $propName = [];\n");
            sink.write("      json[\"$jsonName\"].forEach((item) {\n");
            if (object) {
              sink.write("        $propName.add(new $type.fromJson(item));\n");
            } else {
              sink.write("        $propName.add(item);\n");
            }
            sink.write("      });\n");
          } else {
            if (object) {
              sink.write("      $propName = new $type.fromJson(json[\"$jsonName\"]);\n");
            } else {
              if(schemaType=="string" && schemaFormat == "int64") {
                sink.write("      if(json[\"$jsonName\"] is core.String){\n");
                sink.write("        $propName = core.int.parse(json[\"$jsonName\"]);\n");
                sink.write("      }else{\n");
                sink.write("        $propName = json[\"$jsonName\"];\n");
                sink.write("      }\n");
              }else{
                sink.write("      $propName = json[\"$jsonName\"];\n");
              }
            }
          }
          sink.write("    }\n");
        }
      });
    }
    sink.write("  }\n\n");

    sink.write("  /** Create JSON Object for $name */\n");
    sink.write("  core.Map toJson() {\n");
    sink.write("    var output = new core.Map();\n\n");
    if (data.containsKey("properties")) {
      data["properties"].forEach((key, property) {
        var schemaType = property["type"];
        var schemaFormat = "";
        if (property.containsKey("format")) {
          schemaFormat = property["format"];
        }
        bool array = false;
        bool object = false;
        var type;
        if (schemaType == "array") {
          array = true;
          schemaType = property["items"]["type"];
          schemaFormat = "";
          if (property["items"].containsKey("format")) {
            schemaFormat = property["items"]["format"];
          }
        }
        switch(schemaType) {
          case "object":
            type = "${capitalize(name)}${capitalize(key)}";
            object = true;
            break;
          case "string":
            type = "core.String";
            if (schemaFormat == "int64") {
              type = "core.int";
            }
            break;
          case "number": type = "core.num"; break;
          case "integer": type = "core.int"; break;
          case "boolean": type = "core.bool"; break;
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
          String propName = escapeProperty(cleanName(key));
          String jsonName = key.replaceAll("\$", "\\\$");
          sink.write("    if ($propName != null) {\n");
          if (array) {
            sink.write("      output[\"$jsonName\"] = new core.List();\n");
            sink.write("      $propName.forEach((item) {\n");
            if (object) {
              sink.write("        output[\"$jsonName\"].add(item.toJson());\n");
            } else {
              sink.write("        output[\"$jsonName\"].add(item);\n");
            }
            sink.write("      });\n");
          } else {
            if (object) {
              sink.write("      output[\"$jsonName\"] = $propName.toJson();\n");
            } else {
              sink.write("      output[\"$jsonName\"] = $propName;\n");
            }
          }
          sink.write("    }\n");
        }
      });
    }
    sink.write("\n    return output;\n");
    sink.write("  }\n\n");

    sink.write("  /** Return String representation of $name */\n");
    sink.write("  core.String toString() => JSON.stringify(this.toJson());\n\n");

    sink.write("}\n\n");

    subSchemas.forEach((subName, value) {
      _writeSchemaClass(sink, subName, value);
    });
  }

  void _writeParamComment(StringSink sink, String name, Map description) {
    sink.write("   *\n");
    sink.write("   * [$name]");
    if (description.containsKey("description")) {
      sink.write(" - ${description["description"]}");
    }
    sink.write("\n");
    if (description.containsKey("default")) {
      sink.write("   *   Default: ${description["default"]}\n");
    }
    if (description.containsKey("minimum")) {
      sink.write("   *   Minimum: ${description["minimum"]}\n");
    }
    if (description.containsKey("maximum")) {
      sink.write("   *   Maximum: ${description["maximum"]}\n");
    }
    if (description.containsKey("repeated") && description["repeated"] == true) {
      sink.write("   *   Repeated values: allowed\n");
    }
    if (description.containsKey("enum")) {
      sink.write("   *   Allowed values:\n");
      for (var i = 0; i < description["enum"].length; i++) {
        sink.write("   *     ${description["enum"][i]}");
        if (description.containsKey("enumDescriptions")) {
          sink.write(" - ${description["enumDescriptions"][i]}");
        }
        sink.write("\n");
      }
    }
  }

  /// Create a method with [name] inside of a class, based on [data]
  void _writeMethod(StringSink sink, String name, Map data, [bool noResource = false]) {
    var upload = false;
    var uploadPath;

    name = escapeMethod(cleanName(name));

    sink.write("  /**\n");
    if (data.containsKey("description")) {
      sink.write("   * ${data["description"]}\n");
    }

    var params = new List<String>();
    var optParams = new List<String>();

    if (data.containsKey("request")) {
      params.add("${data["request"]["\$ref"]} request");
      _writeParamComment(sink, "request", {"description": "${data["request"]["\$ref"]} to send in this request"});
    }
    if (data.containsKey("parameterOrder") && data.containsKey("parameters")) {
      data["parameterOrder"].forEach((param) {
        if (data["parameters"].containsKey(param)) {
          var type = parameterType[data["parameters"][param]["type"]];
          if (data["parameters"][param].containsKey("format")) {
             if (data["parameters"][param]["type"] == "string" && data["parameters"][param]["format"] == "int64") {
               type = "core.int";
             }
          }
          if (type != null) {
            var variable = escapeParameter(cleanName(param));
            _writeParamComment(sink, variable, data["parameters"][param]);
            if (data["parameters"][param].containsKey("repeated") && data["parameters"][param]["repeated"] == true) {
              params.add("core.List<$type> $variable");
            } else {
              params.add("$type $variable");
            }
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
      optParams.add("core.String content");
      optParams.add("core.String contentType");
      _writeParamComment(sink, "content", {"description": "Base64 Data of the file content to be uploaded"});
      _writeParamComment(sink, "contentType", {"description": "MimeType of the file to be uploaded"});
    }
    if (data.containsKey("parameters")) {
      data["parameters"].forEach((name, description) {
        if (!description.containsKey("gen_included")) {
          var type = parameterType[description["type"]];
          if (description.containsKey("format")) {
             if (description["type"] == "string" && description["format"] == "int64") {
               type = "core.int";
             }
          }
          if (type != null) {
            var variable = escapeParameter(cleanName(name));
            _writeParamComment(sink, variable, description);
            if (description.containsKey("repeated") && description["repeated"] == true) {
              optParams.add("core.List<$type> $variable");
            } else {
              optParams.add("$type $variable");
            }
          }
        }
      });
    }

    optParams.add("core.Map optParams");
    _writeParamComment(sink, "optParams", {"description": "Additional query parameters"});

    params.add("{${optParams.join(", ")}}");

    sink.write("   */\n");
    var response = null;
    if (data.containsKey("response")) {
      response = "async.Future<${data["response"]["\$ref"]}>";
    } else {
      response = "async.Future<core.Map>";
    }

    sink.write("  $response $name(${params.join(", ")}) {\n");
    sink.write("    var url = \"${data["path"]}\";\n");
    if (upload) {
      sink.write("    var uploadUrl = \"$uploadPath\";\n");
    }
    sink.write("    var urlParams = new core.Map();\n");
    sink.write("    var queryParams = new core.Map();\n\n");
    sink.write("    var paramErrors = new core.List();\n");

    if (data.containsKey("parameters")) {
      data["parameters"].forEach((name, description) {
        var variable = escapeParameter(cleanName(name));
        var location = "queryParams";
        if (description["location"] == "path") { location = "urlParams"; }
        if (description["required"] == true) {
          sink.write("    if ($variable == null) paramErrors.add(\"$variable is required\");\n");
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
          sink.write("    if ($variable != null && ![$list].contains($variable)) {\n");
          sink.write("      paramErrors.add(\"Allowed values for $variable: $values\");\n");
          sink.write("    }\n");
        }
        sink.write("    if ($variable != null) $location[\"$name\"] = $variable;\n");
      });
    }

    sink.write("""
    if (optParams != null) {
      optParams.forEach((key, value) {
        if (value != null && queryParams[key] == null) {
          queryParams[key] = value;
        }
      });
    }

    if (!paramErrors.isEmpty) {
      throw new core.ArgumentError(paramErrors.join(" / "));
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

    sink.write("    var response;\n");
    if (upload) {
      sink.write("    if (content != null) {\n");
      sink.write("      response = ${noResource ? "this" : "_client"}.upload(uploadUrl, \"${data["httpMethod"]}\", $uploadCall);\n");
      sink.write("    } else {\n");
      sink.write("      response = ${noResource ? "this" : "_client"}.request(url, \"${data["httpMethod"]}\", $call);\n");
      sink.write("    }\n");
    } else {
      sink.write("    response = ${noResource ? "this" : "_client"}.request(url, \"${data["httpMethod"]}\", $call);\n");
    }

    if (data.containsKey("response")) {
      sink.write("    return response\n");
      sink.write("      .then((data) => new ${data["response"]["\$ref"]}.fromJson(data));\n");
    } else {
      sink.write("    return response;\n");
    }
    sink.write("  }\n");
  }

  void _writeResourceClass(StringSink sink, String name, Map data) {
    var className = "${capitalize(name)}Resource_";

    sink.write("class $className extends Resource {\n");

    if (data.containsKey("resources")) {
      sink.write("\n");
      data["resources"].forEach((key, resource) {
        var subClassName = "${capitalize(name)}${capitalize(key)}Resource_";
        sink.write("  $subClassName _$key;\n");
        sink.write("  $subClassName get $key => _$key;\n");
      });
    }

    sink.write("\n  $className(Client client) : super(client) {\n");
    if (data.containsKey("resources")) {
      data["resources"].forEach((key, resource) {
        var subClassName = "${capitalize(name)}${capitalize(key)}Resource_";
        sink.write("  _$key = new $subClassName(client);\n");
      });
    }
    sink.write("  }\n");

    if (data.containsKey("methods")) {
      data["methods"].forEach((key, method) {
        sink.write("\n");
        _writeMethod(sink, key, method);
      });
    }

    sink.write("}\n\n");

    if (data.containsKey("resources")) {
      data["resources"].forEach((key, resource) {
        _writeResourceClass(sink, "${capitalize(name)}${capitalize(key)}", resource);
      });
    }
  }

  String get _rootUriOrigin => Uri.parse(_json['rootUrl']).origin;

  String get _createClientClass => """
part of $_libraryName;

/**
 * Base class for all API clients, offering generic methods for HTTP Requests to the API
 */
abstract class Client {
  core.String basePath = \"${_json["basePath"]}\";
  core.String rootUrl = \"${_rootUriOrigin}/\";
  core.bool makeAuthRequests = false;
  final core.Map params = {};

  static const _boundary = "-------314159265358979323846";
  static const _delimiter = "\\r\\n--\$_boundary\\r\\n";
  static const _closeDelim = "\\r\\n--\$_boundary--";

  /**
   * Sends a HTTPRequest using [method] (usually GET or POST) to [requestUrl] using the specified [urlParams] and [queryParams]. Optionally include a [body] in the request.
   */
  async.Future request(core.String requestUrl, core.String method, {core.String body, core.String contentType:"application/json", core.Map urlParams, core.Map queryParams});

  /**
   * Joins [content] (encoded as Base64-String) with specified [contentType] and additional request [body] into one multipart-body and send a HTTPRequest with [method] (usually POST) to [requestUrl]
   */
  async.Future upload(core.String requestUrl, core.String method, core.String body, core.String content, core.String contentType, {core.Map urlParams, core.Map queryParams}) {
    var multiPartBody = new core.StringBuffer();
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
  final Client _client;

  /// Create a new Resource, using the specified [Client] for requests
  Resource(Client this._client);
}

/// Exception thrown when the HTTP Request to the API failed
class APIRequestException implements core.Exception {
  final core.String msg;
  const APIRequestException([this.msg]);
  core.String toString() => (msg == null) ? "APIRequestException" : "APIRequestException: \$msg";
}
""";

  String get _createBrowserClientClass => """
part of $_libraryBrowserName;

/**
 * Base class for all Browser API clients, offering generic methods for HTTP Requests to the API
 */
abstract class BrowserClient extends Client {

  oauth.OAuth2 get auth;
  core.bool _jsClientLoaded = false;

  /**
   * Loads the JS Client Library to make CORS-Requests
   */
  async.Future<core.bool> _loadJsClient() {
    var completer = new async.Completer();

    if (_jsClientLoaded) {
      completer.complete(true);
      return completer.future;
    }

    js.scoped((){
      js.context["handleClientLoad"] =  new js.Callback.once(() {
        _jsClientLoaded = true;
        completer.complete(true);
      });
    });

    html.ScriptElement script = new html.ScriptElement();
    script.src = "http://apis.google.com/js/client.js?onload=handleClientLoad";
    script.type = "text/javascript";
    html.document.body.children.add(script);

    return completer.future;
  }

  /**
   * Makes a request via the JS Client Library to circumvent CORS-problems
   */
  async.Future _makeJsClientRequest(core.String requestUrl, core.String method, {core.String body, core.String contentType, core.Map queryParams}) {
    var completer = new async.Completer();
    var requestData = new core.Map();
    requestData["path"] = requestUrl;
    requestData["method"] = method;
    requestData["headers"] = new core.Map();

    if (queryParams != null) {
      requestData["params"] = queryParams;
    }

    if (body != null) {
      requestData["body"] = body;
      requestData["headers"]["Content-Type"] = contentType;
    }
    if (makeAuthRequests && auth != null && auth.token != null) {
      requestData["headers"]["Authorization"] = "\${auth.token.type} \${auth.token.data}";
    }

    js.scoped(() {
      var request = js.context["gapi"]["client"]["request"](js.map(requestData));
      var callback = new js.Callback.once((jsonResp, rawResp) {
        if (jsonResp == null || (jsonResp is core.bool && jsonResp == false)) {
          var raw = JSON.parse(rawResp);
          if (raw["gapiRequest"]["data"]["status"] >= 400) {
            completer.completeError(new APIRequestException("JS Client - \${raw["gapiRequest"]["data"]["status"]} \${raw["gapiRequest"]["data"]["statusText"]} - \${raw["gapiRequest"]["data"]["body"]}"));
          } else {
            completer.complete({});
          }
        } else {
          completer.complete(js.context["JSON"]["stringify"](jsonResp));
        }
      });
      request.execute(callback);
    });

    return completer.future;
  }

  /**
   * Sends a HTTPRequest using [method] (usually GET or POST) to [requestUrl] using the specified [urlParams] and [queryParams]. Optionally include a [body] in the request.
   */
  async.Future request(core.String requestUrl, core.String method, {core.String body, core.String contentType:"application/json", core.Map urlParams, core.Map queryParams}) {
    var request = new html.HttpRequest();
    var completer = new async.Completer();

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
    var url = new oauth.UrlPattern(path).generate(urlParams, queryParams);

    void handleError() {
      if (request.status == 0) {
        _loadJsClient().then((v) {
          if (requestUrl.substring(0,1) == "/") {
            path = requestUrl;
          } else {
            path ="\$basePath\$requestUrl";
          }
          url = new oauth.UrlPattern(path).generate(urlParams, {});
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
          } on core.FormatException {
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

    request.onLoad.listen((_) {
      if (request.status > 0 && request.status < 400) {
        var data = {};
        if (!request.responseText.isEmpty) {
          data = JSON.parse(request.responseText);
        }
        completer.complete(data);
      } else {
        handleError();
      }
    });

    request.onError.listen((_) => handleError());

    request.open(method, url);
    request.setRequestHeader("Content-Type", contentType);
    if (makeAuthRequests && auth != null) {
      auth.authenticate(request).then((request) => request.send(body));
    } else {
      request.send(body);
    }

    return completer.future;
  }
}
""";

  String get _createConsoleClientClass => """
part of $_libraryConsoleName;

/**
 * Base class for all Console API clients, offering generic methods for HTTP Requests to the API
 */
abstract class ConsoleClient extends Client {

  oauth2.OAuth2Console get auth;

  /**
   * Sends a HTTPRequest using [method] (usually GET or POST) to [requestUrl] using the specified [urlParams] and [queryParams]. Optionally include a [body] in the request.
   */
  async.Future<core.Map<core.String, core.Object>> request(core.String requestUrl, core.String method, {core.String body, core.String contentType:"application/json", core.Map urlParams, core.Map queryParams}) {
    if (urlParams == null) urlParams = {};
    if (queryParams == null) queryParams = {};

    params.forEach((key, param) {
      if (param != null && queryParams[key] == null) {
        queryParams[key] = param;
      }
    });

    method = method.toLowerCase();

    var path;
    if (requestUrl.substring(0,1) == "/") {
      path ="\$rootUrl\${requestUrl.substring(1)}";
    } else {
      path ="\$rootUrl\${basePath.substring(1)}\$requestUrl";
    }

    var url = new oauth2.UrlPattern(path).generate(urlParams, queryParams);
    var uri = core.Uri.parse(url);

    if (makeAuthRequests && auth != null) {
      // Client wants an authenticated request.
      return auth.withClient((r) => _request(r, method, uri, contentType, body));
    } else {
      // Client wants a non authenticated request.
      return _request(new http.Client(), method, uri, contentType, body);
    }
  }

  async.Future<core.Map<core.String, core.Object>> _request(http.Client client, core.String method, core.Uri uri,
                        core.String contentType, core.String body) {
    var request = new http.Request(method, uri)
      ..headers[io.HttpHeaders.CONTENT_TYPE] = contentType;

    if(body != null) {
      request.body = body;
    }

    return client.send(request)
        .then(http.Response.fromStream)
        .then((http.Response response) {
          if(response.body.isEmpty) {
            return null;
          }
          return JSON.parse(response.body);
        })
        .whenComplete(() {
          client.close();
        });
  }
}
""";

  String get _createHopRunner => """
library hop_runner;

import 'package:hop/hop.dart';
import 'package:hop/hop_tasks.dart';

void main() {

  List pathList = [
    'lib/$_libraryBrowserName.dart',
    'lib/$_libraryConsoleName.dart',
    'lib/$_libraryName.dart'
  ];

  addTask('docs', createDartDocTask(pathList, linkApi: true));

  addTask('analyze', createAnalyzerTask(pathList));

  runHop();
}
""";
}
