part of discovery_api_client_generator;

/**
 * Represents a parameter to a resource method.
 */
class MethodParameter {
  final Identifier name;
  final Comment comment;
  final DartSchemaType type;
  final bool required;

  /**
   * [jsonName] may be null if this parameter is the request object parameter.
   */
  final String jsonName;

  /**
   * [encodeInPath] is
   *   - `true` if this parameter is encoded in the path of URL.
   *   - `false` if this parameter is encoded in the query part of the URL.
   *   - `null` otherwise.
   */
  final bool encodedInPath;

  MethodParameter(this.name, this.comment, this.required, this.type,
                  this.jsonName, this.encodedInPath);

  /**
   * Returns the declaration "Type name" of this method parameter.
   */
  String get declaration => '${type.declaration} $name';
}


/**
 * Represents a method on a resource class.
 */
class DartResourceMethod {
  /**
   * [requestParameter] may be [:null:].
   */
  final MethodParameter requestParameter;

  /**
   * [returnType] may be [:null:].
   */
  final DartSchemaType returnType;

  final Comment comment;

  final DartApiImports imports;

  final Identifier name;
  final List<MethodParameter> parameters;
  final List<MethodParameter> namedParameters;
  final String jsonName;
  final String urlPattern;
  final String httpMethod;
  final bool mediaUpload;
  final bool mediaDownload;
  final RestMethodMediaUpload mediaUploadSpec;

  DartResourceMethod(this.imports, this.name, this.comment,
                     this.requestParameter, this.parameters,
                     this.namedParameters, this.returnType,
                     this.jsonName, this.urlPattern, this.httpMethod,
                     this.mediaUpload, this.mediaDownload,
                     this.mediaUploadSpec);

  String get signature {
    var parameterString = new StringBuffer();

    // If a request object was defined, it is always the first parameter.
    if (requestParameter != null) {
      parameterString.write('${requestParameter.declaration}');
    }

    // Normal positional parameters are following.
    if (parameters.length > 0) {
      if (!parameterString.isEmpty) parameterString.write(', ');
      parameterString
          .write(parameters.map((param) => '${param.declaration}')
          .join(', '));
    }

    // Optional parameters are comming last (including the media parameters).
    if (namedParameters.length > 0 || mediaUpload || mediaDownload) {
      if (!parameterString.isEmpty) parameterString.write(', ');

      var namedString = new StringBuffer()
          ..write(namedParameters
                  .map((param) => '${param.declaration}')
                  .join(', '));

      if (mediaUpload) {
        if (!namedString.isEmpty) namedString.write(', ');
        namedString.write('${imports.external}.Media uploadMedia');
      }

      if (mediaDownload) {
        if (!namedString.isEmpty) namedString.write(', ');
        namedString.write('${imports.core}.bool downloadAsMedia: false');
      }

      parameterString.write('{$namedString}');
    }

    var genericReturnType = '';
    // NOTE: Media downloads are optional, so we cannot return [Media] as type.
    if (returnType != null && !mediaDownload) {
      genericReturnType = '<${returnType.declaration}>';
    }
    return '${imports.async}.Future$genericReturnType $name($parameterString)';
  }

