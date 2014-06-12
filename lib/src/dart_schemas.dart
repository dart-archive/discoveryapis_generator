part of discovery_api_client_generator;


/**
 * Class for keeping all named schemas. This is used for
 *  - resolving forward references
 *  - quering types by name
 *  - access to built-in types
 */
class DartSchemaTypeDB {
  // Builtin types
  final StringType stringType = new StringType();
  final IntegerType integerType = new IntegerType();
  final NumberType numberType = new NumberType();
  final DoubleType doubleType = new DoubleType();
  final BooleanType booleanType = new BooleanType();
  final AnyType anyType = new AnyType();

  // List of all [DartSchemaType]s.
  List<DartSchemaType> dartTypes = [];

  // Original schema names to [DartSchemaType].
  final Map<String, DartSchemaType> namedSchemaTypes = {};

  // Name of dart class to [DartSchemaType].
  final Map<String, ComplexDartSchemaType> dartClassTypes = {};
}


/**
 * Represents a property in a dart class.
 */
class DartClassProperty {
  final String name;
  final String comment;
  final DartSchemaType type;
  final String jsonName;

  DartClassProperty(this.name, this.comment, this.type, this.jsonName);
}


/**
 * Represents an internal representation used for codegen.
 *
 * [DartSchemaType] and it's subclasses are a representation for codegen of:
 *   - dart class definitions
 *   - dart type declarations
 *   - dart expressions for encoding/decoding json
 *
 * Before a [DartSchemaType] can be used, it's [resolve] method must be called
 * to resolve all forward references.
 */
abstract class DartSchemaType {
  // [className] is the name of the dart class this [DartSchemaType] represents
  // or `null` if it does not represent a schema type represented by a custom
  // dart class.
  final String className;
  bool _resolved = false;

  DartSchemaType(this.className);

  DartSchemaType resolve(DartSchemaTypeDB db) {
    if (!_resolved) {
      _resolved = true;
      return _resolve(db);
    }
    return this;
  }

  DartSchemaType _resolve(DartSchemaTypeDB db);

  String get declaration;

  /**
   * [value] is the string expression of this [DartSchemaType] that needs to be
   * encoded.
   */
  String jsonEncode(String value);

  /**
   * [json] is the string expression of json data that needs to be decoded to
   * a [DartSchemaType].
   */
  String jsonDecode(String json);
}


/**
 * Placeholder type for forward references.
 */
class DartSchemaForwardRef extends DartSchemaType {
  final String forwardRefName;

  DartSchemaForwardRef(this.forwardRefName) : super(null);

  DartSchemaType resolve(DartSchemaTypeDB db) {
    var concreteType = db.namedSchemaTypes[forwardRefName];
    if (concreteType == null) {
      throw new StateError('Invalid forward reference: $forwardRefName');
    }
    return concreteType;
  }

  DartSchemaType _resolve(DartSchemaTypeDB db) => null;

