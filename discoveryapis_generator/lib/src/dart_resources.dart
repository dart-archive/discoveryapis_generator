// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library discoveryapis_generator.dart_resources;

import 'dart:collection';

import 'dart_api_library.dart';
import 'dart_comments.dart';
import 'dart_schemas.dart';
import 'generated_googleapis/discovery/v1.dart';
import 'namer.dart';
import 'uri_template.dart';
import 'utils.dart';

const reservedMethodParameterNames = [
  'uploadMedia',
  'uploadOptions',
  'downloadOptions',
  'callOptions'
];

const whitelistedGlobalParameterNames = [
  'fields',
];

/// Represents a oauth2 authentication scope.
class OAuth2Scope {
  final String url;
  final Identifier identifier;
  final Comment comment;

  OAuth2Scope(this.url, this.identifier, this.comment);
}

/// Represents a parameter to a resource method.
class MethodParameter {
  final Identifier name;
  final Comment comment;
  final DartSchemaType type;
  final bool required;

  /// [jsonName] may be null if this parameter is the request object parameter.
  final String jsonName;

  /// [encodeInPath] is
  ///   - `true` if this parameter is encoded in the path of URL.
  ///   - `false` if this parameter is encoded in the query part of the URL.
  ///   - `null` otherwise.
  final bool encodedInPath;

  MethodParameter(
    this.name,
    this.comment,
    this.required,
    this.type,
    this.jsonName,
    this.encodedInPath,
  );

  /// Returns the declaration "Type name" of this method parameter.
  String get declaration => '${type.declaration} $name';
}

/// Represents a method on a resource class.
class DartResourceMethod {
  /// [requestParameter] may be [:null:].
  final MethodParameter requestParameter;

  /// [returnType] may be [:null:].
  final DartSchemaType returnType;

  final Comment comment;

  final DartApiImports imports;

  final Identifier name;
  final List<MethodParameter> parameters;
  final List<MethodParameter> namedParameters;
  final String jsonName;
  final String httpMethod;
  final bool mediaUpload;
  final bool mediaUploadResumable;
  final bool mediaDownload;

  final UriTemplate urlPattern;

  // Keys are always 'simple' and 'resumable'
  final Map<String, UriTemplate> mediaUploadPatterns;

  final bool enableDataWrapper;

  DartResourceMethod(
    this.imports,
    this.name,
    this.comment,
    this.requestParameter,
    this.parameters,
    this.namedParameters,
    this.returnType,
    this.jsonName,
    this.urlPattern,
    this.httpMethod,
    this.mediaUpload,
    this.mediaUploadResumable,
    this.mediaDownload,
    this.mediaUploadPatterns,
    this.enableDataWrapper,
  );

  String get signature {
    var parameterString = StringBuffer();

    // If a request object was defined, it is always the first parameter.
    if (requestParameter != null) {
      parameterString.write(requestParameter.declaration);
    }

    // Normal positional parameters are following.
    if (parameters.isNotEmpty) {
      if (parameterString.isNotEmpty) parameterString.write(', ');
      parameterString
          .write(parameters.map((param) => param.declaration).join(', '));
    }

    // Optional parameters come last (including the media parameters).
    if (namedParameters.isNotEmpty || mediaUpload || mediaDownload) {
      if (parameterString.isNotEmpty) parameterString.write(', ');

      var namedString = StringBuffer()
        ..write(namedParameters.map((param) => param.declaration).join(', '));

      if (mediaUpload) {
        if (namedString.isNotEmpty) namedString.write(', ');
        if (mediaUploadResumable) {
          // only take options if resume is supported
          namedString.write('${imports.commons}.UploadOptions uploadOptions = '
              '${imports.commons}.UploadOptions.Default, ');
        }
        namedString.write('${imports.commons}.Media uploadMedia');
      }

      if (mediaDownload) {
        if (namedString.isNotEmpty) namedString.write(', ');
        namedString
            .write('${imports.commons}.DownloadOptions downloadOptions = '
                '${imports.commons}.DownloadOptions.Metadata');
      }

      parameterString.write('{$namedString,}');
    }

    var genericReturnType = '';
    // NOTE: Media downloads are optional, so we cannot return [Media] as type.
    if (returnType != null && !mediaDownload) {
      genericReturnType = '<${returnType.declaration}>';
    }
    return '${imports.async.ref()}Future$genericReturnType $name($parameterString)';
  }

