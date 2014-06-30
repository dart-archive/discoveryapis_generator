import 'package:discovery_api_client_generator/generator.dart';
import 'package:unittest/unittest.dart';

main() {
  group('comments', () {
    test('empty-comment', () {
      expectUndocumented(Comment comment) {
        expect(comment.asDartDoc(0), equals('/** Not documented yet. */\n'));
        expect(comment.asDartDoc(2), equals('  /** Not documented yet. */\n'));
      }

      expectUndocumented(new Comment(null));
      expectUndocumented(new Comment(''));
      expectUndocumented(Comment.Empty);
    });

    test('one-line-comment', () {
      expectABC(Comment comment) {
        expect(comment.asDartDoc(0), equals('/** ABC */\n'));
        expect(comment.asDartDoc(2), equals('  /** ABC */\n'));
      }
      expectABC(new Comment('ABC'));
      expectABC(new Comment('ABC  '));
      expectABC(new Comment('ABC \n '));
    });

    test('multi-line-comment', () {
      expectABCdef(Comment comment) {
        expect(comment.asDartDoc(0), equals(
'''/**
 * ABC
 * def
 */
'''));

      }
      expectABCdef(new Comment('ABC\ndef'));
      expectABCdef(new Comment('ABC\ndef  '));
      expectABCdef(new Comment('ABC \ndef \n  \n  '));
    });
  });
}
