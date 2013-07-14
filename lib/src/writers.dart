part of discovery_api_client_generator;

void _writeSchemaClass(StringSink sink, String name, JsonSchema data) {
  if (data.description != null) {
    sink.write("/** ${data.description} */\n");
  }

  sink.write("class ${capitalize(name)} {\n");

  var props = new List<CoreSchemaProp>();

  if(data.properties != null) {
    data.properties.forEach((key, JsonSchema property) {
      var prop = new CoreSchemaProp.parse(name, key, property);
      props.add(prop);
    });
  } else {
    print('\tWeird to get no properties for $name');
    print('\t\t${JSON.stringify(data)}');
  }

  props.forEach((property) {
    property.writeField(sink);
  });

  sink.write("\n");
  sink.write("  /** Create new $name from JSON data */\n");
  sink.write("  ${capitalize(name)}.fromJson(core.Map json) {\n");
  props.forEach((property) {
    property.writeFromJson(sink);
  });

  sink.write("  }\n\n");

  sink.write("  /** Create JSON Object for $name */\n");
  sink.write("  core.Map toJson() {\n");
  sink.write("    var output = new core.Map();\n\n");
  props.forEach((property) {
    property.writeToJson(sink);
  });
  sink.write("\n    return output;\n");
  sink.write("  }\n\n");

  sink.write("  /** Return String representation of $name */\n");
  sink.write("  core.String toString() => JSON.stringify(this.toJson());\n\n");

  sink.write("}\n\n");

  props.forEach((property) {
    property.getSubSchemas().forEach((String key, JsonSchema value) {
      _writeSchemaClass(sink, key, value);
    });
  });
}

void _writeParamCommentHeader(StringSink sink, String name, String description) {
  sink.write("   *\n");
  sink.write("   * [$name]");
  if (description != null) {
    sink.write(" - ${description}");
  }
  sink.write("\n");
}

void _writeParamComment(StringSink sink, String name, JsonSchema description) {
  _writeParamCommentHeader(sink, name, description.description);
  if (description.defaultProperty != null) {
    sink.write("   *   Default: ${description.defaultProperty}\n");
  }
  if (description.minimum != null) {
    sink.write("   *   Minimum: ${description.minimum}\n");
  }
  if (description.maximum != null) {
    sink.write("   *   Maximum: ${description.maximum}\n");
  }
  if (description.repeated == true) {
    sink.write("   *   Repeated values: allowed\n");
  }
  if (description.enumProperty != null) {
    sink.write("   *   Allowed values:\n");
    for (var i = 0; i < description.enumProperty.length; i++) {
      sink.write("   *     ${description.enumProperty[i]}");
      if (description.enumDescriptions != null) {
        sink.write(" - ${description.enumDescriptions[i]}");
      }
      sink.write("\n");
    }
  }
}