  String get definition {
    var params = StringBuffer();

    var commentBuilder = StringBuffer();
    if (comment.rawComment.isNotEmpty) {
      commentBuilder.writeln(comment.rawComment);
      commentBuilder.writeln();
    }

    if (requestParameter != null) {
      commentBuilder.writeln('[${requestParameter.name.name}] - '
          '${requestParameter.comment.rawComment}\n');
    }

    commentBuilder.writeln('Request parameters:\n');

    parameters.forEach((p) {
      commentBuilder.writeln('[${p.name}] - ${p.comment.rawComment}\n');
    });
    namedParameters.forEach((p) {
      commentBuilder.writeln('[${p.name}] - ${p.comment.rawComment}\n');
    });

    if (mediaUpload) {
      commentBuilder.writeln('[uploadMedia] - The media to upload.\n');
    }
    if (mediaUploadResumable) {
      commentBuilder.writeln('[uploadOptions] - Options for the media upload. '
          'Streaming Media without the length being known '
          'ahead of time is only supported via resumable '
          'uploads.\n');
    }

    if (mediaDownload) {
      commentBuilder.writeln('[downloadOptions] - Options for downloading. '
          'A download can be either a Metadata (default) '
          'or Media download. Partial Media downloads '
          'are possible as well.\n');
    }

    if (returnType != null) {
      if (mediaDownload) {
        commentBuilder.writeln('Completes with a\n');
        commentBuilder.writeln('- [${returnType.declaration}] for Metadata '
            'downloads (see [downloadOptions]).\n');
        commentBuilder.writeln('- [${imports.commons}.Media] for Media '
            'downloads (see [downloadOptions]).\n');
      } else {
        commentBuilder
            .writeln('Completes with a [${returnType.declaration}].\n');
      }
    }
    commentBuilder.writeln('Completes with a '
        '[${imports.commons}.ApiRequestError] '
        'if the API endpoint returned an error.\n');
    commentBuilder.writeln('If the used [${imports.http}.Client] '
        'completes with an error when making a REST call, '
        'this method will complete with the same error.\n');

    var methodComment = Comment('$commentBuilder');

    if (requestParameter != null) {
      var parameterEncode =
          requestParameter.type.jsonEncode('${requestParameter.name}');
      params.writeln('    if (${requestParameter.name} != null) {');
      params.writeln(
          '      _body = ${imports.convert.ref()}json.encode(${parameterEncode});');
      params.writeln('    }');
    }

    var templateVars = <String, Identifier>{};

    void validatePathParam(MethodParameter param) {
      templateVars[param.jsonName] = param.name;

      if (param.required) {
        if (param.type is UnnamedArrayType) {
          params.writeln(
              '    if (${param.name} == null || ${param.name}.isEmpty) {');
        } else {
          params.writeln('    if (${param.name} == null) {');
        }
        params.writeln('      throw ${imports.core.ref()}ArgumentError'
            "('Parameter ${param.name} is required.');");
        params.writeln('    }');
      } else {
        // Is this an error?
        throw ArgumentError('non-required path parameter');
      }
    }

    void encodeQueryParam(MethodParameter param) {
      var propertyAssignment;
      // NOTE: We need to special case array values, since they get encoded
      // as repeated query parameters.
      if (param.type is UnnamedArrayType || param.type is NamedArrayType) {
        DartSchemaType innerType = (param.type as dynamic).innerType;
        var expr;
        if (innerType.needsPrimitiveEncoding) {
          expr = '${param.name}.map('
              '(item) => ${innerType.primitiveEncoding('item')}).toList()';
        } else {
          expr = param.name.name;
        }

        propertyAssignment =
            "_queryParams['${escapeString(param.jsonName)}'] = $expr;";
      } else {
        var expr = param.type.primitiveEncoding(param.name.name);
        propertyAssignment =
            "_queryParams['${escapeString(param.jsonName)}'] = [$expr];";
      }

      if (param.required) {
        if (param.type is UnnamedArrayType) {
          params.writeln(
              '    if (${param.name} == null || ${param.name}.isEmpty) {');
        } else {
          params.writeln('    if (${param.name} == null) {');
        }
        params.writeln('      throw ${imports.core.ref()}ArgumentError'
            "('Parameter ${param.name} is required.');");
        params.writeln('    }');
        params.writeln('    $propertyAssignment');
      } else {
        params.writeln('    if (${param.name} != null) {');
        params.writeln('      $propertyAssignment');
        params.writeln('    }');
      }
    }

    parameters.forEach((p) {
      if (p.encodedInPath) {
        validatePathParam(p);
      } else {
        encodeQueryParam(p);
      }
    });

    namedParameters.forEach((p) {
      if (p.encodedInPath) {
        validatePathParam(p);
      } else {
        encodeQueryParam(p);
      }
    });

    var requestCode = StringBuffer();
    if (mediaUpload) {
      params.writeln('');
      requestCode.writeln('    _uploadMedia =  uploadMedia;');
      if (mediaUploadResumable) {
        requestCode.writeln('    _uploadOptions =  uploadOptions;');
      }
    }
    if (mediaDownload) {
      params.writeln('');
      requestCode.writeln('    _downloadOptions = downloadOptions;');
    } else if (returnType == null) {
      params.writeln('');
      requestCode.writeln('    _downloadOptions = null;');
    }

    var urlPatternCode = StringBuffer();
    var patternExpr = urlPattern.stringExpression(templateVars);
    if (!mediaUpload) {
      urlPatternCode.write('    _url = $patternExpr;');
    } else {
      if (!mediaUploadResumable) {
        // Use default, if resumable is not supported
        urlPatternCode.write('''
    _uploadOptions =  ${imports.commons}.UploadOptions.Default;
    if (_uploadMedia == null) {
      _url = $patternExpr;
    } else {
      _url = ${mediaUploadPatterns['simple'].stringExpression(templateVars)};
    }
''');
      } else {
        urlPatternCode.write('''
    if (_uploadMedia == null) {
      _url = $patternExpr;
    } else if (_uploadOptions is ${imports.commons}.ResumableUploadOptions) {
      _url = ${mediaUploadPatterns['resumable'].stringExpression(templateVars)};
    } else {
      _url = ${mediaUploadPatterns['simple'].stringExpression(templateVars)};
    }
''');
      }
    }

    requestCode.write('''

$urlPatternCode

    final _response = _requester.request(_url,
                                       '$httpMethod',
                                       body: _body,
                                       queryParams: _queryParams,
                                       uploadOptions: _uploadOptions,
                                       uploadMedia: _uploadMedia,
                                       downloadOptions: _downloadOptions,);
''');

    final data = enableDataWrapper ? "data['data']" : 'data';
    var plainResponse =
        returnType != null ? returnType.jsonDecode(data) : 'null';
    if (mediaDownload) {
      requestCode.write('''
    if (_downloadOptions == null ||
        _downloadOptions == ${imports.commons}.DownloadOptions.Metadata) {
      return _response.then((data) => $plainResponse);
    } else {
      return _response;
    }
''');
    } else {
      requestCode.write('''
    return _response.then((data) => $plainResponse);
''');
    }

    var methodString = StringBuffer();
    methodString.write(methodComment.asDartDoc(2));
    methodString.writeln('  $signature {');

    final core = imports.core.ref();
    methodString.write('''
    ${core}String _url;
    final _queryParams = <${core}String, ${core}List<${core}String>>{};
    ${imports.commons}.Media _uploadMedia;
    ${imports.commons}.UploadOptions _uploadOptions;
    var _downloadOptions = ${imports.commons}.DownloadOptions.Metadata;
    ${core}String _body;

$params$requestCode''');

    methodString.writeln('  }');

    return '$methodString';
  }
}

