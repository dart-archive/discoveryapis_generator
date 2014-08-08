part of discovery_api_client_generator;


/**
 * Generates a API test library based on a [DartApiLibrary].
 */
class DartApiTestLibrary extends TestHelper {
  final DartApiLibrary apiLibrary;
  final String apiImportPath;

  final Map<DartSchemaType, SchemaTest> schemaTests = {};
  final List<ResourceTest> resourceTests = [];
  final Map<ResourceTest, ResourceTest> parentResourceTests = {};

  /**
   * Generates a API test library for [apiLibrary].
   */
  DartApiTestLibrary.build(this.apiLibrary, this.apiImportPath) {
    handleType(DartSchemaType schema) {
      schemaTests.putIfAbsent(schema, () => testFromSchema(this, schema));
    }

    traverseResource(DartResourceClass resource, parent, nameInParent) {
      // Method parameters might have more types we need to register
      // (e.g. List<String>):
      for (var method in resource.methods) {
        method.parameters.forEach((p) => handleType(p.type));
        method.namedParameters.forEach((p) => handleType(p.type));
      }

      // Register resource tests.
      var test = new ResourceTest(this, resource, parent, nameInParent);
      if (resource.methods.length > 0) {
        resourceTests.add(test);
      }
      for (int i = 0; i < resource.subResources.length; i++) {
        var subResource = resource.subResources[i];
        var subResourceName = resource.subResourceIdentifiers[i];
        traverseResource(subResource, test, subResourceName);
      }
    }

    // Build up [schemaTests] and [resourceTests].
    var db = apiLibrary.schemaDB;
    handleType(db.integerType);
    handleType(db.numberType);
    handleType(db.doubleType);
    handleType(db.booleanType);
    handleType(db.stringType);
    handleType(db.anyType);

    apiLibrary.schemaDB.dartTypes.forEach(handleType);

    traverseResource(apiLibrary.apiClass, null, null);
  }

  String get librarySource {
    var sink = new StringBuffer();
    sink.writeln(libraryHeader);

    // Build functions for creating schema objects and for validating them.
    schemaTests.forEach((DartSchemaType schema, SchemaTest test) {
      if (test == null) print("${schema.runtimeType}");
      sink.write(test.buildSchemaFunction);
      sink.write(test.checkSchemaFunction);
    });

    sink.writeln();

    withFunc(0, sink, 'main', '', () {
      schemaTests.forEach((DartSchemaType schema, SchemaTest test) {
        sink.write(test.schemaTest);
      });
      resourceTests.forEach((test) => sink.write(test.resourceTest));
    });

    return '$sink';
  }

  String get libraryHeader {
    return
"""
library ${apiLibrary.libraryName}.test;

import "dart:core" as core;
import "dart:collection" as collection;
import "dart:async" as async;
import "dart:convert" as convert;

import 'package:http_base/http_base.dart' as http_base;
import 'package:unittest/unittest.dart' as unittest;
import 'package:googleapis/common/common.dart' as common;
import 'package:googleapis/src/common_internal.dart' as common_internal;
import '../common/common_internal_test.dart' as common_test;

import '$apiImportPath' as api;


""";
  }
}

/**
 * Will generate tests for [resource] of [apiLibrary].
 */
class ResourceTest extends TestHelper {
  final DartApiTestLibrary apiTestLibrary;
  final DartResourceClass resource;
  DartApiLibrary apiLibrary;
  final ResourceTest parent;
  final Identifier nameInParent;

  ResourceTest(
      this.apiTestLibrary, this.resource, this.parent, this.nameInParent) {
    apiLibrary = apiTestLibrary.apiLibrary;
  }

  String apiConstruction(String clientName) {
    if (parent == null) {
      return 'new api.${resource.className.name}($clientName)';
    } else {
      return '${parent.apiConstruction(clientName)}.${nameInParent.name}';
    }
  }

