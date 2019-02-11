// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library discoveryapis_generator.dart_schemas;

import 'dart_api_library.dart';
import 'dart_comments.dart';
import 'generated_googleapis/discovery/v1.dart';
import 'namer.dart';
import 'utils.dart';

/// Class for keeping all named schemas. This is used for
///  - resolving forward references
///  - querying types by name
///  - access to built-in types
class DartSchemaTypeDB {
  // Builtin types
  final StringType stringType;
  final IntegerType integerType;
  final StringIntegerType stringIntegerType;
  final DoubleType doubleType;
  final BooleanType booleanType;
  final DateType dateType;
  final DateTimeType dateTimeType;
  final AnyType anyType;

  DartSchemaTypeDB(DartApiImports imports)
      : stringType = new StringType(imports),
        integerType = new IntegerType(imports),
        stringIntegerType = new StringIntegerType(imports),
        doubleType = new DoubleType(imports),
        booleanType = new BooleanType(imports),
        dateType = new DateType(imports),
        dateTimeType = new DateTimeType(imports),
        anyType = new AnyType(imports);

  // List of all [DartSchemaType]s.
  // TODO: This has to be in depth-first sorted traversal, right?
  List<DartSchemaType> dartTypes = [];

  // Original schema names to [DartSchemaType].
  final Map<String, DartSchemaType> namedSchemaTypes = {};

  // Name of dart class to [DartSchemaType].
  final List<ComplexDartSchemaType> dartClassTypes = [];

  DartSchemaType register(DartSchemaType type) {
    if (type is! DartSchemaForwardRef) {
      // Add [type] to list of all types.
      dartTypes.add(type);
    }
    return type;
  }

  void registerTopLevel(String schemaName, DartSchemaType type) {
    namedSchemaTypes[schemaName] = type;
  }
}

/// Represents a property in a dart class.
class DartClassProperty {
  final Identifier name;
  final Comment comment;
  final DartSchemaType type;
  final String jsonName;

  // If this property is a base64 encoded bytes, this identifier will represent
  // the name used for a setter/getter.
  final Identifier byteArrayAccessor;

  DartClassProperty(this.name, this.comment, this.type, this.jsonName,
      {this.byteArrayAccessor});
}

/// Represents the type declarations we use for representing json data.
abstract class JsonType {
  final DartApiImports imports;
  JsonType(this.imports);

  String get declaration;
  String get baseDeclaration => declaration;
}

class SimpleJsonType extends JsonType {
  final String name;

  SimpleJsonType(DartApiImports imports, this.name) : super(imports);

  String get declaration => '${imports.core.ref()}$name';
}

class StringJsonType extends SimpleJsonType {
  StringJsonType(DartApiImports imports) : super(imports, 'String');
}

class IntJsonType extends SimpleJsonType {
  IntJsonType(DartApiImports imports) : super(imports, 'int');
}

class BoolJsonType extends SimpleJsonType {
  BoolJsonType(DartApiImports imports) : super(imports, 'bool');
}

class DoubleJsonType extends SimpleJsonType {
  DoubleJsonType(DartApiImports imports) : super(imports, 'double');

  String get baseDeclaration => '${imports.core.ref()}num';
}

class MapJsonType extends JsonType {
  final JsonType keyJsonType;
  final JsonType valueJsonType;

  MapJsonType(DartApiImports imports, this.keyJsonType, this.valueJsonType)
      : super(imports);

  String get declaration {
    return '${imports.core.ref()}Map'
        '<${keyJsonType.declaration}, ${valueJsonType.declaration}>';
  }

  String get baseDeclaration => '${imports.core.ref()}Map';
}

class ArrayJsonType extends JsonType {
  final JsonType valueJsonType;

  ArrayJsonType(DartApiImports imports, this.valueJsonType) : super(imports);

  String get declaration =>
      '${imports.core.ref()}List<${valueJsonType.declaration}>';

  String get baseDeclaration => '${imports.core.ref()}List';
}

class AnyJsonType extends JsonType {
  AnyJsonType(DartApiImports imports) : super(imports);

  String get declaration => '${imports.core.ref()}Object';
}

/// Represents an internal representation used for codegen.
///
/// [DartSchemaType] and it's subclasses are a representation for codegen of:
///   - dart class definitions
///   - dart type declarations
///   - dart expressions for encoding/decoding json
///
/// Before a [DartSchemaType] can be used, it's [resolve] method must be called
/// to resolve all forward references.
abstract class DartSchemaType {
  // [className] is the name of the dart class this [DartSchemaType] represents
  // or `null` if it does not represent a schema type represented by a custom
  // dart class.
  final Identifier className;
  final Comment comment;
  final DartApiImports imports;

