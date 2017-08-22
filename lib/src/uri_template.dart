// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library discoveryapis_generator.uri_template;

import 'dart_api_library.dart';
import 'namer.dart';
import 'utils.dart';

/// Generates code for expanding a URI template.
abstract class Part {
  final DartApiImports imports;
  final String templateVar;

  Part(this.imports, this.templateVar);

  /// Generates a dart expression by expanding this part using [codeVariable] as
  /// the contests of a template variable.
  String stringExpression(Identifier variable);
}

/// Represents a URI Template literal.
class StringPart extends Part {
  final String staticString;

  StringPart(DartApiImports imports, this.staticString) : super(imports, null);

  String stringExpression(Identifier _) => "'${escapeString(staticString)}'";
}

/// Represents a URI Template variable expression of the form {var}
class VariableExpression extends Part {
  VariableExpression(DartApiImports imports, String templateVar)
      : super(imports, templateVar);

  String stringExpression(Identifier variable) {
    return "${imports.commons}.Escaper.ecapeVariable('\$$variable')";
  }
}

/// Represents a URI Template variable expression of the form {/var*}
class PathVariableExpression extends Part {
  PathVariableExpression(DartApiImports imports, String templateVar)
      : super(imports, templateVar);

  String stringExpression(Identifier variable) {
    return "'/' + ($variable).map((item) => "
        "${imports.commons}.Escaper.ecapePathComponent(item)).join('/')";
  }
}

/// Represents a URI Template variable expression of the form {+var}
class ReservedExpansionExpression extends Part {
  ReservedExpansionExpression(DartApiImports imports, String templateVar)
      : super(imports, templateVar);

  String stringExpression(Identifier variable) {
    return "${imports.commons}.Escaper.ecapeVariableReserved('\$$variable')";
  }
}

/// Represents a URI Template as defined in RFC 6570.
///
/// This class supports only a very limited subset of RFC 6570, namely
/// the following expression types: {var}, {/var*} and {+var}.
///
/// See: http://tools.ietf.org/html/rfc6570
class UriTemplate {
  final List<Part> parts;

  UriTemplate(this.parts);

  /// Generates a dart expression by expanding this [UriTemplate] using
  /// [identifiers].
  ///
  /// The key in [identifiers] are template variable names and the values are
  /// the dart [Identifier]s which contain the dart value.
  String stringExpression(Map<String, Identifier> identifiers) {
    return parts.map((Part part) {
      if (part.templateVar == null) {
        return part.stringExpression(null);
      }
      var identifier = identifiers[part.templateVar];
      if (identifier == null) {
        throw new ArgumentError(
            'Could not find entry ${part.templateVar} in identifier map.');
      }
      return part.stringExpression(identifier);
    }).join(' + ');
  }

  static UriTemplate parse(DartApiImports imports, String pattern) {
    List<Part> parts = [];

    var offset = 0;
    while (offset < pattern.length) {
      var open = pattern.indexOf("{", offset);
      // If we have no more URI template expressions, we append the remaining
      // string as a literal and we're done.
      if (open < 0) {
        var rest = pattern.substring(offset);
        parts.add(new StringPart(imports, rest));
        break;
      }

      // We append the static string prefix as a literal (if necessary).
      if (open > offset) {
        var stringPrefix = pattern.substring(offset, open);
        parts.add(new StringPart(imports, stringPrefix));
      }

      var close = pattern.indexOf("}", open);
      if (close < 0) {
        throw new ArgumentError("Invalid URI template pattern, "
            "expected closing brace: '$pattern'");
      }

      // We extract the URI template expression and generate an expression
      // object for it.
      String templateExpression = pattern.substring(open + 1, close);
      if (templateExpression.startsWith('/') &&
          templateExpression.endsWith('*')) {
        var variable =
            templateExpression.substring(1, templateExpression.length - 1);
        _ensureValidVariable(variable);
        parts.add(new PathVariableExpression(imports, variable));
      } else if (templateExpression.startsWith('+')) {
        var variable = templateExpression.substring(1);
        _ensureValidVariable(variable);
        parts.add(new ReservedExpansionExpression(imports, variable));
      } else {
        var variable = templateExpression;
        _ensureValidVariable(variable);
        parts.add(new VariableExpression(imports, variable));
      }
      offset = close + 1;
    }
    return new UriTemplate(parts);
  }

  static void _ensureValidVariable(String name) {
    var codeUnites = name.codeUnits;
    for (var i = 0; i < codeUnites.length; i++) {
      var char = codeUnites[i];
      bool isLetter = (65 <= char && char <= 90) || (97 <= char && char <= 122);
      bool isNumber = (48 <= char && char <= 57);
      bool isUnderscore = char == 0x5F;
      if (i == 0 && !isLetter) {
        throw new ArgumentError('Variables can only begin with an upper or '
            'lowercase letter: "$name".');
      }
      if (!isLetter && !isNumber && !isUnderscore) {
        throw new ArgumentError('Variables can only consist of uppercase '
            'letters, lowercase letters, underscores and '
            'numbers: "$name".');
      }
    }
  }
}