/// Create a method with [name] inside of a class, based on [data]
void _writeMethod(StringSink sink, String name, RestMethod data, [bool noResource = false]) {
  String uploadPath = null;

  name = escapeMethod(cleanName(name));

  sink.write("  /**\n");
  if (data.description != null) {
    sink.write("   * ${data.description}\n");
  }

  var genIncluded = new Set<JsonSchema>();

  var params = new List<String>();
  var optParams = new List<String>();

  if (data.request != null) {
    params.add("${_getRef(data.request)} request");
    _writeParamCommentHeader(sink, "request", "${_getRef(data.request)} to send in this request");
  }
  if (data.parameterOrder != null && data.parameters != null) {
    data.parameterOrder.forEach((param) {
      if (data.parameters.containsKey(param)) {
        var paramSchema = data.parameters[param];
        var type = _getDartType(paramSchema);
        var variable = escapeParameter(cleanName(param));
        _writeParamComment(sink, variable, paramSchema);
        if (paramSchema.repeated == true) {
          params.add("core.List<$type> $variable");
        } else {
          params.add("$type $variable");
        }
        genIncluded.add(paramSchema);
      }
    });
  }

  if (data.mediaUpload != null) {
    uploadPath = data.mediaUpload.protocols.simple.path;
  }

  if (uploadPath != null) {
    optParams.add("core.String content");
    optParams.add("core.String contentType");
    _writeParamCommentHeader(sink, "content", "Base64 Data of the file content to be uploaded");
    _writeParamCommentHeader(sink, "contentType", "MimeType of the file to be uploaded");
  }
  if (data.parameters != null) {
    data.parameters.forEach((name, JsonSchema description) {
      if (!genIncluded.contains(description)) {
        var type = _getDartType(description);
        var variable = escapeParameter(cleanName(name));
        _writeParamComment(sink, variable, description);
        if (description.repeated == true) {
          optParams.add("core.List<$type> $variable");
        } else {
          optParams.add("$type $variable");
        }
      }
    });
  }

  optParams.add("core.Map optParams");
  _writeParamCommentHeader(sink, "optParams", "Additional query parameters");

  params.add("{${optParams.join(", ")}}");

  sink.write("   */\n");
  var response = null;
  if (data.response != null) {
    response = "async.Future<${_getRef(data.response)}>";
  } else {
    response = "async.Future<core.Map>";
  }

  sink.write("  $response $name(${params.join(", ")}) {\n");
  sink.write("    var url = \"${data.path}\";\n");
  if (uploadPath != null) {
    sink.write("    var uploadUrl = \"$uploadPath\";\n");
  }
  sink.write("    var urlParams = new core.Map();\n");
  sink.write("    var queryParams = new core.Map();\n\n");
  sink.write("    var paramErrors = new core.List();\n");

  if (data.parameters != null) {
    data.parameters.forEach((name, JsonSchema description) {
      var variable = escapeParameter(cleanName(name));
      var location = "queryParams";
      if (description.location == "path") { location = "urlParams"; }
      if (description.required == true) {
        sink.write("    if ($variable == null) paramErrors.add(\"$variable is required\");\n");
      }
      if(description.enumProperty != null) {
        var list = description.enumProperty.map((i) => "\"$i\"").join(', ');
        var values = description.enumProperty.join(', ');
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
  if (data.request != null) {
    call = "body: request.toString(), urlParams: urlParams, queryParams: queryParams";
    uploadCall = "request.toString(), content, contentType, urlParams: urlParams, queryParams: queryParams";
  } else {
    call = "urlParams: urlParams, queryParams: queryParams";
    uploadCall = "null, content, contentType, urlParams: urlParams, queryParams: queryParams";
  }

  sink.write("    var response;\n");
  if (uploadPath != null) {
    sink.write("    if (content != null) {\n");
    sink.write("      response = ${noResource ? "this" : "_client"}.upload(uploadUrl, \"${data.httpMethod}\", $uploadCall);\n");
    sink.write("    } else {\n");
    sink.write("      response = ${noResource ? "this" : "_client"}.request(url, \"${data.httpMethod}\", $call);\n");
    sink.write("    }\n");
  } else {
    sink.write("    response = ${noResource ? "this" : "_client"}.request(url, \"${data.httpMethod}\", $call);\n");
  }

  if (data.response != null) {
    sink.write("    return response\n");
    sink.write("      .then((data) => new ${_getRef(data.response)}.fromJson(data));\n");
  } else {
    sink.write("    return response;\n");
  }
  sink.write("  }\n");
}

void _writeResourceClass(StringSink sink, String name, RestResource data) {
  var className = "${capitalize(name)}Resource_";

  sink.writeln("class $className {");
  sink.writeln();
  sink.writeln('  final Client _client;');

  if (data.resources != null) {
    sink.writeln('');
    data.resources.forEach((key, RestResource resource) {
      var subClassName = "${capitalize(name)}${capitalize(key)}Resource_";
      sink.writeln('  final $subClassName $key;');
    });
  }

  sink.writeln("\n  $className(Client client) :");
  sink.write('      _client = client');
  if (data.resources == null) {
    sink.writeln(";");
  } else {
    data.resources.forEach((key, RestResource resource) {
      sink.writeln(",");
      var subClassName = "${capitalize(name)}${capitalize(key)}Resource_";
      sink.write('      $key = new $subClassName(client)');
    });
    sink.writeln(";");
  }

  if (data.methods != null) {
    data.methods.forEach((key, RestMethod method) {
      sink.write("\n");
      _writeMethod(sink, key, method);
    });
  }

  sink.write("}\n\n");

  if (data.resources != null) {
    data.resources.forEach((key, RestResource resource) {
      _writeResourceClass(sink, "${capitalize(name)}${capitalize(key)}", resource);
    });
  }
}
