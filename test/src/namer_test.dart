// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:discoveryapis_generator/src/namer.dart';
import 'package:test/test.dart';

main() {
  group('namer', () {
    test('to-valid-identifier', () {
      identifier(x, {bool removeUnderscores: true}) =>
          Scope.toValidIdentifier(x, removeUnderscores: removeUnderscores);

      expect(identifier('abc'), equals('abc'));
      expect(identifier('ABC'), equals('ABC'));
      expect(identifier('0abc'), equals('D0abc'));
      expect(identifier('_abc'), equals('P_abc'));
      expect(identifier('_a_bc_def_', removeUnderscores: false),
          equals('P_a_bc_def_'));
      expect(identifier('_a_bc_def_'), equals('P_aBcDef_'));
      expect(identifier('_a__bc___def_'), equals('P_aBcDef_'));
      expect(identifier('A-bc'), equals('A_bc'));
      expect(identifier('A.bc'), equals('A_bc'));
      expect(identifier('A\u1234bc'), equals('A_bc'));
    });

    test('capitalize-name', () {
      capitalize(x) => Scope.capitalize(x);
      expect(capitalize('a'), equals('A'));
      expect(capitalize('abc'), equals('Abc'));
      expect(capitalize('A'), equals('A'));
      expect(capitalize('ABC'), equals('ABC'));
      expect(capitalize('Abc'), equals('Abc'));
    });

    test('scope-name', () {
      scopename(x) => Scope.toValidScopeName(x);
      expect(scopename('https://www.googleapis.com/auth/youtube.readonly'),
          equals('YoutubeReadonlyScope'));
      expect(scopename('https://www.googleapis.com/auth/youtube-readonly'),
          equals('YoutubeReadonlyScope'));
      expect(scopename('https://www.googleapis.com/auth/youtube_readonly'),
          equals('YoutubeReadonlyScope'));
      expect(scopename('https://www.googleapis.com/auth/youtube/readonly'),
          equals('YoutubeReadonlyScope'));

      expect(
          scopename('https://mail.google.com'), equals('MailGoogleComScope'));
      expect(
          scopename('https://mail.google.com/'), equals('MailGoogleComScope'));
    });

    test('identifier', () {
      var identifier = new Identifier('x');

      expect(identifier.preferredName, equals('x'));
      expect(identifier.name, isNull);

      identifier.sealWithName('foo');
      expect(identifier.preferredName, equals('x'));
      expect(identifier.name, equals('foo'));

      expect(() => identifier.sealWithName('bar'), throwsStateError);
    });

    group('scope', () {
      test('new-identifier', () {
        var scope = new Scope();
        expect(scope.parentScope, isNull);
        expect(scope.childScopes, isEmpty);
        expect(scope.identifiers, isEmpty);

        var tuples = [
          ['a', 'a'],
          ['B', 'B'],
          ['abc', 'abc'],
          ['AbC', 'AbC'],
          ['A-c', 'A_c'],
        ];
        for (var tuple in tuples) {
          var name = tuple[0];
          var target = tuple[1];
          expect(scope.newIdentifier(name), equals(scope.identifiers.last));
          expect(scope.identifiers.last.preferredName, equals(target));
          expect(scope.identifiers.last.name, isNull);
        }
      });

      test('new-child-scope', () {
        var scope = new Scope();

        var child1 = scope.newChildScope();
        expect(scope.parentScope, isNull);
        expect(scope.childScopes, hasLength(1));
        expect(scope.childScopes.last, equals(child1));
        expect(scope.identifiers, isEmpty);

        // Insert 'a' into parent scope
        scope.newIdentifier('a');
        expect(scope.identifiers, hasLength(1));
        expect(scope.identifiers.last.preferredName, equals('a'));

        // Insert 'a.1' into child scope
        child1.newIdentifier('a.1');
        expect(scope.identifiers, hasLength(1));
        expect(scope.childScopes, hasLength(1));
        expect(scope.childScopes.first.identifiers, hasLength(1));
        expect(scope.childScopes.first.identifiers.first.preferredName,
            equals('a_1'));
      });
    });

    group('identifier-namer', () {
      test('flat', () {
        var a = new Identifier('a');
        var a2 = new Identifier('a');
        var a3 = new Identifier('a');
        var b = new Identifier('b');

        var namer = new IdentifierNamer();

        namer.nameIdentifier(a);
        expect(a.name, equals('a'));
        expect(() => namer.nameIdentifier(a), throwsStateError);

        namer.nameIdentifier(a2);
        expect(a2.name, equals('a_1'));

        namer.nameIdentifier(a3);
        expect(a3.name, equals('a_2'));

        namer.nameIdentifier(b);
        expect(b.name, equals('b'));
      });

      test('flat-preallocated', () {
        var a = new Identifier('a');
        var a2 = new Identifier('a');
        var b = new Identifier('b');

        var namer = new IdentifierNamer.fromNameSet(new Set.from(['a']));

        namer.nameIdentifier(a);
        expect(a.name, equals('a_1'));

        namer.nameIdentifier(a2);
        expect(a2.name, equals('a_2'));

        namer.nameIdentifier(b);
        expect(b.name, equals('b'));
      });

      test('tree-preallocated', () {
        // [rootNamer] will contain 'a' and 'b'
        var rootNamer = new IdentifierNamer.fromNameSet(new Set.from(['a']));
        rootNamer.nameIdentifier(new Identifier('b'));

        var childNamer = new IdentifierNamer(parentNamer: rootNamer);
        var a = new Identifier('a');
        var b = new Identifier('b');

        childNamer.nameIdentifier(a);
        expect(a.name, equals('a_1'));

        childNamer.nameIdentifier(b);
        expect(b.name, equals('b_1'));
      });

      test('wasCalled', () {
        Identifier id = new Identifier('foo');
        expect(id.wasCalled, false);
        id.ref();
        expect(id.wasCalled, true);
      });

      test('Identifier.noPrefix()', () {
        Identifier id = new Identifier.noPrefix();
        expect(id.ref(), '');
        // Test that toString() doesn't throw.
        expect(id.toString(), null);
      });
    });

    group('api-namer', () {
      test('library-name', () {
        var namer = new ApiLibraryNamer();
        expect(namer.libraryName('x y', '9a', '\$a'), equals('x_y.D9a.P_a'));
        expect(namer.libraryName('googleapis', 'drive', 'v1'),
            equals('googleapis.drive.v1'));
      });

      test('scope-tree', () {
        var namer = new ApiLibraryNamer();
        var rootScope = namer.importScope;
        var libScope = namer.libraryScope;
        var classScope = namer.newClassScope();

        expect(rootScope.parentScope, isNull);
        expect(libScope.parentScope, equals(rootScope));
        expect(classScope.parentScope, equals(libScope));
      });

      test('schema-class', () {
        var namer = new ApiLibraryNamer();
        var libraryScope = namer.libraryScope;

        // Naming classes is split into two parts:
        // - getting a preffered name with [namer.schemaClassName]
        // - making an indentifier with [namer.schemaClass]
        //   => which will add it to the library scope

        var chapter = namer.schemaClassName('chapter');
        var bookChapter = namer.schemaClassName('chapter', parent: 'book');
        expect(chapter, equals('Chapter'));
        expect(bookChapter, equals('BookChapter'));

        expect(libraryScope.childScopes, isEmpty);
        expect(libraryScope.identifiers, isEmpty);

        var chapterId = namer.schemaClass(chapter);
        var bookChapterId = namer.schemaClass(bookChapter);

        expect(chapterId.preferredName, equals('Chapter'));
        expect(bookChapterId.preferredName, equals('BookChapter'));

        expect(libraryScope.childScopes, isEmpty);
        expect(libraryScope.identifiers, hasLength(2));
        expect(libraryScope.identifiers.first, equals(chapterId));
        expect(libraryScope.identifiers.last, equals(bookChapterId));
      });

      test('identifier-naming', () {
        var namer = new ApiLibraryNamer();
        namer.import('foo');
        namer.import('method'); // will collide with method name
        namer.import('BookApi'); // will collide with api class, schema class
        namer.import('FooBarResourceApi');

        namer.apiClass('Book');

        namer.schemaClass('Book');
        namer.schemaClass('chapter');
        namer.schemaClass('BookApi'); // Will collide with api class
        namer.schemaClass('BooksResourceApi');

        namer.resourceClass('Gustav');
        namer.resourceClass('FooBar');
        namer.resourceClass('Books');

        var subscope = namer.newClassScope();
        subscope.newIdentifier('method');

        namer.nameAllIdentifiers();

        var iscope = namer.importScope;
        expect(iscope.identifiers[0].name, equals('foo'));
        expect(iscope.identifiers[1].name, equals('method_1'));
        expect(iscope.identifiers[2].name, equals('BookApi_2'));
        expect(iscope.identifiers[3].name, equals('FooBarResourceApi_1'));

        var lscope = namer.libraryScope;
        expect(lscope.identifiers[0].name, equals('BookApi'));
        expect(lscope.identifiers[1].name, equals('Book'));
        expect(lscope.identifiers[2].name, equals('Chapter'));
        expect(lscope.identifiers[3].name, equals('BookApi_1'));
        expect(lscope.identifiers[4].name, equals('BooksResourceApi'));
        expect(lscope.identifiers[5].name, equals('GustavResourceApi'));
        expect(lscope.identifiers[6].name, equals('FooBarResourceApi'));
        expect(lscope.identifiers[7].name, equals('BooksResourceApi_1'));
      });
    });
  });
}