/// Represents a resource of an Apiary API.
class DartResourceClass {
  final DartApiImports imports;
  final Identifier className;
  final Comment comment;
  final List<DartResourceMethod> methods;

  final List<Identifier> subResourceIdentifiers;
  final List<DartResourceClass> subResources;

  DartResourceClass(this.imports, this.className, this.comment, this.methods,
      this.subResourceIdentifiers, this.subResources);

  String get preamble => '';

  String get fields {
    var str = StringBuffer();
    for (var i = 0; i < subResourceIdentifiers.length; i++) {
      var identifier = subResourceIdentifiers[i];
      var resource = subResources[i];
      str.writeln('  ${resource.className} get ${identifier.name} '
          '=> ${resource.className}(_requester);');
    }
    if (str.isNotEmpty) str.writeln();
    return '$str';
  }

  String get constructor {
    var str = StringBuffer();
    str.writeln('  $className(${imports.commons}.ApiRequester client) : ');
    str.writeln('      _requester = client;');
    return '$str';
  }

  String get functions {
    var str = StringBuffer();
    methods.forEach((DartResourceMethod m) {
      str.writeln(m.definition);
    });
    return str.isNotEmpty ? '\n$str' : '';
  }

  String getClassDefinition() {
    var str = StringBuffer();
    str.write(comment.asDartDoc(0));
    str.writeln('class $className {');
    str.write(preamble);
    str.writeln('  final ${imports.commons}.ApiRequester _requester;');
    str.writeln('');
    str.write('$fields$constructor$functions');
    str.writeln('}');
    return '$str';
  }
}

