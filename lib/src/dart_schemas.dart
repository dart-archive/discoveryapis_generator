part of discovery_api_client_generator;


/**
 * Class for keeping all named schemas. This is used for
 *  - resolving forward references
 *  - quering types by name
 *  - access to built-in types
 */
class DartSchemaTypeDB {
  // Builtin types
  final StringType stringType;
  final IntegerType integerType;
  final NumberType numberType;
  final DoubleType doubleType;
  final BooleanType booleanType;
  final AnyType anyType;

  DartSchemaTypeDB(DartApiImports imports)
      : stringType = new StringType(imports),
        integerType = new IntegerType(imports),
        numberType = new NumberType(imports),
        doubleType = new DoubleType(imports),
        booleanType = new BooleanType(imports),
        anyType = new AnyType(imports);

  // List of all [DartSchemaType]s.
  // TODO: This has to be in depth-first sorted traversal, right?
  List<DartSchemaType> dartTypes = [];

  // Original schema names to [DartSchemaType].
  final Map<String, DartSchemaType> namedSchemaTypes = {};

  // Name of dart class to [DartSchemaType].
  final List<ComplexDartSchemaType> dartClassTypes = [];
}


/**
 * Represents a property in a dart class.
 */
class DartClassProperty {
  final Identifier name;
  final Comment comment;
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

  DartSchemaForwardRef(DartApiImports imports, this.forwardRefName)
      : super(imports, null);

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
  PrimitiveDartSchemaType(DartApiImports imports) : super(imports, null);

  DartSchemaType _resolve(DartSchemaTypeDB db) => this;

  String jsonEncode(String value) => value;
  String jsonDecode(String json) => json;
}


class BooleanType extends PrimitiveDartSchemaType {
  BooleanType(DartApiImports imports) : super(imports);

  String get declaration => '${imports.core}.bool';
}


class IntegerType extends PrimitiveDartSchemaType {
  IntegerType(DartApiImports imports) : super(imports);

  String get declaration => '${imports.core}.int';
}


class NumberType extends PrimitiveDartSchemaType {
  NumberType(DartApiImports imports) : super(imports);

  String get declaration => '${imports.core}.num';
}


class DoubleType extends PrimitiveDartSchemaType {
  DoubleType(DartApiImports imports) : super(imports);

  String get declaration => '${imports.core}.double';
}


class StringType extends PrimitiveDartSchemaType {
  StringType(DartApiImports imports) : super(imports);

  String get declaration => '${imports.core}.String';
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
  AnyType(DartApiImports imports) : super(imports);

  String get declaration => '${imports.core}.Object';
}


/**
 * Class representing non-primitive types.
 *
 * Subclasses may be named dart classes or composed classes (e.g. List<X>).
 */
abstract class ComplexDartSchemaType extends DartSchemaType {
  ComplexDartSchemaType(DartApiImports imports,
                        Identifier name,
                        {Comment comment})
      : super(imports, name, comment_: comment);

  String get instantiation;

  String get classDefinition;

  String get declaration;
}


/**
 * Represents an unnamed List<T> type with a given `T`.
 */
class UnnamedArrayType extends ComplexDartSchemaType {
  DartSchemaType innerType;

  UnnamedArrayType(DartApiImports imports, this.innerType)
      : super(imports, null);

  DartSchemaType _resolve(DartSchemaTypeDB db) {
    innerType = innerType.resolve(db);
    return this;
  }

  String get instantiation =>
      'new ${imports.core}.List<${innerType.declaration}>()';

  String get classDefinition => null;

  String get declaration => '${imports.core}.List<${innerType.declaration}>';

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

  String get instantiation {
    var from = fromType.declaration;
    var to = toType.declaration;
    return 'new ${imports.core}.Map<$from, $to>()';
  }

  String get classDefinition => null;

  String get declaration {
    var from = fromType.declaration;
    var to = toType.declaration;
    return '${imports.core}.Map<$from, $to>';
  }

  String jsonEncode(String value) {
    return '${imports.internal}.mapMap'
           '(${value}, (item) => ${toType.jsonEncode('item')})';
  }

  String jsonDecode(String json) {
    return '${imports.internal}.mapMap'
           '(${json}, (item) => ${toType.jsonDecode('item')})';
  }
}