  bool _resolved = false;

  DartSchemaType(this.imports, this.className, {Comment comment_})
      : comment = comment_ != null ? comment_ : Comment.Empty;

  DartSchemaType resolve(DartSchemaTypeDB db) {
    if (!_resolved) {
      _resolved = true;
      return _resolve(db);
    }
    return this;
  }

  DartSchemaType _resolve(DartSchemaTypeDB db);

  String get declaration;

  JsonType get jsonType;

  /// [value] is the string expression of this [DartSchemType] that needs to be
  /// encoded.
  ///
  /// This method is used for encoding parameter types for the URI query part.
  String primitiveEncoding(String value);

  /// Whether this value needs a primitive encoding.
  bool get needsPrimitiveEncoding => primitiveEncoding('foo') != 'foo';

  /// [value] is the string expression of this [DartSchemaType] that needs to be
  /// encoded.
  String jsonEncode(String value);

  /// [json] is the string expression of json data that needs to be decoded to
  /// a [DartSchemaType].
  String jsonDecode(String json);

  /// Whether this value needs a JSON encoding or not.
  bool get needsJsonEncoding => jsonEncode('foo') != 'foo';

  /// Whether this value needs a JSON decoding or not.
  bool get needsJsonDecoding => jsonDecode('foo') != 'foo';
}

/// Placeholder type for forward references.
class DartSchemaForwardRef extends DartSchemaType {
  final String forwardRefName;

  DartSchemaForwardRef(DartApiImports imports, this.forwardRefName)
      : super(imports, null);

  DartSchemaType resolve(DartSchemaTypeDB db) {
    var concreteType = db.namedSchemaTypes[forwardRefName];
    while (concreteType is DartSchemaForwardRef) {
      concreteType = db.namedSchemaTypes[
          (concreteType as DartSchemaForwardRef).forwardRefName];
    }
    if (concreteType == null) {
      throw new StateError('Invalid forward reference: $forwardRefName');
    }
    return concreteType;
  }

  DartSchemaType _resolve(DartSchemaTypeDB db) => null;

  JsonType get jsonType {
    throw new StateError('Type declarations can only be created after '
        'resolving references.');
  }

  String get declaration {
    throw new StateError('Type declarations can only be created after '
        'resolving references.');
  }

  String primitiveEncoding(String) {
    throw new StateError('Encoding methods can only be called after '
        'resolving references.');
  }

  String jsonEncode(String value) {
    throw new StateError('JSON methods can only be called after '
        'resolving references.');
  }

  String jsonDecode(String json) {
    throw new StateError('JSON methods can only be called after '
        'resolving references.');
  }
}

/// Superclass for primitive types which will not be represented as custom dart
/// classes.
abstract class PrimitiveDartSchemaType extends DartSchemaType {
  PrimitiveDartSchemaType(DartApiImports imports) : super(imports, null);

  DartSchemaType _resolve(DartSchemaTypeDB db) => this;

  String primitiveEncoding(String value) => '"\${${value}}"';
  String jsonEncode(String value) => value;
  String jsonDecode(String json) => json;
}

class BooleanType extends PrimitiveDartSchemaType {
  final JsonType jsonType;

  BooleanType(DartApiImports imports)
      : jsonType = new BoolJsonType(imports),
        super(imports);

  String get declaration => '${imports.core.ref()}bool';
}

class IntegerType extends PrimitiveDartSchemaType {
  final JsonType jsonType;

  IntegerType(DartApiImports imports)
      : jsonType = new IntJsonType(imports),
        super(imports);

  String get declaration => '${imports.core.ref()}int';
}

class StringIntegerType extends PrimitiveDartSchemaType {
  final JsonType jsonType;

  StringIntegerType(DartApiImports imports)
      : jsonType = new StringJsonType(imports),
        super(imports);

  String get declaration => '${imports.core.ref()}int';
  String jsonEncode(String value) => '"\${${value}}"';
  String jsonDecode(String json) =>
      '${imports.core.ref()}int.parse("\${${json}}")';
}

class DoubleType extends PrimitiveDartSchemaType {
  final JsonType jsonType;

  DoubleType(DartApiImports imports)
      : jsonType = new DoubleJsonType(imports),
        super(imports);

  String get declaration => '${imports.core.ref()}double';
  String jsonDecode(String json) => '$json.toDouble()';
}

class StringType extends PrimitiveDartSchemaType {
  final JsonType jsonType;

  StringType(DartApiImports imports)
      : jsonType = new StringJsonType(imports),
        super(imports);