/// Represents the API resource of an Apiary API.
class DartApiClass extends DartResourceClass {
  final String rootUrl;
  final String servicePath;
  final List<OAuth2Scope> scopes;

  DartApiClass(
    DartApiImports imports,
    Identifier name,
    Comment comment,
    List<DartResourceMethod> methods,
    List<Identifier> subResourceIdentifiers,
    List<DartResourceClass> subResources,
    this.rootUrl,
    this.servicePath,
    this.scopes,
  ) : super(
          imports,
          name,
          comment,
          methods,
          subResourceIdentifiers,
          subResources,
        );

  @override
  String get preamble {
    var sb = StringBuffer();
    scopes.forEach((OAuth2Scope scope) {
      var doc = scope.comment.asDartDoc(2);
      sb.writeln('$doc  static const ${scope.identifier} = '
          "'${escapeString(scope.url)}';");
      sb.writeln('');
    });
    sb.writeln('');
    return '$sb';
  }

  @override
  String get constructor {
    var str = StringBuffer();

    var parameters = [
      "${imports.core.ref()}String rootUrl = '${escapeString(rootUrl)}'",
      "${imports.core.ref()}String servicePath = '${escapeString(servicePath)}'",
    ].join(', ');

    str.writeln('  $className(${imports.http}.Client client, {$parameters}) :');
    str.write('      _requester = ${imports.commons}.ApiRequester'
        '(client, rootUrl, servicePath, USER_AGENT)');
    str.writeln(';');
    return '$str';
  }
}

/// Check if any methods supports media upload or download.
/// Returns true if supported, false if not.
bool parseMediaUse(DartResourceClass resource) {
  assert(resource.methods != null);
  for (var method in resource.methods) {
    if (method.mediaDownload || method.mediaUpload) {
      return true;
    }
  }
  assert(resource.subResources != null);
  for (var subResource in resource.subResources) {
    if (parseMediaUse(subResource)) {
      return true;
    }
  }
  return false;
}