/**
 * Represents a named Map<F, T> type with given types `F` and `T`.
 */
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

  String get instantiation {
    var from = fromType.declaration;
    var to = toType.declaration;
    return 'new $className()';
  }

  String get classDefinition {
    var decode = new StringBuffer();
    decode.writeln('  $className.fromJson(${imports.core}.Map json) {');
    decode.writeln('    json.forEach((${imports.core}.String key, value) {');
    decode.writeln('      this[key] = ${toType.jsonDecode('value')};');
    decode.writeln('    });');
    decode.writeln('  }');

    var encode = new StringBuffer();
    encode.writeln('  ${imports.core}.Map toJson() {');
    encode.writeln('    var json = {};');
    encode.writeln('    this.forEach((${imports.core}.String key, value) {');
    encode.writeln('      this[key] = ${toType.jsonEncode('value')};');
    encode.writeln('    });');
    encode.writeln('    return json;');
    encode.write('  }');

    var fromT = fromType.declaration;
    var toT = toType.declaration;

    return
'''
class $className extends ${imports.collection}.MapBase<$fromT, $toT> {
  final ${imports.core}.Map _innerMap = {};
  $className();

$decode
$encode

  ${toType.declaration} operator [](${imports.core}.Object key)
      => _innerMap[key];

  operator []=($fromT key, $toT value) {
    _innerMap[key] = value;
  }

  void clear() {
    _innerMap.clear();
  }

  ${imports.core}.Iterable<$fromT> get keys => _innerMap.keys;

  $toT remove(${imports.core}.Object key) => _innerMap.remove(key);
}
''';
  }

  String get declaration => '$className';

  String jsonEncode(String value) {
    return '${imports.internal}.mapMap'
           '(${value}, (item) => ${toType.jsonEncode('item')})';
  }

  String jsonDecode(String json) {
    return '${imports.internal}.mapMap'
           '(${json}, (item) => ${toType.jsonDecode('item')})';
  }
}


/**
 * Represents a named custom dart class with a number of properties.
 */
class ObjectType extends ComplexDartSchemaType {
  final List<DartClassProperty> properties;
  // FIXME: Can we have subclasses of subclasses ???
  AbstractVariantType superVariantType;

  ObjectType(DartApiImports imports, Identifier name, this.properties,
             {Comment comment})
      : super(imports, name, comment: comment);

  DartSchemaType _resolve(DartSchemaTypeDB db) {
    for (var i = 0; i < properties.length; i++) {
      var property = properties[i];
      var resolvedProperty = new DartClassProperty(
          property.name, property.comment, property.type.resolve(db),
          property.jsonName);
      properties[i] = resolvedProperty;
    }
    return this;
  }

  String get instantiation => 'new $className()';