  String get definition {
    var params = new StringBuffer();

    var commentBuilder = new StringBuffer();
    commentBuilder.writeln(comment.rawComment);
    commentBuilder.writeln();

    parameters.forEach((p) {
      commentBuilder.writeln('[${p.name}] - ${p.comment.rawComment}\n');
    });
    namedParameters.forEach((p) {
      commentBuilder.writeln('[${p.name}] - ${p.comment.rawComment}\n');
    });
    var methodComment = new Comment('$commentBuilder');

    if (requestParameter != null) {
      var parameterEncode =
          requestParameter.type.jsonEncode('${requestParameter.name}');
      params.writeln('    if (${requestParameter.name} != null) {');
      params.writeln(
          '      _body = ${imports.convert}.JSON.encode(${parameterEncode});');
      params.writeln('    }');
    }

    encodeQueryParam(MethodParameter param, String mapName) {
      var propertyAssignment =
          '_addParameter'
          '($mapName, "${escapeString(param.jsonName)}", ${param.name});';

      if (param.required) {
        if (param.type is UnnamedArrayType) {
          params.writeln(
              '    if (${param.name} == null || ${param.name}.isEmpty) {');
        } else {
          params.writeln('    if (${param.name} == null) {');
        }
        params.writeln('      throw new ${imports.core}.ArgumentError'
                       '("Parameter ${param.name} is required.");');
        params.writeln('    }');
        params.writeln('    $propertyAssignment');
      } else {
        params.writeln('    if (${param.name} != null) {');
        params.writeln('      $propertyAssignment');
        params.writeln('    }');
      }
      if (param.encodedInPath) {
        params.writeln();
      }
    }
    parameters.forEach((p) {
      if (p.encodedInPath) {
        encodeQueryParam(p, '_urlParams');
      } else {
        encodeQueryParam(p, '_queryParams');
      }
    });
    namedParameters.forEach(( p) {
      if (p.encodedInPath) {
        encodeQueryParam(p, '_urlParams');
      } else {
        encodeQueryParam(p, '_queryParams');
      }
    });

    params.writeln('');

    var requestCode = new StringBuffer();
    if (mediaUpload) {
      requestCode.writeln('    _uploadMedia =  uploadMedia;');
    }
    if (mediaDownload) {
      requestCode.writeln('    _downloadAsMedia = downloadAsMedia;');
    }

    // FIXME: We need to pass this differently.
    var uploadPath = '';
    if (mediaUpload) {
      if (mediaUploadSpec == null ||
          mediaUploadSpec.protocols.simple.path == null) {
        throw new StateError('Simple uploads are not supported.');
      }
      uploadPath =
          ', uploadMediaPath: "${mediaUploadSpec.protocols.simple.path}"';
    }

    var plainResponse =
        returnType != null ? returnType.jsonDecode('data') : 'null';
    if (mediaDownload) {
      requestCode.write(
'''
    if (_downloadAsMedia) {
      return _httpClient.requestMedia(_url, "$httpMethod",
                                      body: _body,
                                      urlParams: _urlParams,
                                      queryParams: _queryParams,
                                      uploadMedia: _uploadMedia$uploadPath);
    } else {
      var _response = _httpClient.request(_url,
                                          "$httpMethod",
                                          body: _body,
                                          urlParams: _urlParams,
                                          queryParams: _queryParams,
                                          uploadMedia: _uploadMedia$uploadPath);
      return _response.then((data) => $plainResponse);
    }
'''
      );
    } else {
      requestCode.write(
'''
    var _response = _httpClient.request(_url,
                                        "$httpMethod",
                                        body: _body,
                                        urlParams: _urlParams,
                                        queryParams: _queryParams,
                                        uploadMedia: _uploadMedia$uploadPath);
    return _response.then((data) => $plainResponse);
'''
      );
    }
    var methodString = new StringBuffer();
    methodString.write(methodComment.asDartDoc(2));
    methodString.writeln('  $signature {');

    methodString.write('''
    var _url = "${escapeString(urlPattern)}";
    var _urlParams = new ${imports.core}.Map();
    var _queryParams = new ${imports.core}.Map();
    var _uploadMedia = null;
    var _downloadAsMedia = false;
    var _body = null;

    _addParameter(params, ${imports.core}.String name, value) {
      var values = params.putIfAbsent(name, () => []);
      values.add(value);
    }

$params$requestCode''');

    methodString.writeln('  }');

    return '$methodString';
  }
}


/**
 * Represents a resource of an Apiary API.
 */
class DartResourceClass {
  final DartApiImports imports;
  final Identifier className;
  final Comment comment;
  final List<DartResourceMethod> methods;

  final List<Identifier> subResourceIdentifiers;
  final List<DartResourceClass> subResources;

  DartResourceClass(this.imports, this.className, this.comment, this.methods,
                    this.subResourceIdentifiers, this.subResources);