DartResourceMethod _parseMethod(
  DartApiImports imports,
  DartSchemaTypeDB db,
  RestDescription description,
  Scope classScope,
  String jsonName,
  RestMethod method, {
  bool enableDataWrapper,
}) {
  var methodName = classScope.newIdentifier(jsonName);
  var parameterScope = classScope.newChildScope();

  for (var reserved in reservedMethodParameterNames) {
    // We allocate all identifiers in [RESERVED_METHOD_PARAMETER_NAMES]
    // at the beginning of the parameter scope, so they'll get the correct
    // name.
    parameterScope.newIdentifier(reserved);
  }

  // This set will be reduced to all optional parameters.
  var pendingParameterNames = SplayTreeSet.of(
      method.parameters != null ? method.parameters.keys.toSet() : <String>{});

  var positionalParameters = <MethodParameter>[];
  void tryEnqueuePositionalParameter(
      String jsonName, Comment comment, JsonSchema schema) {
    if (!pendingParameterNames.contains(jsonName)) return;

    var parameter = method.parameters[jsonName];
    if (parameter.required == true) {
      var name = parameterScope.newIdentifier(jsonName);
      pendingParameterNames.remove(jsonName);
      var type = parseResolved(imports, db, parameter);
      comment = extendEnumComment(comment, type);
      comment = extendAnyTypeComment(comment, type);
      positionalParameters.add(MethodParameter(
          name, comment, true, type, jsonName, parameter.location != 'query'));
    }
  }

  var optionalParameters = <MethodParameter>[];
  void enqueueOptionalParameter(
    String jsonName,
    Comment comment,
    JsonSchema schema, {
    bool global = false,
  }) {
    var name = parameterScope.newIdentifier(jsonName, global: global);
    var type = parseResolved(imports, db, schema);
    comment = extendEnumComment(comment, type);
    comment = extendAnyTypeComment(comment, type);
    optionalParameters.add(MethodParameter(
      name,
      comment,
      false,
      type,
      jsonName,
      schema.location != 'query',
    ));
  }

  Comment parameterComment(JsonSchema parameter) {
    var sb = StringBuffer();
    sb.write(parameter.description);

    var min = parameter.minimum;
    var max = parameter.maximum;
    if (min != null && max != null) {
      sb.write('\nValue must be between "$min" and "$max".');
    }
    if (parameter.pattern != null) {
      sb.write('\nValue must have pattern "${parameter.pattern}".');
    }
    return Comment('$sb');
  }

  DartSchemaType getValidReference(String ref) {
    return DartSchemaForwardRef(imports, ref).resolve(db);
  }

  // Enqueue positional parameters with a given order first.
  if (method.parameterOrder != null) {
    for (var jsonName in method.parameterOrder) {
      if (method.parameters == null ||
          !method.parameters.keys.contains(jsonName)) {
        throw GeneratorError(description.name, description.version,
            'Parameters for method $jsonName does not have a type!');
      }
      var comment = parameterComment(method.parameters[jsonName]);

      tryEnqueuePositionalParameter(
          jsonName, comment, method.parameters[jsonName]);
    }
  }

  // If we have more required parameters than in `method.parameterOrder`
  // we append them at the end.
  if (method.parameters != null) {
    method.parameters.forEach((String jsonName, JsonSchema parameter) {
      var comment = parameterComment(parameter);
      tryEnqueuePositionalParameter(
          jsonName, comment, method.parameters[jsonName]);
    });
  }

  // The remaining parameters are optional.
  for (var jsonName in pendingParameterNames) {
    var comment = parameterComment(method.parameters[jsonName]);
    enqueueOptionalParameter(jsonName, comment, method.parameters[jsonName]);
  }

  // Global request parameters valid for all methods.
  if (description.parameters != null) {
    for (var jsonName in description.parameters.keys) {
      final jsonSchema = description.parameters[jsonName];
      assert(jsonSchema != null);
      final comment = parameterComment(jsonSchema);
      if (whitelistedGlobalParameterNames.contains(jsonName)) {
        enqueueOptionalParameter(jsonName, comment, jsonSchema, global: true);
      }
    }
  }

  // Check if we have a request object, if so parse it's type.
  MethodParameter dartRequestParameter;
  if (method.request != null) {
    var type = getValidReference(method.request.P_ref);
    var requestName = parameterScope.newIdentifier('request');
    var comment = Comment('The metadata request object.');
    dartRequestParameter =
        MethodParameter(requestName, comment, true, type, null, null);
  }

  DartSchemaType dartResponseType;
  if (method.response != null) {
    dartResponseType = getValidReference(method.response.ref);
  }

  var comment = Comment(method.description);

  bool makeBoolean(bool x) => x ?? false;

  Map<String, UriTemplate> mediaUploadPatterns;

  var mediaUploadResumable = false;
  if (method.supportsMediaUpload == true) {
    mediaUploadPatterns = <String, UriTemplate>{
      'simple':
          UriTemplate.parse(imports, method.mediaUpload.protocols.simple.path),
    };
    if (method.mediaUpload.protocols.simple.multipart != true) {
      throw ArgumentError('We always require simple upload '
          'protocol with multipart support.');
    }
    mediaUploadResumable = method?.mediaUpload?.protocols?.resumable != null;
    if (mediaUploadResumable) {
      mediaUploadPatterns['resumable'] = UriTemplate.parse(
        imports,
        method.mediaUpload.protocols.resumable.path,
      );
      if (method.mediaUpload.protocols.resumable.multipart != true) {
        throw ArgumentError('We always require resumable upload '
            'protocol with multipart support.');
      }
    }
  }

  final restPath = method.path;
  if (restPath == null) {
    throw StateError('Neither `Method.path` nor `Method.restPath` was given.');
  }

  return DartResourceMethod(
    imports,
    methodName,
    comment,
    dartRequestParameter,
    positionalParameters,
    optionalParameters,
    dartResponseType,
    jsonName,
    UriTemplate.parse(imports, restPath),
    method.httpMethod,
    makeBoolean(method.supportsMediaUpload),
    mediaUploadResumable,
    makeBoolean(method.supportsMediaDownload),
    mediaUploadPatterns,
    enableDataWrapper ?? false,
  );
}