  String get resourceTest {
    var sb = new StringBuffer();

    var db = apiLibrary.schemaDB;
    withTestGroup(2, sb, 'resource-${resource.className}', () {
      for (var method in resource.methods) {
        withTest(4, sb, 'method--${method.name.name}', () {
          sb.writeln('      // TODO: Implement tests for media upload;');
          sb.writeln('      // TODO: Implement tests for media download;');
          sb.writeln();

          // Method building.
          sb.writeln('      var mock = new common_test.HttpServerMock();');
          sb.writeln('      mock.register(unittest.expectAsync('
                     '(http_base.Request req, json) {');
          if (method.requestParameter != null) {
            var t = apiTestLibrary.schemaTests[method.requestParameter.type];
            var name = method.requestParameter.type.className;
            sb.writeln('        var obj = new api.${name}.fromJson(json);');
            sb.writeln('        ${t.checkSchemaStatement('obj')}');
            sb.writeln();
          }

          sb.writeln('        // TODO: Validate [req.uri].');
          sb.writeln();
          sb.writeln('        var h = new http_base.HeadersImpl({');
          sb.writeln('          '
                     '"content-type" : ["application/json; charset=utf-8"],');
          sb.writeln('        });');
          if (method.returnType == null) {
            sb.writeln('        var resp = "";');
          } else {
            var t = apiTestLibrary.schemaTests[method.returnType];
            sb.writeln('        var resp = '
                       'convert.JSON.encode(${t.newSchemaExpr});');
          }
          sb.writeln('        return new async.Future.value('
                     'common_test.stringResponse(200, h, resp));');
          sb.writeln('      }), true);');

          // Method argument building
          sb.writeln('      api.${resource.className} res = '
                     '${apiConstruction('mock')};');

          var args = [];
          void newParameter(MethodParameter p) {
            var schemaTest = apiTestLibrary.schemaTests[p.type];
            var name = 'arg_${p.name}';
            sb.writeln('      var $name = ${schemaTest.newSchemaExpr};');
            if (p.required) {
              args.add(name);
            } else {
              args.add('${p.name}: $name');
            }
          }

          if (method.requestParameter != null) {
            newParameter(method.requestParameter);
          }
          method.parameters.forEach(newParameter);
          method.namedParameters.forEach(newParameter);

          // Method call
          sb.write('      res.${method.name}(${args.join(', ')})'
                   '.then(unittest.expectAsync(');
          if (method.returnType == null) {
            sb.write('(_) {}');
          } else {
            var t = apiTestLibrary.schemaTests[method.returnType];
            sb.writeln('((api.${method.returnType.className} response) {');
            sb.writeln('        ${t.checkSchemaStatement('response')}');
            sb.write('      })');
          }
          sb.writeln('));');
        });
        sb.writeln();
      }
    });
    return '$sb';
  }
}

testFromSchema(apiTestLibrary, schema) {
  if (schema is ObjectType) {
    return new ObjectSchemaTest(apiTestLibrary, schema);
  } else if (schema is NamedMapType) {
    return new NamedMapSchemaTest(apiTestLibrary, schema);
  } else if (schema is IntegerType) {
    return new IntSchemaTest(apiTestLibrary, schema);
  } else if (schema is DoubleType) {
    return new DoubleSchemaTest(apiTestLibrary, schema);
  } else if (schema is NumberType) {
    return new NumberSchemaTest(apiTestLibrary, schema);
  } else if (schema is BooleanType) {
    return new BooleanSchemaTest(apiTestLibrary, schema);
  } else if (schema is StringType) {
    return new StringSchemaTest(apiTestLibrary, schema);
  } else if (schema is UnnamedArrayType) {
    return new UnnamedArrayTest(apiTestLibrary, schema);
  } else if (schema is UnnamedMapType) {
    return new UnnamedMapTest(apiTestLibrary, schema);
  } else if (schema is AbstractVariantType) {
    return new AbstractVariantSchemaTest(apiTestLibrary, schema);
  } else if (schema is NamedArrayType) {
    return new NamedArraySchemaTest(apiTestLibrary, schema);
  } else if (schema is AnyType) {
    return new AnySchemaTest(apiTestLibrary, schema);
  } else {
    throw new UnimplementedError(
        '${schema.runtimeType} -- no test implemented.');
  }
}

/**
 * Will generate tests for [schema] of [apiLibrary].
 */
abstract class SchemaTest<T> extends TestHelper {
  final DartApiTestLibrary apiTestLibrary;
  final T schema;
  DartApiLibrary apiLibrary;

  SchemaTest(this.apiTestLibrary, this.schema) {
    apiLibrary = apiTestLibrary.apiLibrary;
  }

  String get declaration;
  String get buildSchemaFunction;
  String get newSchemaExpr;
  String get checkSchemaFunction;
  String checkSchemaStatement(String o);
  String get schemaTest;
}

abstract class PrimitiveSchemaTest<T> extends SchemaTest<T> {
  PrimitiveSchemaTest(apiTestLibrary, schema) : super(apiTestLibrary, schema);