  String primitiveEncoding(String value) => value;
  String get declaration => '${imports.core.ref()}String';
}

class EnumType extends StringType {
  final List<String> enumValues;
  final List<String> enumDescriptions;

  factory EnumType(DartApiImports imports, List<String> enumValues,
      List<String> enumDescriptions) {
    if (enumDescriptions == null) {
      enumDescriptions = enumValues.map((value) => 'A $value.').toList();
    }

    if (enumValues.length != enumDescriptions.length) {
      throw new ArgumentError('Number of enum values does not match number of '
          'enum descriptions.');
    }
    return new EnumType._(imports, enumValues, enumDescriptions);
  }

  EnumType._(DartApiImports imports, this.enumValues, this.enumDescriptions)
      : super(imports);
}

class DateType extends StringType {
  DateType(DartApiImports imports) : super(imports);

  String get declaration => '${imports.core.ref()}DateTime';

  String primitiveEncoding(String value) =>
      '"\${($value).year.toString().padLeft(4, \'0\')}-'
      '\${($value).month.toString().padLeft(2, \'0\')}-'
      '\${($value).day.toString().padLeft(2, \'0\')}"';

  String jsonEncode(String value) => primitiveEncoding(value);

  String jsonDecode(String json) =>
      '${imports.core.ref()}DateTime.parse($json)';
}

class DateTimeType extends StringType {
  DateTimeType(DartApiImports imports) : super(imports);

  String get declaration => '${imports.core.ref()}DateTime';

  String primitiveEncoding(String value) => '($value).toIso8601String()';

  String jsonEncode(String value) => '($value).toIso8601String()';

  String jsonDecode(String json) =>
      '${imports.core.ref()}DateTime.parse($json)';
}

/// Class representing "any" schema type.
///
/// A decodeded any type object is the JSON the server sent. The any type object
/// a user supplies is expected to be JSON and transferred to the server "as is".
class AnyType extends PrimitiveDartSchemaType {
  final JsonType jsonType;

  AnyType(DartApiImports imports)
      : jsonType = new AnyJsonType(imports),
        super(imports);

  String get declaration => '${imports.core.ref()}Object';
}

/// Class representing non-primitive types.
///
/// Subclasses may be named dart classes or composed classes (e.g. List<X>).
abstract class ComplexDartSchemaType extends DartSchemaType {
  ComplexDartSchemaType(DartApiImports imports, Identifier name,
      {Comment comment})
      : super(imports, name, comment_: comment);

  String get classDefinition;

  String get declaration;

  String primitiveEncoding(String value) {
    throw new UnsupportedError(
        'Complex schema types do not have a primitive string encoding for URI'
        'query parameters.');
  }
}

/// Represents an unnamed List<T> type with a given `T`.
class UnnamedArrayType extends ComplexDartSchemaType {
  DartSchemaType innerType;

  UnnamedArrayType(DartApiImports imports, this.innerType)
      : super(imports, null);

  DartSchemaType _resolve(DartSchemaTypeDB db) {
    innerType = innerType.resolve(db);
    return this;
  }

  JsonType get jsonType => new ArrayJsonType(imports, innerType.jsonType);

  String get classDefinition => null;

  String get declaration =>
      '${imports.core.ref()}List<${innerType.declaration}>';

  String jsonEncode(String value) {
    if (innerType.needsJsonEncoding) {
      return '${value}.map((value) => ${innerType.jsonEncode('value')})'
          '.toList()';
    } else {
      // NOTE: The List from the user is already JSON. We have a big
      // ASSUMPTION here: The user does not modify the list while we're
      // converting JSON -> String (-> Bytes).
      return value;
    }
  }

  String jsonDecode(String json) {
    if (innerType.needsJsonDecoding) {
      return '($json as ${imports.core.ref()}List).map<${innerType.declaration}>((value) => ${innerType.jsonDecode('value')})'
          '.toList()';
    } else {
      // NOTE: The List returned from JSON.decode() transfers ownership to the
      // user (i.e. we don't need to make a copy of it).
      return '($json as ${imports.core.ref()}List).cast<${innerType.declaration}>()';
    }
  }
}

/// Represents a named List<T> type with a given `T`.
class NamedArrayType extends ComplexDartSchemaType {
  DartSchemaType innerType;

  NamedArrayType(DartApiImports imports, Identifier name, this.innerType,
      {Comment comment})
      : super(imports, name, comment: comment);

  DartSchemaType _resolve(DartSchemaTypeDB db) {
    innerType = innerType.resolve(db);
    return this;
  }

  JsonType get jsonType => new ArrayJsonType(imports, innerType.jsonType);

