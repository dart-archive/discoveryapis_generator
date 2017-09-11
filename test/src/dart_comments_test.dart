// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:discoveryapis_generator/src/dart_comments.dart';
import 'package:test/test.dart';

main() {
  group('comments', () {
    test('empty-comment', () {
      expectUndocumented(Comment comment) {
        expect(comment.asDartDoc(0), equals(''));
        expect(comment.asDartDoc(2), equals(''));
      }

      expectUndocumented(new Comment(null));
      expectUndocumented(new Comment(''));
      expectUndocumented(Comment.Empty);
    });

    test('escape-comment', () {
      var comment = new Comment('/* foobar */');
      expect(comment.asDartDoc(0), equals('///  / *  foobar  * /\n'));
    });

    test('one-line-comment', () {
      expectABC(Comment comment) {
        expect(comment.asDartDoc(0), equals('/// ABC\n'));
        expect(comment.asDartDoc(2), equals('  /// ABC\n'));
      }

      expectABC(new Comment('ABC'));
      expectABC(new Comment('ABC  '));
      expectABC(new Comment('ABC \n '));
    });

    test('multi-line-comment', () {
      expectABCdef(Comment comment) {
        expect(comment.asDartDoc(0), equals('''
/// ABC
/// def
'''));
      }

      expectABCdef(new Comment('ABC\ndef'));
      expectABCdef(new Comment('ABC\ndef  '));
      expectABCdef(new Comment('ABC \ndef \n  \n  '));
    });

    test('break-lines', () {
      var chars = ('A ' * ((80 - 7) ~/ 2)).trimRight();
      var charsShortened = chars.substring(0, chars.length - 4);
      var comment = new Comment(chars);

      // [chars] fit on one line with indentation=0.
      expect(comment.asDartDoc(0), equals('/// $chars\n'));

      // Adding an indentation of 2 characters should make it a block comment.
      expect(comment.asDartDoc(2), equals('''
  /// $chars
'''));

      comment = new Comment('$chars\n\n$chars');

      // Adding an indentation of 8 characters should make it a block comment
      // which has multiple lines.
      // Multiple independend lines should be treated equally.
      expect(comment.asDartDoc(8), equals('''
        /// $charsShortened
        /// A A
        ///
        /// $charsShortened
        /// A A
'''));
    });
  });
}