  String get fields {
    var str = new StringBuffer();
    for (var i = 0; i < subResourceIdentifiers.length; i++) {
      var identifier = subResourceIdentifiers[i];
      var resource = subResources[i];
      str.writeln('  ${resource.className} get ${identifier.name} '
                  '=> new ${resource.className}(_httpClient);');
    }
    if (!str.isEmpty) str.writeln();
    return '$str';
  }

  String get constructor {
    var str = new StringBuffer();
    str.writeln('  $className(${imports.internal}.ApiRequester client) : ');
    str.writeln('      _httpClient = client;');
    return '$str';
  }

  String get functions {
    var str = new StringBuffer();
    methods.forEach((DartResourceMethod m) {
      str.writeln(m.definition);
    });
    return !str.isEmpty ? '\n$str' : '';
  }

  String getClassDefinition() {
    var str = new StringBuffer();
    str.write(comment.asDartDoc(0));
    str.writeln('class $className {');
    str.writeln('  final ${imports.internal}.ApiRequester _httpClient;');
    str.writeln('');
    str.write('$fields$constructor$functions');
    str.writeln('}');
    return '$str';
  }
}


/**
 * Represents the API resource of an Apiary API.
 */
class DartApiClass extends DartResourceClass {
  // TODO: parameters (like prettyPrint)
  // TODO: scopes
  // TODO: Url base?
  final String rootUrl;
  final String basePath;

  DartApiClass(DartApiImports imports,
               Identifier name,
               Comment comment,
               List<DartResourceMethod> methods,
               List<Identifier> subResourceIdentifiers,
               List<DartResourceClass> subResources,
               this.rootUrl, this.basePath)
      : super(imports, name, comment, methods,
              subResourceIdentifiers, subResources);

  String get constructor {
    var str = new StringBuffer();
    str.writeln('  $className(${imports.httpBase}.Client client) : ');
    str.write('      _httpClient = new ${imports.internal}.ApiRequester'
              '(client, "${escapeString(rootUrl)}", '
              '"${escapeString(basePath)}")');
    str.writeln(';');
    return '$str';
  }
}


/**
 * Parses all resources in [description] and returns the root [DartApiClass].
 */
