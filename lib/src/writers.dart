part of discovery_api_client_generator;

void _writeSchemaClass(StringSink sink, String name, JsonSchema data) {
  if (data.description != null) {
    sink.writeln('/** ${data.description} */');
  }

  sink.writeln('class ${capitalize(name)} {');

  var props = new List<CoreSchemaProp>();

  if(data.properties != null) {
    data.properties.forEach((key, JsonSchema property) {
      var prop = new CoreSchemaProp.parse(name, key, property);
      props.add(prop);
    });
  } else {
    print('\tWeird to get no properties for $name');
    print('\t\t${JSON.encode(data)}');
  }

  props.forEach((property) {
    property.writeField(sink);
  });

  sink.writeln();
  sink.writeln('  /** Create new $name from JSON data */');
  sink.writeln('  ${capitalize(name)}.fromJson(core.Map json) {');
  props.forEach((property) {
    property.writeFromJson(sink);
  });

  sink.writeln('  }');
  sink.writeln();

  sink.writeln('  /** Create JSON Object for $name */');
  sink.writeln('  core.Map toJson() {');
  sink.writeln('    var output = new core.Map();');
  sink.writeln();
  props.forEach((property) {
    property.writeToJson(sink);
  });
  sink.writeln('\n    return output;');
  sink.writeln('  }');
  sink.writeln();

  sink.writeln('  /** Return String representation of $name */');
  sink.writeln('  core.String toString() => JSON.encode(this.toJson());');
  sink.writeln();

  sink.writeln('}');
  sink.writeln();

  props.forEach((property) {
    property.getSubSchemas().forEach((String key, JsonSchema value) {
      _writeSchemaClass(sink, key, value);
    });
  });
}

void _writeParamCommentHeader(StringSink sink, String name, String description) {
  sink.writeln('   *');
  sink.write("   * [$name]");
  if (description != null) {
    sink.write(" - ${description}");
  }
  sink.writeln();
}

void _writeParamComment(StringSink sink, String name, JsonSchema description) {
  _writeParamCommentHeader(sink, name, description.description);
  if (description.defaultProperty != null) {
    sink.writeln('   *   Default: ${description.defaultProperty}');
  }
  if (description.minimum != null) {
    sink.writeln('   *   Minimum: ${description.minimum}');
  }
  if (description.maximum != null) {
    sink.writeln('   *   Maximum: ${description.maximum}');
  }
  if (description.repeated == true) {
    sink.writeln('   *   Repeated values: allowed');
  }
  if (description.enumProperty != null) {
    sink.writeln('   *   Allowed values:');
    for (var i = 0; i < description.enumProperty.length; i++) {
      sink.write("   *     ${description.enumProperty[i]}");
      if (description.enumDescriptions != null) {
        sink.write(" - ${description.enumDescriptions[i]}");
      }
      sink.writeln();
    }
  }
}

/// Create a method with [name] inside of a class, based on [data]
void _writeMethod(StringSink sink, String name, RestMethod data, [bool noResource = false]) {
  String uploadPath = null;

  name = escapeMethod(cleanName(name));

  sink.writeln('  /**');
  if (data.description != null) {
    sink.writeln('   * ${data.description}');
  }

  var genIncluded = new Set<JsonSchema>();

  var params = new List<String>();
  var optParams = new List<String>();

  if (data.request != null) {
    params.add("${data.request.$ref} request");
    _writeParamCommentHeader(sink, "request", "${data.request.$ref} to send in this request");
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

  sink.writeln('   */');
  var response = null;
  if (data.response != null) {
    response = "async.Future<${data.response.$ref}>";
  } else {
    response = "async.Future<core.Map>";
  }

  sink.writeln('  $response $name(${params.join(", ")}) {');
  sink.writeln('    var url = \"${data.path}\";');
  if (uploadPath != null) {
    sink.writeln('    var uploadUrl = \"$uploadPath\";');
  }
  sink.writeln('    var urlParams = new core.Map();');
  sink.writeln('    var queryParams = new core.Map();');
  sink.writeln();
  sink.writeln('    var paramErrors = new core.List();');

  if (data.parameters != null) {
    data.parameters.forEach((name, JsonSchema description) {
      var variable = escapeParameter(cleanName(name));
      var location = "queryParams";
      if (description.location == "path") { location = "urlParams"; }
      if (description.required == true) {
        sink.writeln('    if ($variable == null) paramErrors.add(\"$variable is required\");');
      }
      if(description.enumProperty != null) {
        var list = description.enumProperty.map((i) => "\"$i\"").join(', ');
        var values = description.enumProperty.join(', ');
        sink.writeln('    if ($variable != null && ![$list].contains($variable)) {');
        sink.writeln('      paramErrors.add(\"Allowed values for $variable: $values\");');
        sink.writeln('    }');
      }
      sink.writeln('    if ($variable != null) $location[\"$name\"] = $variable;');
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

  sink.writeln('    var response;');
  if (uploadPath != null) {
    sink.writeln('    if (content != null) {');
    sink.writeln('      response = ${noResource ? "this" : "_client"}.upload(uploadUrl, \"${data.httpMethod}\", $uploadCall);');
    sink.writeln('    } else {');
    sink.writeln('      response = ${noResource ? "this" : "_client"}.request(url, \"${data.httpMethod}\", $call);');
    sink.writeln('    }');
  } else {
    sink.writeln('    response = ${noResource ? "this" : "_client"}.request(url, \"${data.httpMethod}\", $call);');
  }

  if (data.response != null) {
    sink.writeln('    return response');
    sink.writeln('      .then((data) => new ${data.response.$ref}.fromJson(data));');
  } else {
    sink.writeln('    return response;');
  }
  sink.writeln('  }');
}

void _writeResourceClass(StringSink sink, String name, RestResource data) {
  var className = "${capitalize(name)}Resource_";

  sink.writeln("class $className {");
  sink.writeln();
  sink.writeln('  final Client _client;');

  if (data.resources != null) {
    sink.writeln();
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
      sink.writeln();
      _writeMethod(sink, key, method);
    });
  }

  sink.writeln('}');
  sink.writeln();

  if (data.resources != null) {
    data.resources.forEach((key, RestResource resource) {
      _writeResourceClass(sink, "${capitalize(name)}${capitalize(key)}", resource);
    });
  }
}
