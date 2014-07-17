import 'package:discovery_api_client_generator/generator.dart';
import 'package:unittest/unittest.dart';

main() {
  group('url-pattern', () {
    var namer = new ApiLibraryNamer();
    var imports = new DartApiImports.fromNamer(namer);
    namer.nameAllIdentifiers();

    id(String s) => new Identifier(s)..sealWithName(s);

    test('string', () {
      var template = UriTemplate.parse(imports, 'abc');
      expect(template.parts, hasLength(1));
      expect(template.parts.first is StringPart, isTrue);
      expect(template.parts.first.templateVar, isNull);
      expect(template.parts.first.staticString, 'abc');

      expect(template.stringExpression({}), "'abc'");
    });

    test('variable', () {
      var template = UriTemplate.parse(imports, '{myvar}');
      expect(template.parts, hasLength(1));
      expect(template.parts.first is VariableExpression, isTrue);
      expect(template.parts.first.templateVar, equals('myvar'));

      expect(() => template.stringExpression({}), throwsA(isArgumentError));
      expect(template.stringExpression({'myvar' : id('abc')}),
             equals("common_internal.Escaper.ecapeVariable('\$abc')"));
    });

    test('path-variable-expr', () {
      var template = UriTemplate.parse(imports, '{/myvar*}');
      expect(template.parts, hasLength(1));
      expect(template.parts.first is PathVariableExpression, isTrue);
      expect(template.parts.first.templateVar, equals('myvar'));

      expect(() => template.stringExpression({}), throwsA(isArgumentError));
      expect(template.stringExpression({'myvar' : id('abc')}),
             equals("'/' + (abc).map((item) => "
                    "common_internal.Escaper.ecapePathComponent(item))"
                    ".join('/')"));
    });

    test('reserved-expansion-expr', () {
      var template = UriTemplate.parse(imports, '{+myvar}');
      expect(template.parts, hasLength(1));
      expect(template.parts.first is ReservedExpansionExpression, isTrue);
      expect(template.parts.first.templateVar, equals('myvar'));

      expect(() => template.stringExpression({}), throwsA(isArgumentError));
      expect(template.stringExpression({'myvar' : id('abc')}),
             equals("common_internal.Escaper.ecapeVariableReserved('\$abc')"));
    });

    test('reserved-expansion-expr', () {
      var template = UriTemplate.parse(imports, '/a/{b}/{+c}{/d*}');
      expect(template.parts, hasLength(5));

      expect(template.parts[0] is StringPart, isTrue);
      expect(template.parts[0].templateVar, isNull);

      expect(template.parts[1] is VariableExpression, isTrue);
      expect(template.parts[1].templateVar, equals('b'));

      expect(template.parts[2] is StringPart, isTrue);
      expect(template.parts[2].templateVar, isNull);

      expect(template.parts[3] is ReservedExpansionExpression, isTrue);
      expect(template.parts[3].templateVar, equals('c'));

      expect(template.parts[4] is PathVariableExpression, isTrue);
      expect(template.parts[4].templateVar, equals('d'));
    });

    test('invalid-variablename', () {
      expect(() => UriTemplate.parse(imports, '{foobar'),
             throwsA(isArgumentError));
      expect(() => UriTemplate.parse(imports, '{1foobar}'),
             throwsA(isArgumentError));
      expect(() => UriTemplate.parse(imports, '{/abc}'),
             throwsA(isArgumentError));
      expect(() => UriTemplate.parse(imports, '{+abc*}'),
             throwsA(isArgumentError));
    });
  });
}