  String get classDefinition {
    var decode = new StringBuffer();
    decode.writeln('  $className.fromJson(${imports.core.ref()}List json)');
    decode.writeln('      : _inner = json.map((value) => '
        '${innerType.jsonDecode('value')}).toList();');

    var encode = new StringBuffer();
    encode.writeln('  ${jsonType.declaration} toJson() {');
    encode.writeln('    return _inner.map((value) => '
        '${innerType.jsonEncode('value')}).toList();');
    encode.write('  }');

    var type = innerType.declaration;
    return '''
${comment.asDartDoc(0)}class $className
    extends ${imports.collection.ref()}ListBase<$type> {
  final ${imports.core.ref()}List<$type> _inner;

  $className() : _inner = [];

$decode
$encode

  $type operator [](${imports.core.ref()}int key) => _inner[key];

  void operator []=(${imports.core.ref()}int key, $type value) {
    _inner[key] = value;
  }

  ${imports.core.ref()}int get length => _inner.length;

  set length(${imports.core.ref()}int newLength) {
    _inner.length = newLength;
  }
}
''';
  }

  String get declaration => '${className.name}';

  String jsonEncode(String value) {
    if (innerType.needsJsonEncoding) {
      return '(${value}).toJson()';
    } else {
      // NOTE: The List from the user can be encoded directly. We have a big
      // ASSUMPTION here: The user does not modify the list while we're
      // converting JSON -> String (-> Bytes).
      return value;
    }
  }

  String jsonDecode(String json) {
    return 'new $className.fromJson($json)';
  }
}

/// Represents an unnamed Map<F, T> type with given types `F` and `T`.
class UnnamedMapType extends ComplexDartSchemaType {
  DartSchemaType fromType;
  DartSchemaType toType;

  UnnamedMapType(DartApiImports imports, this.fromType, this.toType)
      : super(imports, null) {
    if (fromType is! StringType) {
      throw new StateError('Violation of assumption: Keys in map types must '
          'be Strings.');
    }
  }

  DartSchemaType _resolve(DartSchemaTypeDB db) {
    fromType = fromType.resolve(db);
    toType = toType.resolve(db);
    return this;
  }

  JsonType get jsonType =>
      new MapJsonType(imports, fromType.jsonType, toType.jsonType);

  String get classDefinition => null;

  String get declaration {
    var from = fromType.declaration;
    var to = toType.declaration;
    return '${imports.core.ref()}Map<$from, $to>';
  }

  String jsonEncode(String value) {
    if (fromType.needsJsonEncoding || toType.needsJsonEncoding) {
      return '${imports.commons}.mapMap'
          '<${toType.declaration}, ${toType.jsonType.declaration}>'
          '(${value}, (${toType.declaration} item) '
          '=> ${toType.jsonEncode('item')})';
    } else {
      // NOTE: The Map from the user can be encoded directly. We have a big
      // ASSUMPTION here: The user does not modify the map while we're
      // converting JSON -> String (-> Bytes).
      return value;
    }
  }

  String jsonDecode(String json) {
    if (fromType.needsJsonDecoding || toType.needsJsonDecoding) {
      return '${imports.commons}.mapMap'
          '<${toType.jsonType.baseDeclaration}, ${toType.declaration}>'
          '($json.cast<${fromType.jsonType.baseDeclaration}, ${toType.jsonType.baseDeclaration}>(), '
          '(${toType.jsonType.baseDeclaration} item) '
          '=> ${toType.jsonDecode('item')})';
    } else {
      // NOTE: The Map returned from JSON.decode() transfers ownership to the
      // user (i.e. we don't need to make a copy of it).
      return '($json as ${imports.core.ref()}Map).cast<${fromType.declaration}, ${toType.declaration}>()';
    }
  }
}

/// Represents a named Map<F, T> type with given types `F` and `T`.
class NamedMapType extends ComplexDartSchemaType {
  DartSchemaType fromType;
  DartSchemaType toType;

  NamedMapType(
      DartApiImports imports, Identifier name, this.fromType, this.toType,
      {Comment comment})
      : super(imports, name, comment: comment) {
    if (fromType is! StringType) {
      throw new StateError('Violation of assumption: Keys in map types must '
          'be Strings.');
    }
  }

  DartSchemaType _resolve(DartSchemaTypeDB db) {
    fromType = fromType.resolve(db);
    toType = toType.resolve(db);
    return this;
  }

  JsonType get jsonType =>
      new MapJsonType(imports, fromType.jsonType, toType.jsonType);

