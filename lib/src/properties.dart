part of discovery_api_client_generator;

class PropClass {
  final String name;

  static const PropClass ARRAY = const PropClass._internal('array');
  static const PropClass OBJECT = const PropClass._internal('object');
  static const PropClass REF = const PropClass._internal('ref');
  static const PropClass SIMPLE = const PropClass._internal('simple');
  static const PropClass TYPED_MAP = const PropClass._internal('map');

  const PropClass._internal(this.name);

  static PropClass getPropClass(JsonSchema propDef) {
    String schemaType = propDef.type;
    if(schemaType == null) {
      assert(propDef.$ref != null);
      schemaType = 'ref';
    } else if(schemaType == 'object') {
      if(propDef.properties == null) {
        assert(propDef.additionalProperties != null);
        schemaType = 'typedMap';
      }
    }

    switch(schemaType) {
      case 'array':
        return PropClass.ARRAY;
      case 'object':
        return PropClass.OBJECT;
      case 'ref':
        return PropClass.REF;
      case 'typedMap':
        return PropClass.TYPED_MAP;
      default:
        return PropClass.SIMPLE;
    }
  }

  String toString() => 'PropClass:$name';
}

abstract class CoreSchemaProp {
  final String schemaName;
  final String dartName;
  final String jsonName;
  final String description;

  String get dartType;

  CoreSchemaProp(String schemaName, this.description) :
    this.schemaName = schemaName,
    dartName = escapeProperty(cleanName(schemaName)),
    jsonName = schemaName.replaceAll("\$", "\\\$");

  factory CoreSchemaProp.parse(String parentName, String schemaName, JsonSchema property) {
    var propClass = PropClass.getPropClass(property);

    switch(propClass) {
      case PropClass.SIMPLE:
        return new SimpleSchemaProp.parse(schemaName, property);
      case PropClass.ARRAY:
        return new ArraySchemaProp.parse(parentName, schemaName, property);
      case PropClass.REF:
        return new RefSchemaProp.parse(parentName, schemaName, property);
      case PropClass.TYPED_MAP:
        return new MapSchemaProp.parse(parentName, schemaName, property);
      case PropClass.OBJECT:
        return new ObjectSchemaProp.parse(parentName, schemaName, property);
      default:
        throw 'Case for $propClass not supported';
    }
  }

  Map<String, JsonSchema> getSubSchemas() => {};

  void writeField(StringSink sink) {
    sink.writeln();
    if (description != null) {
      sink.writeln("  /** $description */");
    }
    sink.writeln("  $dartType $dartName;");
  }

  void writeToJson(StringSink sink) {
    sink.writeln("    if ($dartName != null) {");
    sink.write("      output[\"$jsonName\"] = ");
    writeToJsonExpression(sink, 0);
    sink.writeln(';');
    sink.writeln("    }");
  }

  void writeFromJson(StringSink sink) {
    sink.writeln("    if (json.containsKey(\"$jsonName\")) {");
    sink.write("      $dartName = ");
    writeFromJsonExpression(sink, 0);
    sink.writeln(";");
    sink.writeln("    }");
  }

  void writeToJsonExpression(StringSink sink, int depth);

  void writeFromJsonExpression(StringSink sink, int depth);

  String _getJsonExpression(int depth) {
    assert(depth >= 0);
    if(depth == 0) {
      return 'json[\"$jsonName\"]';
    } else if(depth == 1) {
      return '${dartName}Item';
    } else {
      return '${dartName}Item${depth}';
    }
  }

  String _getDartExpression(int depth) {
    assert(depth >= 0);
    if(depth == 0) {
      return dartName;
    } else if(depth == 1) {
      return '${dartName}Item';
    } else {
      return '${dartName}Item${depth}';
    }
  }
}

class MapSchemaProp extends CoreSchemaProp {
  final CoreSchemaProp itemType;

  factory MapSchemaProp.parse(String parentName, String schemaName, JsonSchema property) {
    var itemProp = new CoreSchemaProp.parse(parentName, schemaName, property.additionalProperties);
    return new MapSchemaProp(schemaName, property.description, itemProp);
  }

  MapSchemaProp(String schemaName, String description, this.itemType)
      : super(schemaName, description) {
    assert(itemType != null);
  }

  String get dartType => 'core.Map<core.String, ${itemType.dartType}>';

  @override
  Map getSubSchemas() => itemType.getSubSchemas();

  @override
  void writeToJsonExpression(StringSink sink, int depth) {

    sink.write('_mapMap(');
    sink.write(_getDartExpression(depth));

    var itemName = itemType._getDartExpression(depth + 1);

    //
    // If the ToJson expression is just the value, we can skip the map
    //
    var buffer = new StringBuffer();
    itemType.writeToJsonExpression(buffer, depth + 1);
    var subExpression = buffer.toString();

    if(subExpression != itemName) {
      sink.write(', ($itemName) => $subExpression');
    }

    sink.write(')');
  }

  @override
  void writeFromJsonExpression(StringSink sink, int depth) {
    var itemExpression = _getJsonExpression(depth);
    sink.write('_mapMap(');
    sink.write(itemExpression);

    var subItemExpression = itemType._getJsonExpression(depth + 1);

    //
    // If the FromJson expression is just the value, we can skip the map
    //
    var buffer = new StringBuffer();
    itemType.writeFromJsonExpression(buffer, depth + 1);
    var subExpression = buffer.toString();

    if(subExpression != subItemExpression) {
      sink.write(', ($subItemExpression) => $subExpression');
    }

    sink.write(')');
  }
}