  String get buildSchemaFunction => '';

  String get checkSchemaFunction => '';

  String get schemaTest => '';
}

class IntSchemaTest extends PrimitiveSchemaTest<IntegerType> {
  IntSchemaTest(apiTestLibrary, schema) : super(apiTestLibrary, schema);
  String get declaration => 'core.int';
  String get newSchemaExpr => '42';
  String checkSchemaStatement(String o)
      => 'unittest.expect($o, unittest.equals(42));';
}

class DoubleSchemaTest extends PrimitiveSchemaTest<DoubleType> {
  DoubleSchemaTest(apiTestLibrary, schema) : super(apiTestLibrary, schema);
  String get declaration => 'core.double';
  String get newSchemaExpr => '42.0';
  String checkSchemaStatement(String o)
      => 'unittest.expect($o, unittest.equals(42.0));';
}

class NumberSchemaTest extends PrimitiveSchemaTest<NumberType> {
  NumberSchemaTest(apiTestLibrary, schema) : super(apiTestLibrary, schema);
  String get declaration => 'core.num';
  String get newSchemaExpr => '42.0';
  String checkSchemaStatement(String o)
      => 'unittest.expect($o, unittest.equals(42.0));';
}

class BooleanSchemaTest extends PrimitiveSchemaTest<BooleanType> {
  BooleanSchemaTest(apiTestLibrary, schema) : super(apiTestLibrary, schema);
  String get declaration => 'core.bool';
  String get newSchemaExpr => 'true';
  String checkSchemaStatement(String o)
      => 'unittest.expect($o, unittest.isTrue);';
}

class StringSchemaTest extends PrimitiveSchemaTest<StringType> {
  StringSchemaTest(apiTestLibrary, schema) : super(apiTestLibrary, schema);
  String get declaration => 'core.String';
  String get newSchemaExpr => '"foo"';
  String checkSchemaStatement(String o)
      => 'unittest.expect($o, unittest.equals("foo"));';
}

abstract class UnnamedSchemaTest<T> extends SchemaTest<T> {
  static int UnnamedCounter = 0;
  int _id = UnnamedCounter++;

  UnnamedSchemaTest(apiTestLibrary, schema) : super(apiTestLibrary, schema);

  String get schemaTest => '';

  String get newSchemaExpr => 'buildUnnamed$_id()';

  String checkSchemaStatement(String obj) => 'checkUnnamed$_id($obj);';
}

class UnnamedMapTest extends UnnamedSchemaTest<UnnamedMapType> {
  UnnamedMapTest(apiTestLibrary, schema) : super(apiTestLibrary, schema);

  String get declaration {
    var toType = apiTestLibrary.schemaTests[schema.toType].declaration;
    return 'core.Map<core.String, $toType>';
  }

  String get buildSchemaFunction {
    var innerTest = apiTestLibrary.schemaTests[schema.toType];

    var sb = new StringBuffer();
    withFunc(0, sb, 'buildUnnamed$_id', '', () {
      sb.writeln('  var o = new $declaration();');
      sb.writeln('  o["x"] = ${innerTest.newSchemaExpr};');
      sb.writeln('  o["y"] = ${innerTest.newSchemaExpr};');
      sb.writeln('  return o;');
    });
    return '$sb';
  }

  String get checkSchemaFunction {
    var innerTest = apiTestLibrary.schemaTests[schema.toType];

    var sb = new StringBuffer();
    withFunc(0, sb, 'checkUnnamed$_id', '$declaration o', () {
      sb.writeln('  unittest.expect(o, unittest.hasLength(2));');
      sb.writeln('  ${innerTest.checkSchemaStatement('o["x"]')}');
      sb.writeln('  ${innerTest.checkSchemaStatement('o["y"]')}');
    });
    return '$sb';
  }
}

class UnnamedArrayTest<T> extends UnnamedSchemaTest<UnnamedArrayType> {
  UnnamedArrayTest(apiTestLibrary, schema) : super(apiTestLibrary, schema);

  String get declaration {
    var innerType = apiTestLibrary.schemaTests[schema.innerType].declaration;
    return 'core.List<$innerType>';
  }

  String get buildSchemaFunction {
    var innerTest = apiTestLibrary.schemaTests[schema.innerType];

    var sb = new StringBuffer();
    withFunc(0, sb, 'buildUnnamed$_id', '', () {
      sb.writeln('  var o = new $declaration();');
      sb.writeln('  o.add(${innerTest.newSchemaExpr});');
      sb.writeln('  o.add(${innerTest.newSchemaExpr});');
      sb.writeln('  return o;');
    });
    return '$sb';
  }