  String get classDefinition {
    var core = imports.core.ref();
    var decode = new StringBuffer();
    decode.writeln('  $className.fromJson(');
    decode.writeln('      ${core}Map<${core}String, ${core}dynamic> _json) {');
    decode.writeln('    _json.forEach((${core}String key, value) {');
    decode.writeln('      this[key] = ${toType.jsonDecode('value')};');
    decode.writeln('    });');
    decode.writeln('  }');

    var encode = new StringBuffer();
    encode.writeln('  ${jsonType.declaration} toJson() {');
    encode.writeln('    final ${jsonType.declaration} _json = '
        '<${fromType.jsonType.declaration}, '
        '${toType.jsonType.declaration}>{};');
    encode.writeln('    this.forEach((${core}String key, value) {');
    encode.writeln('      _json[key] = ${toType.jsonEncode('value')};');
    encode.writeln('    });');
    encode.writeln('    return _json;');
    encode.write('  }');

    var fromT = fromType.declaration;
    var toT = toType.declaration;

    return '''
${comment.asDartDoc(0)}class $className
    extends ${imports.collection.ref()}MapBase<$fromT, $toT> {
  final _innerMap = <$fromT, $toT>{};

  $className();

$decode
$encode

  ${toType.declaration} operator [](${core}Object key)
      => _innerMap[key];

  operator []=($fromT key, $toT value) {
    _innerMap[key] = value;
  }

  void clear() {
    _innerMap.clear();
  }

  ${core}Iterable<$fromT> get keys => _innerMap.keys;

  $toT remove(${core}Object key) => _innerMap.remove(key);
}
''';
  }

  String get declaration => '$className';

  String jsonEncode(String value) {
    if (fromType.needsJsonEncoding || toType.needsJsonEncoding) {
      return '(${value}).toJson()';
    } else {
      // NOTE: The Map from the user can be encoded directly. We have a big
      // ASSUMPTION here: The user does not modify the map while we're
      // converting JSON -> String (-> Bytes).
      return value;
    }
  }

  String jsonDecode(String json) {
    return 'new $className.fromJson($json)';
  }
}

/// Represents a named custom dart class with a number of properties.
class ObjectType extends ComplexDartSchemaType {
  final List<DartClassProperty> properties;
  final MapJsonType jsonType;

  // Will be set by the superVariantType when resolving forward references.
  AbstractVariantType superVariantType;

  ObjectType(DartApiImports imports, Identifier name, this.properties,
      {Comment comment})
      : jsonType = new MapJsonType(
            imports, new StringJsonType(imports), new AnyJsonType(imports)),
        super(imports, name, comment: comment);

  DartSchemaType _resolve(DartSchemaTypeDB db) {
    for (var i = 0; i < properties.length; i++) {
      var property = properties[i];
      var resolvedProperty = new DartClassProperty(property.name,
          property.comment, property.type.resolve(db), property.jsonName,
          byteArrayAccessor: property.byteArrayAccessor);
      properties[i] = resolvedProperty;
    }
    return this;
  }

  String get classDefinition {
    var superClassString = '';
    if (superVariantType != null) {
      superClassString = ' extends ${superVariantType.declaration} ';
    }

    var propertyString = new StringBuffer();
    properties.forEach((DartClassProperty property) {
      var comment = property.comment.asDartDoc(2);
      var prefix = '', postfix = '';
      if (isVariantDiscriminator(property)) {
        prefix = 'final ';
        postfix = ' = "${escapeString(discriminatorValue())}"';
      }
      propertyString.writeln(
          '$comment  $prefix${property.type.declaration} ${property.name}'
          '$postfix;');

      if (property.byteArrayAccessor != null) {
        propertyString.writeln(
            '  ${imports.core.ref()}List<${imports.core.ref()}int> get '
            '${property.byteArrayAccessor} {');
        propertyString.writeln('    return '
            '${imports.convert.ref()}base64.decode'
            '(${property.name});');
        propertyString.writeln('  }');

        propertyString.writeln();

        propertyString.write('  set ${property.byteArrayAccessor}');
        propertyString.writeln(
            '(${imports.core.ref()}List<${imports.core.ref()}int> _bytes) {');
        propertyString.writeln('    ${property.name} = ${imports.convert.ref()}'
            'base64.encode(_bytes).replaceAll("/", "_").replaceAll("+", "-");');
        propertyString.writeln('  }');
      }
    });

    var fromJsonString = new StringBuffer();
    fromJsonString
        .writeln('  $className.fromJson(${imports.core.ref()}Map _json) {');
    properties.forEach((DartClassProperty property) {
      // The super variant fromJson() will call this subclass constructor
      // and the variant descriminator is final.
      if (!isVariantDiscriminator(property)) {
        var decodeString = property.type
            .jsonDecode('_json["${escapeString(property.jsonName)}"]');
        fromJsonString.writeln('    if (_json.containsKey'
            '("${escapeString(property.jsonName)}")) {');
        fromJsonString.writeln('      ${property.name} = ${decodeString};');
        fromJsonString.writeln('    }');
      }
    });
    fromJsonString.writeln('  }');

    var toJsonString = new StringBuffer();
    toJsonString.writeln('  ${jsonType.declaration} toJson() {');
    toJsonString.writeln('    final ${jsonType.declaration} _json = '
        'new ${imports.core.ref()}Map<${jsonType.keyJsonType.declaration}, '
        '${jsonType.valueJsonType.declaration}>();');
    properties.forEach((DartClassProperty property) {
      toJsonString.writeln('    if (${property.name} != null) {');
      toJsonString
          .writeln('      _json["${escapeString(property.jsonName)}"] = '
              '${property.type.jsonEncode('${property.name}')};');
      toJsonString.writeln('    }');
    });
    toJsonString.writeln('    return _json;');
    toJsonString.write('  }');

    return '''
${comment.asDartDoc(0)}class $className $superClassString{
$propertyString
  $className();

$fromJsonString
$toJsonString
}
''';
  }