  String get classDefinition {
    var superClassString = '';
    if (superVariantType != null) {
      superClassString = ' extends ${superVariantType.declaration} ';
    }

    var propertyString = new StringBuffer();
    properties.forEach((DartClassProperty property) {
      var comment = property.comment.asDartDoc(2);
      propertyString.writeln(
          '$comment  ${property.type.declaration} ${property.name};');
      propertyString.writeln();
    });

    var fromJsonString = new StringBuffer();
    fromJsonString.writeln('  $className.fromJson(${imports.core}.Map json) {');
    properties.forEach((DartClassProperty property) {
      var decodeString = property.type.jsonDecode(
          'json["${escapeString(property.jsonName)}"]');
      fromJsonString.writeln('    if (json.containsKey'
                             '("${escapeString(property.jsonName)}")) {');
      fromJsonString.writeln('      ${property.name} = ${decodeString};');
      fromJsonString.writeln('    }');
    });
    fromJsonString.writeln('  }');

    var toJsonString = new StringBuffer();
    toJsonString.writeln('  ${imports.core}.Map toJson() {');
    toJsonString.writeln('    var json = new ${imports.core}.Map();');
    properties.forEach((DartClassProperty property) {
      toJsonString.writeln('    if (${property.name} != null) {');
      toJsonString.writeln('      json["${escapeString(property.jsonName)}"] = '
                           '${property.type.jsonEncode('${property.name}')};');
      toJsonString.writeln('    }');
    });
    toJsonString.writeln('    return json;');
    toJsonString.write('  }');

    return
'''
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

  AbstractVariantType(DartApiImports imports,
                      Identifier name,
                      this.discriminant,
                      this.map,
                      {Comment comment})
      : super(imports, name, comment: comment);

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
    fromJsonString.writeln(
        '  factory $className.fromJson(${imports.core}.Map json) {');
    fromJsonString.writeln('    var discriminant = json["$discriminant"];');
    map.forEach((String name, DartSchemaType type) {
      fromJsonString.writeln('    if (discriminant == "$name") {');
      fromJsonString.writeln('      return new ${type.declaration}'
                             '.fromJson(json);');
      fromJsonString.writeln('    }');
    });
    fromJsonString.writeln('    throw new ${imports.core}.ArgumentError'
                           '("Invalid discriminant: \$discriminant!");');
    fromJsonString.writeln('  }');

    var toJsonString = new StringBuffer();
    toJsonString.writeln('  ${imports.core}.Map toJson();');

    return
'''
abstract class $className {
  $className();
$fromJsonString
$toJsonString
}
''';
  }

  String get declaration => '$className';

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
DartSchemaTypeDB parseSchemas(DartApiImports imports,
                              RestDescription description) {
  var namer = imports.namer;
  var db = new DartSchemaTypeDB(imports);

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
  DartSchemaType parse(String className,
                       Scope classScope,
                       JsonSchema schema,
                       {bool topLevel: false}) {
    if (schema.repeated != null) {
      throw new ArgumentError('Only path/query parameters can be repeated.');
    }

    if (schema.type == 'object') {
      var comment = new Comment(schema.description);

      if (schema.additionalProperties != null) {
        var anonValueClassName =
            namer.schemaClassName('${className}Value');
        var anonClassScope = namer.newClassScope();
        var valueType = parse(anonValueClassName,
                              anonClassScope,
                              schema.additionalProperties);
        if (topLevel) {
          // This is a named map type.
          var classId = namer.schemaClass(className);
          return register(new NamedMapType(
              imports, classId, db.stringType, valueType, comment: comment));
        } else {
          // This is an unnamed map type.
          return register(
              new UnnamedMapType(imports, db.stringType, valueType));
        }
      } else if (schema.variant != null) {
        // This is a variant type, declaring the type discriminant field and all
        // subclasses.
        var map = <String, DartSchemaType>{};
        schema.variant.map.forEach((JsonSchemaVariantMap mapItem) {
          map[mapItem.type_value] =
              new DartSchemaForwardRef(imports, mapItem.$ref);
        });
        var classId = namer.schemaClass(className);
        return register(new AbstractVariantType(
            imports, classId, schema.variant.discriminant, map));
      } else {
        // This is a normal named schema class, we generate a normal
        // [ObjectType] for it with the defined properties.
        var classId = namer.schemaClass(className);
        var properties = new List<DartClassProperty>();
        if (schema.properties != null) {
          orderedForEach(schema.properties,
                         (String jsonPName, JsonSchema value) {
            var propertyName = classScope.newIdentifier(
                jsonPName, public: true);
            var propertyClass = namer.schemaClassName(
                jsonPName, parent: className);
            var propertyClassScope = namer.newClassScope();

            var propertyType = parse(propertyClass, propertyClassScope, value);

            var comment = new Comment(value.description);
            var property = new DartClassProperty(
                propertyName, comment, propertyType, jsonPName);
            properties.add(property);
          });
        }
        return register(
            new ObjectType(imports, classId, properties, comment: comment));
      }
    } else if (schema.type == 'array') {
      // Array of objects
      return register(new UnnamedArrayType(imports,
              parse(className, namer.newClassScope(), schema.items)));
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
      return register(new DartSchemaForwardRef(imports, schema.$ref));
    }
    throw new ArgumentError('Invalid JsonSchema.type (was: ${schema.type}).');
  }

  if (description.schemas != null) {
    orderedForEach(description.schemas, (String name, JsonSchema schema) {
      var className = namer.schemaClassName(name);
      var classScope = namer.newClassScope();
      registerTopLevel(name,
                       parse(className, classScope, schema, topLevel: true));
    });

    // Resolve all forward references and save list in [db.dartTypes].
    db.dartTypes = db.dartTypes.map((type) => type.resolve(db)).toList();

    // Build map of all top level dart schema classes which will be represented
    // as named dart classes.
    db.dartClassTypes.addAll(
        db.dartTypes.where((type) => type.className != null));
  }

  return db;
}

// NOTE: This will be called for resolving parameter types in methods.
DartSchemaType parseResolved(DartApiImports imports,
                             DartSchemaTypeDB db,
                             JsonSchema schema) {
  var primitiveTypes = {
    'boolean' : db.booleanType,
    'string' : db.stringType,
    'number' : db.numberType,
    'double' : db.doubleType,
    'integer' : db.integerType,
  };
  var primitiveType = primitiveTypes[schema.type];
  if (primitiveType == null) {
    throw new ArgumentError('Invalid JsonSchema.type (was: ${schema.type}).');
  }
  if (schema.repeated == null || !schema.repeated) {
    return primitiveType;
  } else {
    return new UnnamedArrayType(imports, primitiveType);
  }
}


/**
 * Generates the codegen'ed dart string for all schema classes.
 */
String generateSchemas(DartSchemaTypeDB db) {
  var sb = new StringBuffer();
  db.dartClassTypes.forEach((ComplexDartSchemaType value) {
    var classDefinition = value.classDefinition;
    if (classDefinition != null) {
      sb.writeln(classDefinition);
      sb.writeln();
    }
  });

  return '$sb';
}