  String get declaration {
    throw new StateError('Type declarations can only be created after '
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


/**
 * Superclass for primitive types which will not be represented as custom dart
 * classes.
 */
abstract class PrimitiveDartSchemaType extends DartSchemaType {
  PrimitiveDartSchemaType() : super(null);

  DartSchemaType _resolve(DartSchemaTypeDB db) => this;

  String jsonEncode(String value) => value;
  String jsonDecode(String json) => json;
}


class BooleanType extends PrimitiveDartSchemaType {
  String get declaration => 'core.bool';
}


class IntegerType extends PrimitiveDartSchemaType {
  String get declaration => 'core.int';
}


class NumberType extends PrimitiveDartSchemaType {
  String get declaration => 'core.num';
}


class DoubleType extends PrimitiveDartSchemaType {
  String get declaration => 'core.double';
}


class StringType extends PrimitiveDartSchemaType {
  String get declaration => 'core.String';
}


/**
 * Class representing "any" schema type.
 *
 * FIXME/TODO:
 *
 * This is unimplemented and not supported right now.
 * It does not work with jsonEncode/jsonDecode and probably many
 * other things.
 */
class AnyType extends PrimitiveDartSchemaType {
  String get declaration => 'core.Object';
}


/**
 * Class representing non-primitive types.
 *
 * Subclasses may be named dart classes or composed classes (e.g. List<X>).
 */
abstract class ComplexDartSchemaType extends DartSchemaType {
  ComplexDartSchemaType(String name) : super(name);

  String get instantiation;

  String get classDefinition;

  String get declaration;
}


/**
 * Represents an unnamed List<T> type with a given `T`.
 */
class UnnamedArrayType extends ComplexDartSchemaType {
  DartSchemaType innerType;

  UnnamedArrayType(this.innerType) : super(null);

  DartSchemaType _resolve(DartSchemaTypeDB db) {
    innerType = innerType.resolve(db);
    return this;
  }

  String get instantiation =>
      'new core.List<${innerType.declaration}>()';

  String get classDefinition => null;

  String get declaration => 'core.List<${innerType.declaration}>';

  String jsonEncode(String value) {
    return '${value}.map((value) => ${innerType.jsonEncode('value')}).toList()';
  }

  String jsonDecode(String json) {
    return '${json}.map((value) => ${innerType.jsonDecode('value')}).toList()';
  }
}


/**
 * Represents an unnamed Map<F, T> type with given types `F` and `T`.
 */
class UnnamedMapType extends ComplexDartSchemaType {
  DartSchemaType fromType;
  DartSchemaType toType;

  UnnamedMapType(this.fromType, this.toType) : super(null) {
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

  String get instantiation {
    var from = fromType.declaration;
    var to = toType.declaration;
    return 'new core.Map<$from, $to>()';
  }

  String get classDefinition => null;

  String get declaration {
    var from = fromType.declaration;
    var to = toType.declaration;
    return 'core.Map<$from, $to>';
  }

  String jsonEncode(String value) {
    return 'common_internal.mapMap'
           '(${value}, (item) => ${toType.jsonEncode('item')})';
  }

  String jsonDecode(String json) {
    return 'common_internal.mapMap'
           '(${json}, (item) => ${toType.jsonDecode('item')})';
  }
}


/**
 * Represents a named Map<F, T> type with given types `F` and `T`.
 */
class NamedMapType extends ComplexDartSchemaType {
  DartSchemaType fromType;
  DartSchemaType toType;

  NamedMapType(String name, this.fromType, this.toType) : super(name) {
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

  String get instantiation {
    var from = fromType.declaration;
    var to = toType.declaration;
    return 'new $className()';
  }

  String get classDefinition {
    var fromJsonString = new StringBuffer();
    fromJsonString.writeln('  $className.fromJson(core.Map json) {');
    fromJsonString.writeln('    json.forEach((core.String key, value) {');
    fromJsonString.writeln('      this[key] = ${toType.jsonDecode('value')};');
    fromJsonString.writeln('    });');
    fromJsonString.writeln('  }');

    var toJsonString = new StringBuffer();
    toJsonString.writeln('  core.Map toJson() {');
    toJsonString.writeln('    var json = {};');
    toJsonString.writeln('    this.forEach((core.String key, value) {');
    toJsonString.writeln('      this[key] = ${toType.jsonEncode('value')};');
    toJsonString.writeln('    });');
    toJsonString.writeln('    return json;');
    toJsonString.write('  }');

    var fromDeclaration = fromType.declaration;
    var toDeclaration = toType.declaration;

    return
'''
class $className extends collection.MapBase<$fromDeclaration, $toDeclaration> {
  final core.Map _innerMap = {};
  $className();

$fromJsonString
$toJsonString

  ${toType.declaration} operator [](core.Object key) => _innerMap[key];

  operator []=($fromDeclaration key, $toDeclaration value) {
    _innerMap[key] = value;
  }

  void clear() {
    _innerMap.clear();
  }

  core.Iterable<$fromDeclaration> get keys => _innerMap.keys;

  $toDeclaration remove(core.Object key) => _innerMap.remove(key);
}
''';
  }

  String get declaration => className;

  String jsonEncode(String value) {
    return 'common_internal.mapMap'
           '(${value}, (item) => ${toType.jsonEncode('item')})';
  }

  String jsonDecode(String json) {
    return 'common_internal.mapMap'
           '(${json}, (item) => ${toType.jsonDecode('item')})';
  }
}


/**
 * Represents a named custom dart class with a number of properties.
 */
class ObjectType extends ComplexDartSchemaType {
  final Map<String, DartClassProperty> properties;
  // FIXME: Can we have subclasses of subclasses ???
  AbstractVariantType superVariantType;

  ObjectType(String name, this.properties) : super(name);

  DartSchemaType _resolve(DartSchemaTypeDB db) {
    properties.forEach((String key, DartClassProperty property) {
      var resolvedProperty = new DartClassProperty(
          property.name, property.comment, property.type.resolve(db),
          property.jsonName);
      properties[key] = resolvedProperty;
    });
    return this;
  }

  String get instantiation => 'new $className()';

  String get classDefinition {
    var superClassString = '';
    if (superVariantType != null) {
      superClassString = ' extends ${superVariantType.declaration} ';
    }

    var propertyString = new StringBuffer();
    properties.forEach((String prop, DartClassProperty property) {
      var comment = '';
      if (property.comment != null) {
          comment = '  /* ${escapeComment(property.comment)} */\n';
      }
      propertyString.writeln(
          '$comment  ${property.type.declaration} $prop;');
      propertyString.writeln();
    });

    var fromJsonString = new StringBuffer();
    fromJsonString.writeln('  $className.fromJson(core.Map json) {');
    properties.forEach((String name, DartClassProperty property) {
      var decodeString = property.type.jsonDecode(
          'json["${escapeString(property.jsonName)}"]');
      fromJsonString.writeln('    if (json.containsKey'
                             '("${escapeString(property.jsonName)}")) {');
      fromJsonString.writeln('      ${property.name} = ${decodeString};');
      fromJsonString.writeln('    }');
    });
    fromJsonString.writeln('  }');

    var toJsonString = new StringBuffer();
    toJsonString.writeln('  core.Map toJson() {');
    toJsonString.writeln('    var json = new core.Map();');
    properties.forEach((String name, DartClassProperty property) {
      toJsonString.writeln('    if (${property.name} != null) {');
      toJsonString.writeln('      json["${escapeString(property.jsonName)}"] = '
                             '${property.type.jsonEncode(property.name)};');
      toJsonString.writeln('    }');
    });
    toJsonString.writeln('    return json;');
    toJsonString.writeln('  }');

    return
'''
class $className $superClassString{
$propertyString
  $className();

$fromJsonString
$toJsonString
}
''';
  }

  String get declaration => className;

  String jsonEncode(String value) {
    return '$value.toJson()';
  }

  String jsonDecode(String json) {
    return 'new $className.fromJson($json)';
  }
}

/**
 * Represents a schema variant type.
 */
class AbstractVariantType extends ComplexDartSchemaType {
  final String discriminant;
  final Map<String, DartSchemaType> map;

  AbstractVariantType(String name, this.discriminant, this.map) : super(name);

  DartSchemaType _resolve(DartSchemaTypeDB db) {
    map.forEach((String name, DartSchemaType ref) {
      var resolvedType = ref.resolve(db);
      if (resolvedType is ObjectType) {
        map[name] = resolvedType;
        // Set superclass to ourselves.
        if (resolvedType.superVariantType == null) {
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

  String get instantiation => null;

  String get classDefinition {
    var fromJsonString = new StringBuffer();
    fromJsonString.writeln('  factory $className.fromJson(core.Map json) {');
    fromJsonString.writeln('    var discriminant = json["$discriminant"];');
    map.forEach((String name, DartSchemaType type) {
      fromJsonString.writeln('    if (discriminant == "$name") {');
      fromJsonString.writeln('      return new ${type.declaration}'
                             '.fromJson(json);');
      fromJsonString.writeln('    }');
    });
    fromJsonString.writeln('    throw new core.ArgumentError'
                           '("Invalid discriminant: \$discriminant!");');
    fromJsonString.writeln('  }');

    var toJsonString = new StringBuffer();
    toJsonString.writeln('  core.Map toJson();');

    return
'''
abstract class $className {
  $className();
$fromJsonString
$toJsonString
}
''';
  }

  String get declaration => className;

  String jsonEncode(String value) {
    return '$value.toJson()';
  }

  String jsonDecode(String json) {
    return 'new $className.fromJson($json)';
  }
}


/**
 * Parses all schemas in [description] and returns a [DartSchemaTypeDB].
 */
DartSchemaTypeDB parseSchemas(RestDescription description) {
  var db = new DartSchemaTypeDB();

  String upperCaseName(String name) {
    if (name == null) return null;

    var result = name.toUpperCase().substring(0, 1);
    if (name.length > 1) {
      result = '$result${name.substring(1)}';
    }
    return result;
  }

  String camelCaseName(String a, String b) {
    if (a == null || b == null) return null;

    return '$a${upperCaseName(b)}';
  }

  DartSchemaType register(DartSchemaType type) {
    if (type is! DartSchemaForwardRef) {
      // Add [type] to list of all types.
      db.dartTypes.add(type);
    }
    return type;
  }

  void registerTopLevel(String schemaName, DartSchemaType type) {
    db.namedSchemaTypes[schemaName] = type;
  }

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
  DartSchemaType parse(String schemaName, JsonSchema schema,
                       {bool topLevel: false}) {
    if (schema.type == 'object') {
      if (schema.additionalProperties != null) {
        var valueType = parse(schemaName, schema.additionalProperties);
        if (topLevel) {
          // This is a named map type.
          return register(
              new NamedMapType(schemaName, db.stringType, valueType));
        } else {
          // This is an unnamed map type.
          return register(new UnnamedMapType(db.stringType, valueType));
        }
      } else if (schema.variant != null) {
        // This is a variant type, declaring the type discriminant field and all
        // subclasses.
        var map = <String, DartSchemaType>{};
        schema.variant.map.forEach((JsonSchemaVariantMap mapItem) {
          map[mapItem.type_value] = new DartSchemaForwardRef(mapItem.$ref);
        });
        return register(new AbstractVariantType(
            schemaName, schema.variant.discriminant, map));
      } else {
        // This is a normal named schema class, we generate a normal
        // [ObjectType] for it with the defined properties.
        var properties = new Map<String, DartClassProperty>();
        if (schema.properties != null) {
          schema.properties.forEach((String name, JsonSchema value) {
            var propertyName = escapeProperty(name);
            var type = parse(camelCaseName(schemaName, name), value);
            var property = new DartClassProperty(
                propertyName, value.description, type, name);
            properties[propertyName] = property;
          });
        }
        return register(new ObjectType(schemaName, properties));
      }
    } else if (schema.type == 'array') {
      // Array of objects
      return register(new UnnamedArrayType(parse(schemaName, schema.items)));
    } else if (schema.type == 'boolean') {
      return db.booleanType;
    } else if (schema.type == 'string') {
      // FIXME: What about string enums?
      return db.stringType;
    } else if (schema.type == 'number') {
      return db.numberType;
    } else if (schema.type == 'double') {
      return db.doubleType;
    } else if (schema.type == 'integer') {
      // FIXME: Also take [schema.format] into account, e.g. "int64"
      return db.integerType;
    } else if (schema.type == 'any') {
      return db.anyType; // FIXME: What do we do here?
    } else if (schema.$ref != null) {
      // This is a forward or backward reference, it will be resolved in
      // another pass following the parsing.
      return register(new DartSchemaForwardRef(schema.$ref));
    }
    throw new ArgumentError('Invalid JsonSchema.type (was: ${schema.type}).');
  }

  if (description.schemas != null) {
    description.schemas.forEach((String name, JsonSchema schema) {
      registerTopLevel(name, parse(name, schema, topLevel: true));
    });

    // Resolve all forward references and save list in [db.dartTypes].
    db.dartTypes = db.dartTypes.map((type) => type.resolve(db)).toList();

    // Build map of all top level dart schema classes which will be represented
    // as named dart classes.
    for (var type in db.dartTypes) {
      if (type.className != null) {
        if (db.dartClassTypes.containsKey(type.className)) {
          throw new StateError('Trying to register already registred class '
                               '(${type.className}).');
        }
        db.dartClassTypes[type.className] = type;
      }
    }
  }

  return db;
}


/**
 * Generates the codegen'ed dart string for all schema classes.
 */
String generateSchemas(RestDescription description) {
  var db = parseSchemas(description);

  var sb = new StringBuffer();
  db.dartClassTypes.forEach((String name, ComplexDartSchemaType value) {
    sb.writeln('/* Schema class for $name */');
    var classDefinition = value.classDefinition;
    if (classDefinition != null) {
      sb.writeln(classDefinition);
      sb.writeln();
    }
  });

  return '$sb';
}