  String get declaration => '$className';

  String jsonEncode(String value) {
    return '(${value}).toJson()';
  }

  String jsonDecode(String json) {
    return 'new $className.fromJson($json)';
  }

  bool isVariantDiscriminator(DartClassProperty prop) {
    return superVariantType != null &&
        prop.jsonName == superVariantType.discriminant;
  }

  String discriminatorValue() {
    for (var key in superVariantType.map.keys) {
      var value = superVariantType.map[key];
      if (value == this) return key;
    }
    throw new StateError('Could not find my discriminator string.');
  }
}

/// Represents a schema variant type.
class AbstractVariantType extends ComplexDartSchemaType {
  final String discriminant;
  final Map<String, DartSchemaType> map;
  final JsonType jsonType;

  AbstractVariantType(
      DartApiImports imports, Identifier name, this.discriminant, this.map,
      {Comment comment})
      : jsonType = new MapJsonType(
            imports, new StringJsonType(imports), new AnyJsonType(imports)),
        super(imports, name, comment: comment);

  DartSchemaType _resolve(DartSchemaTypeDB db) {
    map.forEach((String name, DartSchemaType ref) {
      var resolvedType = ref.resolve(db);
      if (resolvedType is ObjectType) {
        map[name] = resolvedType;
        // Set superclass to ourselves.
        if (resolvedType.superVariantType == null) {
          if (resolvedType is AbstractVariantType) {
            throw new StateError('Variant types cannot have subclasses which '
                'are variant types themselves.');
          }
          resolvedType.superVariantType = this;
        } else {
          throw new StateError('Superclass already set. A object type should '
              'have only one superclass');
        }
      } else {
        throw new StateError('A variant type can only have concrete object '
            'types as subclasses.');
      }
    });
    return this;
  }

  String get classDefinition {
    var fromJsonString = new StringBuffer();
    fromJsonString.writeln(
        '  factory $className.fromJson(${imports.core.ref()}Map json) {');
    fromJsonString.writeln('    var discriminant = json["$discriminant"];');
    map.forEach((String name, DartSchemaType type) {
      fromJsonString.writeln('    if (discriminant == "$name") {');
      fromJsonString.writeln('      return new ${type.declaration}'
          '.fromJson(json);');
      fromJsonString.writeln('    }');
    });
    fromJsonString.writeln('    throw new ${imports.core.ref()}ArgumentError'
        '("Invalid discriminant: \$discriminant!");');
    fromJsonString.writeln('  }');

    var toJsonString = new StringBuffer();
    toJsonString.writeln('  ${jsonType.declaration} toJson();');

    return '''
${comment.asDartDoc(0)}abstract class $className {
  $className();
$fromJsonString
$toJsonString
}
''';
  }

  String get declaration => '$className';

  String jsonEncode(String value) {
    return '(${value}).toJson()';
  }

  String jsonDecode(String json) {
    return 'new $className.fromJson($json)';
  }
}

