import 'package:discovery_api_client_generator/generator.dart';
import 'package:google_discovery_v1_api/discovery_v1_api_client.dart';
import 'package:unittest/unittest.dart';

withParsedDB(json, function) {
  var description = new RestDescription.fromJson(json);
  var db = parseSchemas(description);
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

    test('object-schema', () {
      withParsedDB({
        'schemas' : {
          'Task' : {
            'type' : 'object',
            'properties' : {
              'name' : { 'type': 'string' },
              'isMale' : { 'type': 'boolean' },
              'age' : { 'type': 'integer' },
              'any' : { 'type': 'any' },
              'labels' : {
                'type': 'array',
                'items' : {
                  'type' : 'integer',
                },
              },
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
        expect(db.dartClassTypes, contains('Task'));
        ObjectType task = db.dartClassTypes['Task'];
        expect(db.dartTypes, contains(task));
        expect(db.namedSchemaTypes['Task'], equals(task));

        // Do tests on `task`.
        expect(task is ObjectType, isTrue);
        expect(task.className, equals('Task'));
        expect(task.superVariantType, isNull);

        // Do tests on `task.properties`.
        var name = task.properties['name'];
        expect(name, isNotNull);
        expect(name.name, equals('name'));
        expect(name.type, equals(db.stringType));

        var isMale = task.properties['isMale'];
        expect(isMale, isNotNull);
        expect(isMale.name, equals('isMale'));
        expect(isMale.type, equals(db.booleanType));

        var age = task.properties['age'];
        expect(age, isNotNull);
        expect(age.name, equals('age'));
        expect(age.type, equals(db.integerType));

        var any = task.properties['any'];
        expect(any, isNotNull);
        expect(any.name, equals('any'));
        expect(any.type, equals(db.anyType));

        var labels = task.properties['labels'];
        expect(labels, isNotNull);
        expect(labels.name, equals('labels'));
        expect(labels.type is UnnamedArrayType, isTrue);
        UnnamedArrayType lablesTyped = labels.type;
        expect(lablesTyped.className, isNull);
        expect(lablesTyped.innerType, equals(db.integerType));

        var properties = task.properties['properties'];
        expect(properties, isNotNull);
        expect(properties.name, equals('properties'));
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
        expect(db.dartClassTypes, contains('Geometry'));
        expect(db.namedSchemaTypes, contains('Geometry'));
        AbstractVariantType geo = db.dartClassTypes['Geometry'];
        expect(db.dartTypes, contains(geo));
        expect(db.namedSchemaTypes['Geometry'], equals(geo));

        // 'LineGeometry' schema
        expect(db.dartClassTypes, contains('LineGeometry'));
        expect(db.namedSchemaTypes, contains('LineGeometry'));
        ObjectType lineGeo = db.dartClassTypes['LineGeometry'];
        expect(db.dartTypes, contains(lineGeo));
        expect(db.namedSchemaTypes['LineGeometry'], equals(lineGeo));

        // 'PolygonGeometry' schema
        expect(db.dartClassTypes, contains('PolygonGeometry'));
        expect(db.namedSchemaTypes, contains('PolygonGeometry'));
        ObjectType polyGeo = db.dartClassTypes['PolygonGeometry'];
        expect(db.dartTypes, contains(polyGeo));
        expect(db.namedSchemaTypes['PolygonGeometry'], equals(polyGeo));

        // Check variant map
        expect(geo.className, equals('Geometry'));
        expect(geo.discriminant, equals('my_type'));
        expect(geo.map, contains('my_line_type'));
        expect(geo.map['my_line_type'], equals(lineGeo));
        expect(geo.map, contains('my_polygon_type'));
        expect(geo.map['my_polygon_type'], equals(polyGeo));

        expect(lineGeo.className, equals('LineGeometry'));
        expect(lineGeo.properties['label'].name, equals('label'));
        expect(lineGeo.properties['label'].type, equals(db.stringType));
        expect(polyGeo.className, equals('PolygonGeometry'));
        expect(polyGeo.properties['points'].name, equals('points'));
        expect(polyGeo.properties['points'].type, equals(db.integerType));
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

        expect(db.dartClassTypes, contains('Properties'));
        expect(db.namedSchemaTypes, contains('Properties'));
        NamedMapType properties = db.dartClassTypes['Properties'];
        expect(properties.className, equals('Properties'));
        expect(properties.fromType, equals(db.stringType));
        expect(properties.toType, equals(db.integerType));
      });
    });
  });
}