  String get checkSchemaFunction {
    var innerTest = apiTestLibrary.schemaTests[schema.innerType];

    var sb = new StringBuffer();
    withFunc(0, sb, 'checkUnnamed$_id', '$declaration o', () {
      sb.writeln('  unittest.expect(o, unittest.hasLength(2));');
      sb.writeln('  ${innerTest.checkSchemaStatement('o[0]')}');
      sb.writeln('  ${innerTest.checkSchemaStatement('o[1]')}');
    });
    return '$sb';
  }
}

abstract class NamedSchemaTest<T extends ComplexDartSchemaType>
    extends SchemaTest<T> {
  NamedSchemaTest(apiTestLibrary, schema) : super(apiTestLibrary, schema);

  String get declaration => 'api.${schema.className}';

  String get schemaTest {
    var db = apiLibrary.schemaDB;
    var sb = new StringBuffer();
    withTestGroup(2, sb, 'obj-schema-${schema.className}', () {
      withTest(4, sb, 'to-json--from-json', () {
        sb.writeln('      var o = ${newSchemaExpr};');
        sb.writeln('      var od = new api.${schema.className.name}'
                   '.fromJson(o.toJson());');
        sb.writeln('      ${checkSchemaStatement('od')}');
      });
    });
    return '$sb';
  }

  String get newSchemaExpr => 'build${schema.className.name}()';

  String checkSchemaStatement(String obj) =>
      'check${schema.className.name}($obj);';
}

class ObjectSchemaTest extends NamedSchemaTest<ObjectType> {
  ObjectSchemaTest(apiTestLibrary, schema) : super(apiTestLibrary, schema);

  String get counterName => 'buildCounter${schema.className.name}';

  String get buildSchemaFunction {
    var sb = new StringBuffer();

    // Having cycles in schema definitions will result in stack overflows while
    // generatinge example schema data.
    // We break these cycles at object schemas, by using an increasing counter.
    // Assumption: Every cycle will contain normal object schemas.
    sb.writeln('core.int $counterName = 0;');

    withFunc(0, sb, 'build${schema.className.name}', '', () {
      sb.writeln('  var o = new $declaration();');
      sb.writeln('  $counterName++;');
      sb.writeln('  if ($counterName < 3) {');
      for (DartClassProperty prop in schema.properties) {
        if (!schema.isVariantDiscriminator(prop)) {
          var propertyTest = apiTestLibrary.schemaTests[prop.type];
          sb.writeln('    o.${prop.name.name} = '
                     '${propertyTest.newSchemaExpr};');
        }
      }
      sb.writeln('  }');
      sb.writeln('  $counterName--;');
      sb.writeln('  return o;');
    });
    return '$sb';
  }

  String get checkSchemaFunction {
    var sb = new StringBuffer();
    withFunc(0, sb, 'check${schema.className.name}', '$declaration o', () {
      sb.writeln('  $counterName++;');
      sb.writeln('  if ($counterName < 3) {');
      for (DartClassProperty prop in schema.properties) {
        if (!schema.isVariantDiscriminator(prop)) {
          var propertyTest = apiTestLibrary.schemaTests[prop.type];
          var name = prop.name.name;
          sb.writeln('    ${propertyTest.checkSchemaStatement('o.$name')}');
        }
      }
      sb.writeln('  }');
      sb.writeln('  $counterName--;');
    });
    return '$sb';
  }
}

class NamedArraySchemaTest extends NamedSchemaTest<NamedArrayType> {
  NamedArraySchemaTest(apiTestLibrary, schema) : super(apiTestLibrary, schema);

  String get buildSchemaFunction {
    var innerTest = apiTestLibrary.schemaTests[schema.innerType];

    var sb = new StringBuffer();
    withFunc(0, sb, 'build${schema.className.name}', '', () {
      sb.writeln('  var o = new $declaration();');
      sb.writeln('  o.add(${innerTest.newSchemaExpr});');
      sb.writeln('  o.add(${innerTest.newSchemaExpr});');
      sb.writeln('  return o;');
    });
    return '$sb';
  }