/// Parses all schemas in [description] and returns a [DartSchemaTypeDB].
DartSchemaTypeDB parseSchemas(
    DartApiImports imports, RestDescription description) {
  var namer = imports.namer;
  var db = new DartSchemaTypeDB(imports);

  /*
   * Primitive types "integer"/"boolean"/"double"/"number"/"string":
   *   { "type": "boolean" ... }
   *
   * Any type:
   *   { "type" : "any" ... }
   *
   * Array types:
   *   { "type": "array", "items" : {"type": ...}, ... }
   *
   * Map types:
   *   {
   *     "type": "object",
   *     "additionalProperties" : {"type": ...},
   *     ...
   *   }
   *   => key is always String
   *
   * Forward references:
   *   { "$ref" : "NamedSchemaType" }
   *
   * Normal objects:
   *   {
   *     "type" : "object",
   *     "properties": {"prop1" : {"type" : ...}, ... },
   *     ...
   *   }
   *
   * Variant objects:
   *   {
   *     "type" : 'object",
   *     "variant": {
   *       "discriminant" : "type",
   *       "map": [
   *           { "type_value" : "type_a", "$ref" : "NamedSchemaType" },
   *           { "type_value" : "type_b", "$ref" : "NamedSchemaType" }
   *       ]
   *     }
   *   }
   *
   * If these types appear on the top level, i.e. in the {"schemas" { XXX }},
   * they are named, otherwise they are unnamed.
   */
  DartSchemaType parse(String className, Scope classScope, JsonSchema schema,
      {bool topLevel: false}) {
    if (schema.repeated != null) {
      throw new ArgumentError('Only path/query parameters can be repeated.');
    }

    if (schema.type == 'object') {
      var comment = new Comment(schema.description);
      if (schema.additionalProperties != null) {
        var anonValueClassName = namer.schemaClassName('${className}Value');
        var anonClassScope = namer.newClassScope();
        var valueType = parse(
            anonValueClassName, anonClassScope, schema.additionalProperties);
        if (topLevel) {
          if (schema.additionalProperties.description != null) {
            comment = new Comment('${comment.rawComment}\n\n'
                '${schema.additionalProperties.description}');
          }
          // This is a named map type.
          var classId = namer.schemaClass(className);
          return db.register(new NamedMapType(
              imports, classId, db.stringType, valueType,
              comment: comment));
        } else {
          // This is an unnamed map type.
          return db
              .register(new UnnamedMapType(imports, db.stringType, valueType));
        }
      } else if (schema.variant != null) {
        // This is a variant type, declaring the type discriminant field and all
        // subclasses.
        var map = <String, DartSchemaType>{};
        schema.variant.map.forEach((JsonSchemaVariantMap mapItem) {
          map[mapItem.typeValue] =
              new DartSchemaForwardRef(imports, mapItem.P_ref);
        });
        var classId = namer.schemaClass(className);
        return db.register(new AbstractVariantType(
            imports, classId, schema.variant.discriminant, map));
      } else {
        // This is a normal named schema class, we generate a normal
        // [ObjectType] for it with the defined properties.
        var classId = namer.schemaClass(className);
        var properties = new List<DartClassProperty>();
        if (schema.properties != null) {
          orderedForEach(schema.properties,
              (String jsonPName, JsonSchema value) {
            var propertyName = classScope.newIdentifier(jsonPName);
            var propertyClass =
                namer.schemaClassName(jsonPName, parent: className);
            var propertyClassScope = namer.newClassScope();

            var propertyType = parse(propertyClass, propertyClassScope, value);

            var comment = new Comment(value.description);
            comment = extendEnumComment(comment, propertyType);
            comment = extendAnyTypeComment(comment, propertyType);
            Identifier byteArrayAccessor;
            if (value.format == 'byte' && value.type == 'string') {
              byteArrayAccessor =
                  classScope.newIdentifier('${jsonPName}AsBytes');
            }
            var property = new DartClassProperty(
                propertyName, comment, propertyType, jsonPName,
                byteArrayAccessor: byteArrayAccessor);
            properties.add(property);
          });
        }
        return db.register(
            new ObjectType(imports, classId, properties, comment: comment));
      }
    } else if (schema.type == 'array') {
      var comment = new Comment(schema.description);
      if (topLevel) {
        var elementClassName = namer.schemaClassName('${className}Element');
        var classId = namer.schemaClass(className);
        return db.register(new NamedArrayType(imports, classId,
            parse(elementClassName, namer.newClassScope(), schema.items),
            comment: comment));
      } else {
        return db.register(new UnnamedArrayType(
            imports, parse(className, namer.newClassScope(), schema.items)));
      }
    } else if (schema.type == 'any') {
      return db.anyType;
    } else if (schema.P_ref != null) {
      // This is a forward or backward reference, it will be resolved in
      // another pass following the parsing.
      return db.register(new DartSchemaForwardRef(imports, schema.P_ref));
    } else {
      return parsePrimitive(imports, db, schema);
    }
  }

  if (description.schemas != null) {
    orderedForEach(description.schemas, (String name, JsonSchema schema) {
      var className = namer.schemaClassName(name);
      var classScope = namer.newClassScope();
      db.registerTopLevel(
          name, parse(className, classScope, schema, topLevel: true));
    });

    // Resolve all forward references and save list in [db.dartTypes].
    db.dartTypes = db.dartTypes.map((type) => type.resolve(db)).toList();

    // Build map of all top level dart schema classes which will be represented
    // as named dart classes.
    db.dartClassTypes.addAll(db.dartTypes
        .where((type) => type.className != null)
        .cast<ComplexDartSchemaType>());
  }

  return db;
}