DartApiClass parseResources(DartApiImports imports,
                            DartSchemaTypeDB db,
                            RestDescription description) {
  DartResourceClass parseResource(String resourceName,
                                  String resourceDescription,
                                  Map<String, RestMethod> methods,
                                  Map<String, RestResource> subResources,
                                  String parentName) {
    DartResourceMethod parseMethod(Scope classScope,
                                   String jsonName,
                                   RestMethod method) {
      var methodName = classScope.newIdentifier(jsonName, public: true);
      var parameterScope = classScope.newChildScope();

      // This set will be reduced to all optional parameters.
      var pendingParameterNames = method.parameters != null
          ? method.parameters.keys.toSet() : new Set<String>();

      // TODO: Handle parameters with `parameter.repeated == true`.

      var positionalParameters = new List<MethodParameter>();
      tryEnqueuePositionalParameter(String jsonName,
                                    Comment comment,
                                    JsonSchema schema) {
        if (!pendingParameterNames.contains(jsonName)) return;

        var parameter = method.parameters[jsonName];
        if (parameter.required == true) {
          var name = parameterScope.newIdentifier(jsonName);
          pendingParameterNames.remove(jsonName);
          var type = parseResolved(imports, db, parameter);
          positionalParameters.add(new MethodParameter(
              name, comment, true, type, jsonName,
              parameter.location != 'query'));
        }
      }

      var optionalParameters = new List<MethodParameter>();
      enqueueOptionalParameter(String jsonName,
                               Comment comment,
                               JsonSchema schema) {
        var name = parameterScope.newIdentifier(jsonName);
        var parameter = method.parameters[jsonName];
        var type = parseResolved(imports, db, parameter);
        optionalParameters.add(new MethodParameter(
            name, comment, false, type, jsonName,
            parameter.location != 'query'));
      }

      DartSchemaType getValidReference(String ref) {
        var type = db.namedSchemaTypes[ref];
        if (type == null) {
          throw new ArgumentError(
              'Could not find reference ${method.request.$ref}.');
        }
        return type;
      }

      // Enqueue positional parameters with a given order first.
      if (method.parameterOrder != null) {
        for (var jsonName in method.parameterOrder) {
          if (method.parameters == null ||
              !method.parameters.keys.contains(jsonName)) {
            throw new GeneratorError(
                description.name,
                description.version,
                'Parameters for method $jsonName does not have a type!');
          }
          var comment = new Comment(method.parameters[jsonName].description);

          tryEnqueuePositionalParameter(
              jsonName, comment, method.parameters[jsonName]);
        }
      }

      // If we have more required parameters than in `method.parameterOrder`
      // we append them at the end.
      if (method.parameters != null) {
        method.parameters.forEach((String jsonName, JsonSchema parameter) {
          var comment = new Comment(parameter.description);
          tryEnqueuePositionalParameter(
              jsonName, comment, method.parameters[jsonName]);
        });
      }

      // The remaining parameters are optional.
      for (var jsonName in pendingParameterNames) {
        var comment = new Comment(method.parameters[jsonName].description);
        enqueueOptionalParameter(
            jsonName, comment, method.parameters[jsonName]);
      }

      // Check if we have a request object, if so parse it's type.
      var dartRequestParameter = null;
      if (method.request != null) {
        var type = getValidReference(method.request.$ref);
        // FIXME: Is `required: true` really the right thing?
        var requestName = parameterScope.newIdentifier('request');
        var comment = new Comment('Request object');
        dartRequestParameter =
            new MethodParameter(requestName, comment, true, type, null, null);
      }

      var dartResponseType = null;
      if (method.response != null) {
        dartResponseType = getValidReference(method.response.$ref);
      }

      var comment = new Comment(method.description);

      makeBoolean(bool x) => x != null ? x : false;

      return new DartResourceMethod(imports, methodName, comment,
          dartRequestParameter,
          positionalParameters, optionalParameters, dartResponseType, jsonName,
          method.path, method.httpMethod,
          makeBoolean(method.supportsMediaUpload),
          makeBoolean(method.supportsMediaDownload), method.mediaUpload);
    }

    bool topLevel = parentName.isEmpty;

    var namer = imports.namer;
    Identifier className;
    if (topLevel) {
      className = namer.apiClass(resourceName);
    } else {
      className = namer.resourceClass(resourceName, parent: parentName);
    }
    var classScope = namer.newClassScope();

    var dartMethods = [];
    if (methods != null) {
      orderedForEach(methods, (String jsonName, RestMethod method) {
        var dartMethod = parseMethod(classScope, jsonName, method);
        dartMethods.add(dartMethod);
      });
    }

    var dartSubResourceIdentifiers = [];
    var dartSubResource = [];
    if (subResources != null) {
      orderedForEach(subResources, (String jsonName, RestResource resource) {
        var instanceName = classScope.newIdentifier(jsonName, public: true);
        var dartResource = parseResource(
            jsonName, '', resource.methods, resource.resources,
            className.preferredName);
        dartSubResourceIdentifiers.add(instanceName);
        dartSubResource.add(dartResource);
      });
    }

    var coment = new Comment(resourceDescription);
    if (topLevel) {
      return new DartApiClass(
          imports, className, coment, dartMethods, dartSubResourceIdentifiers,
          dartSubResource, description.rootUrl, description.basePath);
    } else {
      return new DartResourceClass(
          imports, className, coment, dartMethods, dartSubResourceIdentifiers,
          dartSubResource);
    }
  }
  return parseResource(description.name,
                       description.description,
                       description.methods,
                       description.resources,
                       '');
}


/**
 * Generates a string representation of all resource classes, beginning with
 * [apiClass].
 */
String generateResources(DartApiClass apiClass) {
  var sb = new StringBuffer();
  writeResourceClass(DartResourceClass resource) {
    sb.writeln(resource.getClassDefinition());
    sb.writeln();
    resource.subResources.forEach((subResource) {
      writeResourceClass(subResource);
    });
  }
  writeResourceClass(apiClass);
  return '$sb';
}
