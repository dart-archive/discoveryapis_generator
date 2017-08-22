// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library discoveryapis_generator.dart_resources;

import 'dart_api_library.dart';
import 'dart_comments.dart';
import 'dart_schemas.dart';
import 'generated_googleapis/discovery/v1.dart';
import 'namer.dart';
import 'uri_template.dart';
import 'utils.dart';

const RESERVED_METHOD_PARAMETER_NAMES = const [
  'uploadMedia',
  'uploadOptions',
  'downloadOptions',
  'callOptions'
];

const WHITELISTED_GLOBAL_PARAMETER_NAMES = const [
  'fields',
];

/**
 * Represents a oauth2 authentication scope.
 */
class OAuth2Scope {
  final String url;
  final Identifier identifier;
  final Comment comment;

  OAuth2Scope(this.url, this.identifier, this.comment);
}

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
  final String httpMethod;
  final bool mediaUpload;
  final bool mediaDownload;

  final UriTemplate urlPattern;

  // Keys are always 'simple' and 'resumable'
  final Map<String, UriTemplate> mediaUploadPatterns;

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
      this.mediaDownload,
      this.mediaUploadPatterns);

  String get signature {
    var parameterString = new StringBuffer();

    // If a request object was defined, it is always the first parameter.
    if (requestParameter != null) {
      parameterString.write('${requestParameter.declaration}');
    }

    // Normal positional parameters are following.
    if (parameters.length > 0) {
      if (parameterString.isNotEmpty) parameterString.write(', ');
      parameterString
          .write(parameters.map((param) => '${param.declaration}').join(', '));
    }

    // Optional parameters come last (including the media parameters).
    if (namedParameters.length > 0 || mediaUpload || mediaDownload) {
      if (parameterString.isNotEmpty) parameterString.write(', ');

      var namedString = new StringBuffer()
        ..write(
            namedParameters.map((param) => '${param.declaration}').join(', '));

      if (mediaUpload) {
        if (namedString.isNotEmpty) namedString.write(', ');
        namedString.write('${imports.commons}.UploadOptions uploadOptions : '
            '${imports.commons}.UploadOptions.Default, ');
        namedString.write('${imports.commons}.Media uploadMedia');
      }

      if (mediaDownload) {
        if (namedString.isNotEmpty) namedString.write(', ');
        namedString.write('${imports.commons}.DownloadOptions downloadOptions: '
            '${imports.commons}.DownloadOptions.Metadata');
      }

      parameterString.write('{$namedString}');
    }

    var genericReturnType = '';
    // NOTE: Media downloads are optional, so we cannot return [Media] as type.
    if (returnType != null && !mediaDownload) {
      genericReturnType = '<${returnType.declaration}>';
    }
    return '${imports.async.ref()}Future$genericReturnType $name($parameterString)';
  }

  String get definition {
    var params = new StringBuffer();

    var commentBuilder = new StringBuffer();
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

    var methodComment = new Comment('$commentBuilder');

    if (requestParameter != null) {
      var parameterEncode =
          requestParameter.type.jsonEncode('${requestParameter.name}');
      params.writeln('    if (${requestParameter.name} != null) {');
      params.writeln(
          '      _body = ${imports.convert}.JSON.encode(${parameterEncode});');
      params.writeln('    }');
    }

    Map<String, Identifier> templateVars = {};

    validatePathParam(MethodParameter param) {
      templateVars[param.jsonName] = param.name;

      if (param.required) {
        if (param.type is UnnamedArrayType) {
          params.writeln(
              '    if (${param.name} == null || ${param.name}.isEmpty) {');
        } else {
          params.writeln('    if (${param.name} == null) {');
        }
        params.writeln('      throw new ${imports.core.ref()}ArgumentError'
            '("Parameter ${param.name} is required.");');
        params.writeln('    }');
      } else {
        // Is this an error?
        throw 'non-required path parameter';
      }
    }

    encodeQueryParam(MethodParameter param) {
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
            '_queryParams["${escapeString(param.jsonName)}"] = $expr;';
      } else {
        var expr = param.type.primitiveEncoding(param.name.name);
        propertyAssignment =
            '_queryParams["${escapeString(param.jsonName)}"] = [$expr];';
      }

      if (param.required) {
        if (param.type is UnnamedArrayType) {
          params.writeln(
              '    if (${param.name} == null || ${param.name}.isEmpty) {');
        } else {
          params.writeln('    if (${param.name} == null) {');
        }
        params.writeln('      throw new ${imports.core.ref()}ArgumentError'
            '("Parameter ${param.name} is required.");');
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

    var requestCode = new StringBuffer();
    if (mediaUpload) {
      params.writeln('');
      requestCode.writeln('    _uploadMedia =  uploadMedia;');
      requestCode.writeln('    _uploadOptions =  uploadOptions;');
    }
    if (mediaDownload) {
      params.writeln('');
      requestCode.writeln('    _downloadOptions = downloadOptions;');
    } else if (returnType == null) {
      params.writeln('');
      requestCode.writeln('    _downloadOptions = null;');
    }

    var urlPatternCode = new StringBuffer();
    var patternExpr = urlPattern.stringExpression(templateVars);
    if (!mediaUpload) {
      urlPatternCode.write('    _url = $patternExpr;');
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

    requestCode.write('''

$urlPatternCode

    var _response = _requester.request(_url,
                                       "$httpMethod",
                                       body: _body,
                                       queryParams: _queryParams,
                                       uploadOptions: _uploadOptions,
                                       uploadMedia: _uploadMedia,
                                       downloadOptions: _downloadOptions);
''');

    var plainResponse =
        returnType != null ? returnType.jsonDecode('data') : 'null';
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

    var methodString = new StringBuffer();
    methodString.write(methodComment.asDartDoc(2));
    methodString.writeln('  $signature {');

    methodString.write('''
    var _url = null;
    var _queryParams = new ${imports.core.ref()}Map();
    var _uploadMedia = null;
    var _uploadOptions = null;
    var _downloadOptions = ${imports.commons}.DownloadOptions.Metadata;
    var _body = null;

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

  String get preamble => '';

  String get fields {
    var str = new StringBuffer();
    for (var i = 0; i < subResourceIdentifiers.length; i++) {
      var identifier = subResourceIdentifiers[i];
      var resource = subResources[i];
      str.writeln('  ${resource.className} get ${identifier.name} '
          '=> new ${resource.className}(_requester);');
    }
    if (str.isNotEmpty) str.writeln();
    return '$str';
  }

  String get constructor {
    var str = new StringBuffer();
    str.writeln('  $className(${imports.commons}.ApiRequester client) : ');
    str.writeln('      _requester = client;');
    return '$str';
  }

  String get functions {
    var str = new StringBuffer();
    methods.forEach((DartResourceMethod m) {
      str.writeln(m.definition);
    });
    return str.isNotEmpty ? '\n$str' : '';
  }

  String getClassDefinition() {
    var str = new StringBuffer();
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

/**
 * Represents the API resource of an Apiary API.
 */
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
      this.scopes)
      : super(imports, name, comment, methods, subResourceIdentifiers,
            subResources);

  String get preamble {
    var sb = new StringBuffer();
    scopes.forEach((OAuth2Scope scope) {
      var doc = scope.comment.asDartDoc(2);
      sb.writeln('$doc  static const ${scope.identifier} = '
          '"${escapeString(scope.url)}";');
      sb.writeln('');
    });
    sb.writeln('');
    return '$sb';
  }

  String get constructor {
    var str = new StringBuffer();

    var parameters = [
      '${imports.core.ref()}String rootUrl: "${escapeString(rootUrl)}"',
      '${imports.core.ref()}String servicePath: "${escapeString(servicePath)}"',
    ].join(', ');

    str.writeln('  $className(${imports.http}.Client client, {$parameters}) :');
    str.write('      _requester = new ${imports.commons}.ApiRequester'
        '(client, rootUrl, servicePath, USER_AGENT)');
    str.writeln(';');
    return '$str';
  }
}

/**
 * Check if any methods supports media upload or download.
 * Returns true if supported, false if not.
 */
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

/**
 * Parses all resources in [description] and returns the root [DartApiClass].
 */
DartApiClass parseResources(
    DartApiImports imports, DartSchemaTypeDB db, RestDescription description) {
  DartResourceClass parseResource(
      String resourceName,
      String resourceDescription,
      Map<String, RestMethod> methods,
      Map<String, RestResource> subResources,
      String parentName) {
    DartResourceMethod parseMethod(
        Scope classScope, String jsonName, RestMethod method) {
      var methodName = classScope.newIdentifier(jsonName);
      var parameterScope = classScope.newChildScope();

      for (var reserved in RESERVED_METHOD_PARAMETER_NAMES) {
        // We allocate all identifiers in [RESERVED_METHOD_PARAMETER_NAMES]
        // at the beginning of the parameter scope, so they'll get the correct
        // name.
        parameterScope.newIdentifier(reserved);
      }

      // This set will be reduced to all optional parameters.
      var pendingParameterNames = method.parameters != null
          ? method.parameters.keys.toSet()
          : new Set<String>();

      var positionalParameters = new List<MethodParameter>();
      tryEnqueuePositionalParameter(
          String jsonName, Comment comment, JsonSchema schema) {
        if (!pendingParameterNames.contains(jsonName)) return;

        var parameter = method.parameters[jsonName];
        if (parameter.required == true) {
          var name = parameterScope.newIdentifier(jsonName);
          pendingParameterNames.remove(jsonName);
          var type = parseResolved(imports, db, parameter);
          comment = extendEnumComment(comment, type);
          comment = extendAnyTypeComment(comment, type);
          positionalParameters.add(new MethodParameter(name, comment, true,
              type, jsonName, parameter.location != 'query'));
        }
      }

      var optionalParameters = new List<MethodParameter>();
      enqueueOptionalParameter(
          String jsonName, Comment comment, JsonSchema schema,
          {bool global: false}) {
        var name = parameterScope.newIdentifier(jsonName, global: global);
        var type = parseResolved(imports, db, schema);
        comment = extendEnumComment(comment, type);
        comment = extendAnyTypeComment(comment, type);
        optionalParameters.add(new MethodParameter(
            name, comment, false, type, jsonName, schema.location != 'query'));
      }

      Comment parameterComment(JsonSchema parameter) {
        var sb = new StringBuffer();
        sb.write(parameter.description);

        var min = parameter.minimum;
        var max = parameter.maximum;
        if (min != null && max != null) {
          sb.write('\nValue must be between "$min" and "$max".');
        }
        if (parameter.pattern != null) {
          sb.write('\nValue must have pattern "${parameter.pattern}".');
        }
        return new Comment('$sb');
      }

      DartSchemaType getValidReference(String ref) {
        return new DartSchemaForwardRef(imports, ref).resolve(db);
      }

      // Enqueue positional parameters with a given order first.
      if (method.parameterOrder != null) {
        for (var jsonName in method.parameterOrder) {
          if (method.parameters == null ||
              !method.parameters.keys.contains(jsonName)) {
            throw new GeneratorError(description.name, description.version,
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
        enqueueOptionalParameter(
            jsonName, comment, method.parameters[jsonName]);
      }

      // Global request parameters valid for all methods.
      if (description.parameters != null) {
        for (var jsonName in description.parameters.keys) {
          final jsonSchema = description.parameters[jsonName];
          assert(jsonSchema != null);
          final comment = parameterComment(jsonSchema);
          if (WHITELISTED_GLOBAL_PARAMETER_NAMES.contains(jsonName)) {
            enqueueOptionalParameter(jsonName, comment, jsonSchema,
                global: true);
          }
        }
      }

      // Check if we have a request object, if so parse it's type.
      MethodParameter dartRequestParameter;
      if (method.request != null) {
        var type = getValidReference(method.request.P_ref);
        var requestName = parameterScope.newIdentifier('request');
        var comment = new Comment('The metadata request object.');
        dartRequestParameter =
            new MethodParameter(requestName, comment, true, type, null, null);
      }

      DartSchemaType dartResponseType;
      if (method.response != null) {
        dartResponseType = getValidReference(method.response.P_ref);
      }

      var comment = new Comment(method.description);

      makeBoolean(bool x) => x != null ? x : false;

      Map mediaUploadPatterns;

      if (method.supportsMediaUpload == true) {
        mediaUploadPatterns = {
          'simple': UriTemplate.parse(
              imports, method.mediaUpload.protocols.simple.path),
          'resumable': UriTemplate.parse(
              imports, method.mediaUpload.protocols.resumable.path),
        };
        if (method.mediaUpload.protocols.simple.multipart != true ||
            method.mediaUpload.protocols.resumable.multipart != true) {
          throw new ArgumentError('We always require simple/resumable upload '
              'protocols with multipart support.');
        }
      }

      String restPath;
      if (method.path != null) {
        restPath = method.path;
      } else if (method.restPath != null) {
        restPath = method.restPath;
      } else {
        throw new StateError(
            'Neither `Method.path` nor `Method.restPath` was given.');
      }

      return new DartResourceMethod(
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
          makeBoolean(method.supportsMediaDownload),
          mediaUploadPatterns);
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
        var instanceName = classScope.newIdentifier(jsonName);
        var dartResource = parseResource(jsonName, '', resource.methods,
            resource.resources, className.preferredName);
        dartSubResourceIdentifiers.add(instanceName);
        dartSubResource.add(dartResource);
      });
    }

    var coment = new Comment(resourceDescription);
    if (topLevel) {
      var scopes = [];

      if (description.auth != null && description.auth.oauth2 != null) {
        orderedForEach(description.auth.oauth2.scopes, (scope, description) {
          var scopeId = classScope.newIdentifier(Scope.toValidScopeName(scope));

          scopes.add(new OAuth2Scope(
              scope, scopeId, new Comment(description.description)));
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
        var expectedBaseUrl =
            '${description.rootUrl}${description.servicePath}';
        assert(expectedBaseUrl == description.baseUrl);
      }

      var rootUrl = description.rootUrl;
      var restPath = description.servicePath;
      return new DartApiClass(
          imports,
          className,
          coment,
          dartMethods,
          dartSubResourceIdentifiers,
          dartSubResource,
          rootUrl,
          restPath,
          scopes);
    } else {
      return new DartResourceClass(imports, className, coment, dartMethods,
          dartSubResourceIdentifiers, dartSubResource);
    }
  }

  return parseResource(description.name, description.description,
      description.methods, description.resources, '');
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
