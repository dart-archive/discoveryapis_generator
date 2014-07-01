import 'package:discovery_api_client_generator/generator.dart';
import 'package:google_discovery_v1_api/discovery_v1_api_client.dart';
import 'package:unittest/unittest.dart';

withParsedDB(json, function) {
  var namer = new ApiLibraryNamer();
  var imports = new DartApiImports.fromNamer(namer);

  var description = new RestDescription.fromJson(json);
  var db = parseSchemas(imports, description);

  namer.nameAllIdentifiers();

  return function(db);
}

main() {
  group('dart-schemas', () {
    test('empty', () {
      withParsedDB({}, (DartSchemaTypeDB db) {
        expect(db.dartTypes, hasLength(0));
        expect(db.namedSchemaTypes, hasLength(0));
        expect(db.dartClassTypes, hasLength(0));
      });

      withParsedDB({
        'empty-schemas' : {}
      }, (DartSchemaTypeDB db) {
        expect(db.dartTypes, hasLength(0));
        expect(db.namedSchemaTypes, hasLength(0));
        expect(db.dartClassTypes, hasLength(0));
      });
    });

    test('invalid', () {
      expect(() => withParsedDB({
        'schemas' : {
          'Task' : {
            'type' : 'object',
            'repeated' : true,
          },
        }
      }, () {}), throwsArgumentError);
    });

    test('object-schema', () {
      withParsedDB({
        'schemas' : {
          'Task' : {
            'type' : 'object',
            'properties' : {
              'age' : { 'type': 'integer' },
              'any' : { 'type': 'any' },
              'isMale' : { 'type': 'boolean' },
              'labels' : {
                'type': 'array',
                'items' : {
                  'type' : 'integer',
                },
              },
              'name' : { 'type': 'string' },
              'properties' : {
                'type': 'object',
                'additionalProperties' : {
                  'type' : 'string',
                },
              },
            },
          },
        }
      }, (DartSchemaTypeDB db) {
        expect(db.dartTypes, hasLength(3));
        expect(db.namedSchemaTypes, hasLength(1));
        expect(db.dartClassTypes, hasLength(1));

        expect(db.namedSchemaTypes, contains('Task'));
        expect(db.dartClassTypes, hasLength(1));
        ObjectType task = db.dartClassTypes.first;
        expect(db.dartTypes, contains(task));
        expect(db.namedSchemaTypes['Task'], equals(task));

        // Do tests on `task`.
        expect(task is ObjectType, isTrue);
        expect(task.className.name, equals('Task'));
        expect(task.superVariantType, isNull);

        // Do tests on `task.properties`.

        var age = task.properties[0];
        expect(age, isNotNull);
        expect(age.name.name, equals('age'));
        expect(age.type, equals(db.integerType));

        var any = task.properties[1];
        expect(any, isNotNull);
        expect(any.name.name, equals('any'));
        expect(any.type, equals(db.anyType));

        var isMale = task.properties[2];
        expect(isMale, isNotNull);
        expect(isMale.name.name, equals('isMale'));
        expect(isMale.type, equals(db.booleanType));

        var labels = task.properties[3];
        expect(labels, isNotNull);
        expect(labels.name.name, equals('labels'));
        expect(labels.type is UnnamedArrayType, isTrue);
        UnnamedArrayType lablesTyped = labels.type;
        expect(lablesTyped.className, isNull);
        expect(lablesTyped.innerType, equals(db.integerType));

        var name = task.properties[4];
        expect(name, isNotNull);
        expect(name.name.name, equals('name'));
        expect(name.type, equals(db.stringType));

        var properties = task.properties[5];
        expect(properties, isNotNull);
        expect(properties.name.name, equals('properties'));
        expect(properties.type is UnnamedMapType, isTrue);
        UnnamedMapType propertiesTyped = properties.type;
        expect(propertiesTyped.className, isNull);
        expect(propertiesTyped.fromType, equals(db.stringType));
        expect(propertiesTyped.toType, equals(db.stringType));
      });
    });

    test('variant-schema-with-forward-references', () {
      withParsedDB({
        'schemas' : {
          'Geometry' : {
            'type' : 'object',
            'variant' : {
              'discriminant' : 'my_type',
              'map' : [
                  {
                    'type_value' : 'my_line_type',
                    '\$ref' : 'LineGeometry',
                  },
                  {
                    'type_value' : 'my_polygon_type',
                    '\$ref' : 'PolygonGeometry',
                  },
              ],
            },
          },
          'LineGeometry' : {
            'type' : 'object',
            'properties' : {
              'label' : {'type' : 'string' },
            },
          },
          'PolygonGeometry' : {
            'type' : 'object',
            'properties' : {
              'points' : {'type' : 'integer' },
            },
          }
        }
      }, (DartSchemaTypeDB db) {
        expect(db.dartTypes, hasLength(3));
        expect(db.namedSchemaTypes, hasLength(3));
        expect(db.dartClassTypes, hasLength(3));

        // 'Geometry' variant schema.
        expect(db.namedSchemaTypes, contains('Geometry'));
        AbstractVariantType geo = db.dartClassTypes[0];
        expect(db.dartTypes, contains(geo));
        expect(db.namedSchemaTypes['Geometry'], equals(geo));

        // 'LineGeometry' schema
        expect(db.namedSchemaTypes, contains('LineGeometry'));
        ObjectType lineGeo = db.dartClassTypes[1];
        expect(db.dartTypes, contains(lineGeo));
        expect(db.namedSchemaTypes['LineGeometry'], equals(lineGeo));

        // 'PolygonGeometry' schema
        expect(db.namedSchemaTypes, contains('PolygonGeometry'));
        ObjectType polyGeo = db.dartClassTypes[2];
        expect(db.dartTypes, contains(polyGeo));
        expect(db.namedSchemaTypes['PolygonGeometry'], equals(polyGeo));

        // Check variant map
        expect(geo.className.name, equals('Geometry'));
        expect(geo.discriminant, equals('my_type'));
        expect(geo.map, contains('my_line_type'));
        expect(geo.map['my_line_type'], equals(lineGeo));
        expect(geo.map, contains('my_polygon_type'));
        expect(geo.map['my_polygon_type'], equals(polyGeo));

        expect(lineGeo.className.name, equals('LineGeometry'));
        expect(lineGeo.properties.first.name.name, equals('label'));
        expect(lineGeo.properties.first.type, equals(db.stringType));
        expect(polyGeo.className.name, equals('PolygonGeometry'));
        expect(polyGeo.properties.first.name.name, equals('points'));
        expect(polyGeo.properties.first.type, equals(db.integerType));
      });
    });


    test('object-schema-name-overlap', () {
      withParsedDB({
        'schemas' : {
          // Task, TaskName, TaskName_1
          'Overlap' : {
            'type' : 'object',
            'properties' : {
              'array' : {
                'type': 'array',
                'items' : {
                  'type' : 'integer',
                },
              },
              'object' : {
                'type': 'object',
                'properties' : {
                  'prop' : {'type' : 'integer'},
                },
              },
              'integer' : {
                'type': 'integer',
              },
            },
          },
          'OverlapArray' : {
            'type' : 'object',
            'properties' : {
              'oaprop' : { 'type': 'integer' },
            },
          },
          'OverlapObject' : {
            'type' : 'object',
            'properties' : {
              'ooprop' : { 'type': 'integer' },
            },
          },
          // INFO: Should generate the following classes:
          // Overlap, OverlapArray, OverlapObject, OverlapObject_1
          //
          // NOTE: Since we don't generate a class for
          // - [Overlap.array]
          // - [Overlap.integer]
          // we can assert that
          // - the name 'OverlapArray' will not be allocated twice
          // - the name 'OverlapInteger' will not be allocated
        }
      }, (DartSchemaTypeDB db) {
        expect(db.dartClassTypes, hasLength(4));

        expect(db.namedSchemaTypes, hasLength(3));
        expect(db.namedSchemaTypes, contains('Overlap'));
        expect(db.namedSchemaTypes, contains('OverlapArray'));
        expect(db.namedSchemaTypes, contains('OverlapObject'));

        // The order in [db.dartClassTypes] is:
        // depth-first traversal with postorder node processing.
        //
        // Naming happens on the scope tree level-by-level, so it depends on
        // the order of insertion into the scope.
        expect(db.dartClassTypes, hasLength(4));
        expect(db.dartClassTypes[0].className.name, equals('OverlapObject'));
        expect(db.dartClassTypes[1].className.name, equals('Overlap'));
        expect(db.dartClassTypes[2].className.name, equals('OverlapArray'));
        expect(db.dartClassTypes[3].className.name, equals('OverlapObject_1'));

        expect(db.dartClassTypes[1],
               equals(db.namedSchemaTypes['Overlap']));
        expect(db.dartClassTypes[2],
               equals(db.namedSchemaTypes['OverlapArray']));
        expect(db.dartClassTypes[3],
               equals(db.namedSchemaTypes['OverlapObject']));
      });
    });

    test('named-map-schema', () {
      withParsedDB({
        'schemas' : {
          'Properties' : {
            'type' : 'object',
            'additionalProperties' : {
              'type' : 'integer',
            },
          },
        }
      }, (DartSchemaTypeDB db) {
        expect(db.dartTypes, hasLength(1));
        expect(db.namedSchemaTypes, hasLength(1));
        expect(db.dartClassTypes, hasLength(1));

        expect(db.namedSchemaTypes, contains('Properties'));
        NamedMapType properties = db.dartClassTypes.first;
        expect(properties.className.name, equals('Properties'));
        expect(properties.fromType, equals(db.stringType));
        expect(properties.toType, equals(db.integerType));
      });
    });
  });
}