class ArraySchemaProp extends CoreSchemaProp {
  final CoreSchemaProp itemType;

  factory ArraySchemaProp.parse(String parentName, String schemaName, JsonSchema prop) {
    var itemProp = new CoreSchemaProp.parse(parentName, schemaName, prop.items);
    return new ArraySchemaProp(schemaName, prop.description, itemProp);
  }

  ArraySchemaProp(String schemaName, String description, this.itemType)
      : super(schemaName, description) {
    assert(itemType != null);
  }

  String get dartType => 'core.List<${itemType.dartType}>';

  @override
  Map getSubSchemas() => itemType.getSubSchemas();

  @override
  void writeToJsonExpression(StringSink sink, int depth) {

    sink.write(_getDartExpression(depth));

    var itemName = itemType._getDartExpression(depth + 1);

    //
    // If the ToJson expression is just the value, we can skip the map
    //
    var buffer = new StringBuffer();
    itemType.writeToJsonExpression(buffer, depth + 1);
    var subExpression = buffer.toString();

    if(subExpression != itemName) {
      sink.write('.map(($itemName) => $subExpression)');
    }

    sink.write('.toList()');
  }

  @override
  void writeFromJsonExpression(StringSink sink, int depth) {
    var itemExpression = _getJsonExpression(depth);
    sink.write(itemExpression);

    var subItemExpression = itemType._getJsonExpression(depth + 1);

    //
    // If the FromJson expression is just the value, we can skip the map
    //
    var buffer = new StringBuffer();
    itemType.writeFromJsonExpression(buffer, depth + 1);
    var subExpression = buffer.toString();

    if(subExpression != subItemExpression) {
      sink.write('.map(($subItemExpression) => $subExpression)');
    }

    sink.write('.toList()');
  }
}

String _getDartType(JsonSchema schema) {
  switch(schema.type) {
    case "string":
      return (schema.format == "int64") ? "core.int" : 'core.String';
    case "number":
      return "core.num";
    case "integer":
      return "core.int";
    case "boolean":
      return "core.bool";
    case 'any':
      return 'core.Object';
    default:
      return schema.type;
  }
}

class SimpleSchemaProp extends CoreSchemaProp {
  final String schemaType;
  final String schemaFormat;
  final String dartType;
  static const SIMPLE_TYPES = const ['string', 'boolean', 'integer', 'any', 'number'];

  factory SimpleSchemaProp.parse(String schemaName, JsonSchema prop) {
    var dt = _getDartType(prop);
    return new SimpleSchemaProp(schemaName, prop.type, prop.format, dt, prop.description);
  }

  SimpleSchemaProp(String schemaName, this.schemaType, this.schemaFormat, this.dartType, String description)
      : super(schemaName, description) {
    assert(SIMPLE_TYPES.contains(schemaType));
  }

  @override
  void writeToJsonExpression(StringSink sink, int depth) {
    // TODO: for int64, should the value provided be turned back into a string?
    sink.write(_getDartExpression(depth));
  }

  @override
  void writeFromJsonExpression(StringSink sink, int depth) {
    var jsonExpression = _getJsonExpression(depth);
    if(schemaType=="string" && schemaFormat == "int64") {
      sink.write("($jsonExpression is core.String) ? core.int.parse($jsonExpression) : $jsonExpression");
    } else{
      sink.write(jsonExpression);
    }
  }
}

class RefSchemaProp extends ComplexSchemaProp {

  factory RefSchemaProp.parse(String parentName, String schemaName, JsonSchema property) {
    assert(PropClass.getPropClass(property) == PropClass.REF);

    return new RefSchemaProp(schemaName, property.$ref, property.description);
  }

  RefSchemaProp(String sourceName, String dartType, String description) :
    super(sourceName, dartType, description);
}

class ObjectSchemaProp extends ComplexSchemaProp {
  final JsonSchema propDefinition;

  factory ObjectSchemaProp.parse(String parentName, String schemaName, JsonSchema property) {
    assert(PropClass.getPropClass(property) == PropClass.OBJECT);

    var dartType = "${capitalize(parentName)}${capitalize(schemaName)}";

    return new ObjectSchemaProp(schemaName, dartType, property, property.description);
  }

  ObjectSchemaProp(String sourceName, String dartType, this.propDefinition, String description) :
    super(sourceName, dartType, description);

  @override
  Map<String, JsonSchema> getSubSchemas() => new Map()
    ..[dartType] = propDefinition;
}

abstract class ComplexSchemaProp extends CoreSchemaProp {
  final String dartType;

  ComplexSchemaProp(String schemaName, this.dartType, String description) :
    super(schemaName, description) {
    assert(dartType != null);
    // TODO: assert dartType is a valid type for Dart
  }

  @override
  void writeToJsonExpression(StringSink sink, int depth) {
    sink.write("${_getDartExpression(depth)}.toJson()");
  }

  @override
  void writeFromJsonExpression(StringSink sink, int depth) {
    var jsonExpression = _getJsonExpression(depth);
    sink.write("new $dartType.fromJson($jsonExpression)");
  }
}