DartResourceClass _parseResource(
  DartApiImports imports,
  DartSchemaTypeDB db,
  RestDescription description,
  String resourceName,
  String resourceDescription,
  Map<String, RestMethod> methods,
  Map<String, RestResource> subResources,
  String parentName,
) {
  var topLevel = parentName.isEmpty;

  var namer = imports.namer;
  Identifier className;
  if (topLevel) {
    className = namer.apiClass(resourceName);
  } else {
    className = namer.resourceClass(resourceName, parent: parentName);
  }

  var classScope = namer.newClassScope();

  final enableDataWrapper =
      description.features?.contains('dataWrapper') ?? false;
  var dartMethods = <DartResourceMethod>[];
  if (methods != null) {
    orderedForEach(methods, (String jsonName, RestMethod method) {
      var dartMethod = _parseMethod(
        imports,
        db,
        description,
        classScope,
        jsonName,
        method,
        enableDataWrapper: enableDataWrapper,
      );
      dartMethods.add(dartMethod);
    });
  }

  var dartSubResourceIdentifiers = <Identifier>[];
  var dartSubResource = <DartResourceClass>[];
  if (subResources != null) {
    orderedForEach(subResources, (String jsonName, RestResource resource) {
      var instanceName = classScope.newIdentifier(jsonName);
      var dartResource = _parseResource(
        imports,
        db,
        description,
        jsonName,
        '',
        resource.methods,
        resource.resources,
        className.preferredName,
      );
      dartSubResourceIdentifiers.add(instanceName);
      dartSubResource.add(dartResource);
    });
  }

  var comment = Comment(resourceDescription);
  if (topLevel) {
    var scopes = <OAuth2Scope>[];

    if (description.auth != null && description.auth.oauth2 != null) {
      orderedForEach(description.auth.oauth2.scopes, (scope, description) {
        var scopeId = classScope.newIdentifier(Scope.toValidScopeName(scope));

        scopes
            .add(OAuth2Scope(scope, scopeId, Comment(description.description)));
      });
    }

    // The following fields can specify the URL base on which to make API
    // calls:
    //   - rootUrl                (ends with slash)
    //   - servicePath            (does not begin with slash)
    //   - basePath [deprecated] (ends with slash)
    //   - baseUrl [deprecated]   (ends with slash)
    //
    // Relationships:
    //   <rootUrl><servicePath> == <baseUrl>
    //   <rootUrl.path><servicePath> == <basePath>
    //
    // Examples:
    // a)
    //   rootUrl = https://www.googleapis.com/
    //   servicePath = storage/v1/
    //   basePath = /storage/v1/
    //   baseUrl = https://www.googleapis.com/storage/v1/
    //
    // b)
    //   rootUrl = https://www.googleapis.com/
    //   servicePath = sink/v1/
    //
    // c)
    //   rootUrl = https://www.googleapis.com/
    //   servicePath = ''
    //   basePath = /
    //   baseUrl = https://www.googleapis.com/

    // Validate our assumptions in checked mode:
    assert(description.rootUrl != null);
    assert(description.rootUrl.endsWith('/'));
    assert(description.servicePath != null);
    assert(description.servicePath == '' ||
        (!description.servicePath.startsWith('/') &&
            description.servicePath.endsWith('/')));
    if (description.baseUrl != null) {
      var expectedBaseUrl = '${description.rootUrl}${description.servicePath}';
      assert(expectedBaseUrl == description.baseUrl);
    }

    var rootUrl = description.rootUrl;
    var restPath = description.servicePath;
    return DartApiClass(imports, className, comment, dartMethods,
        dartSubResourceIdentifiers, dartSubResource, rootUrl, restPath, scopes);
  } else {
    return DartResourceClass(imports, className, comment, dartMethods,
        dartSubResourceIdentifiers, dartSubResource);
  }
}

/// Parses all resources in [description] and returns the root [DartApiClass].
DartApiClass parseResources(
  DartApiImports imports,
  DartSchemaTypeDB db,
  RestDescription description,
) {
  return _parseResource(
    imports,
    db,
    description,
    description.name,
    description.description,
    description.methods,
    description.resources,
    '',
  );
}

/// Generates a string representation of all resource classes, beginning with
/// [apiClass].
String generateResources(DartApiClass apiClass) {
  var sb = StringBuffer();
  void writeResourceClass(DartResourceClass resource) {
    sb.writeln(resource.getClassDefinition());
    sb.writeln();
    resource.subResources.forEach(writeResourceClass);
  }

  writeResourceClass(apiClass);
  return '$sb';
}