  String get checkSchemaFunction {
    var innerTest = apiTestLibrary.schemaTests[schema.innerType];

    var sb = new StringBuffer();
    withFunc(0, sb, 'check${schema.className.name}', '$declaration o', () {
      sb.writeln('  unittest.expect(o, unittest.hasLength(2));');
      sb.writeln('  ${innerTest.checkSchemaStatement('o[0]')}');
      sb.writeln('  ${innerTest.checkSchemaStatement('o[1]')}');
    });
    return '$sb';
  }
}

class NamedMapSchemaTest extends NamedSchemaTest<NamedMapType> {
  NamedMapSchemaTest(apiTestLibrary, schema) : super(apiTestLibrary, schema);

  String get buildSchemaFunction {
    var innerTest = apiTestLibrary.schemaTests[schema.toType];

    var sb = new StringBuffer();
    withFunc(0, sb, 'build${schema.className.name}', '', () {
      sb.writeln('  var o = new $declaration();');
      sb.writeln('  o["a"] = ${innerTest.newSchemaExpr};');
      sb.writeln('  o["b"] = ${innerTest.newSchemaExpr};');
      sb.writeln('  return o;');
    });
    return '$sb';
  }

  String get checkSchemaFunction {
    var innerTest = apiTestLibrary.schemaTests[schema.toType];

    var sb = new StringBuffer();
    withFunc(0, sb, 'check${schema.className.name}', '$declaration o', () {
      sb.writeln('  unittest.expect(o, unittest.hasLength(2));');
      sb.writeln('  ${innerTest.checkSchemaStatement('o["a"]')}');
      sb.writeln('  ${innerTest.checkSchemaStatement('o["b"]')}');
    });
    return '$sb';
  }
}

class AbstractVariantSchemaTest extends NamedSchemaTest<AbstractVariantType> {
  var subSchema, subSchemaTest;

  AbstractVariantSchemaTest(apiTestLibrary, schema)
      : super(apiTestLibrary, schema);

  void _init() {
    if (subSchema == null) {
      // Randomly sample one of the subtypes!?
      subSchema = schema.map.values.first;
      subSchemaTest = apiTestLibrary.schemaTests[subSchema];
    }
  }

  String get buildSchemaFunction {
    _init();

    var sb = new StringBuffer();
    withFunc(0, sb, 'build${schema.className.name}', '', () {
      sb.writeln('  return ${subSchemaTest.newSchemaExpr};');
    });
    return '$sb';
  }

  String get checkSchemaFunction {
    _init();

    var sb = new StringBuffer();
    withFunc(0, sb, 'check${schema.className.name}', '$declaration o', () {
      sb.writeln('  ${subSchemaTest.checkSchemaFunction}(o);');
    });
    return '$sb';
  }
}

class AnySchemaTest extends SchemaTest<AnyType> {
  int _counter = 0;

  AnySchemaTest(apiTestLibrary, schema) : super(apiTestLibrary, schema);

  String get buildSchemaFunction => '';

  String get checkSchemaFunction => '';

  String get schemaTest => '';

  String get declaration => 'core.Object';

  String get newSchemaExpr {
    return "{'list' : [1, 2, 3], 'bool' : true, 'string' : 'foo'}";
  }

  String checkSchemaStatement(String o) {
    _counter++;
    var uhl = 'unittest.hasLength';
    var ue = 'unittest.expect';
    var ueq = 'unittest.equals';
    return "var casted$_counter = ($o) as core.Map; "
           "$ue(casted$_counter, $uhl(3)); "
           "$ue(casted$_counter['list'], $ueq([1, 2, 3])); "
           "$ue(casted$_counter['bool'], $ueq(true)); "
           "$ue(casted$_counter['string'], $ueq('foo'));";
  }
}

/**
 * Helps generating unittests.
 */
class TestHelper {
  void withFunc(int indentation, StringBuffer buffer,
                String name, String args, Function f) {
    var spaces = ' ' * indentation;
    buffer.write(spaces);
    buffer.writeln('$name($args) {');
    f();
    buffer.write(spaces);
    buffer.writeln('}\n');
  }

  void withTestGroup(int indentation, StringBuffer buffer,
                     String name, Function f) {
    var spaces = ' ' * indentation;
    buffer.write(spaces);
    buffer.writeln('unittest.group("$name", () {');
    f();
    buffer.write(spaces);
    buffer.writeln('});\n\n');
  }

  void withTest(int indentation, StringBuffer buffer,
                String name, Function f) {
    var spaces = ' ' * indentation;
    buffer.write(spaces);
    buffer.writeln('unittest.test("$name", () {');
    f();
    buffer.write(spaces);
    buffer.writeln('});');
  }
}