// NOTE: This will be called for resolving parameter types in methods.
DartSchemaType parseResolved(
    DartApiImports imports, DartSchemaTypeDB db, JsonSchema schema) {
  if (schema.repeated != null && schema.repeated) {
    var innerType = parsePrimitive(imports, db, schema);
    return new UnnamedArrayType(imports, innerType);
  }
  return parsePrimitive(imports, db, schema);
}

DartSchemaType parsePrimitive(
    DartApiImports imports, DartSchemaTypeDB db, JsonSchema schema) {
  switch (schema.type) {
    case 'boolean':
      return db.booleanType;
    case 'string':
      switch (schema.format) {
        case 'date-time':
          return db.dateTimeType;
        case 'date':
          return db.dateType;
        case 'int64':
          // 9007199254740991 == pow(2, 53) - 1; the maximum range for integers
          // in javascript (which uses doubles to store integers)
          if (schema.maximum != null &&
              int.parse(schema.maximum) <= 9007199254740991 &&
              schema.minimum != null &&
              int.parse(schema.minimum) >= -9007199254740991) {
            return db.stringIntegerType;
          }
      }
      if (schema.enum_ != null) {
        return db.register(
            new EnumType(imports, schema.enum_, schema.enumDescriptions));
      }
      return db.stringType;
    case 'number':
      if (!['float', 'double', null].contains(schema.format)) {
        throw new ArgumentError(
            'Only number types with float/double format are supported.');
      }
      return db.doubleType;
    case 'integer':
      var format = schema.format;
      if (format != null && !['int16', 'int32', 'uint32'].contains(format)) {
        throw new Exception('Integer format $format is not not supported.');
      }
      return db.integerType;
  }
  throw new ArgumentError('Invalid JsonSchema.type (was: ${schema.type}).');
}

/// Generates the codegen'ed dart string for all schema classes.
String generateSchemas(DartSchemaTypeDB db) {
  var sb = new StringBuffer();
  db.dartClassTypes.forEach((ComplexDartSchemaType value) {
    var classDefinition = value.classDefinition;
    if (classDefinition != null) {
      sb.writeln(classDefinition);
    }
  });

  return '$sb';
}

Comment extendEnumComment(Comment baseComment, DartSchemaType type) {
  if (type is EnumType) {
    var s = new StringBuffer()
      ..writeln(baseComment.rawComment)
      ..writeln('Possible string values are:');
    for (int i = 0; i < type.enumValues.length; i++) {
      var description = type.enumDescriptions[i];
      if (description != null && description.trim().length > 0) {
        s.writeln('- "${type.enumValues[i]}" : $description');
      } else {
        s.writeln('- "${type.enumValues[i]}"');
      }
    }
    return new Comment('$s');
  }
  return baseComment;
}

Comment extendAnyTypeComment(Comment baseComment, DartSchemaType type,
    {bool includeNamedTypes: false}) {
  const String AnyTypeComment =
      'The values for Object must be JSON objects. It can consist of `num`, '
      '`String`, `bool` and `null` as well as `Map` and `List` values.';

  // This will detect if [type] contains usages of the general AnyType, e.g.
  //   - Object
  //   - List<List<Object>>
  //   - Map<String,List<Object>>
  //   - ...
  bool traverseType(DartSchemaType type) {
    if (includeNamedTypes) {
      if (type is NamedArrayType) {
        return traverseType(type.innerType);
      } else if (type is NamedMapType) {
        return traverseType(type.toType);
      }
    }
    if (type is UnnamedArrayType) {
      return traverseType(type.innerType);
    } else if (type is UnnamedMapType) {
      return traverseType(type.toType);
    } else if (type is AnyType) {
      return true;
    }
    return false;
  }

  if (traverseType(type)) {
    return new Comment('${baseComment.rawComment}\n\n$AnyTypeComment');
  }
  return baseComment;
}
