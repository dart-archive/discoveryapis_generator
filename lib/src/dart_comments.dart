part of discovery_api_client_generator;


/**
 * Represents a comment of a dart element (e.g. class, method, ...)
 */
class Comment {
  static final Comment Empty = new Comment('');
  final String rawComment;

  Comment(String raw)
      : rawComment = (raw != null && raw.length > 0)
        ? raw.trimRight() : 'Not documented yet.';

  /**
   * Returns a block string which has [indentationLevel] spaces in front of it.
   *
   * The block will start with spaces and ends with a new line.
   */
  String asDartDoc(int indentationLevel) {
    var commentString = escapeComment(rawComment);
    var spaces = ' ' * indentationLevel;

    String multilineComment() {
      var result = new StringBuffer();

      var maxCommentLine = 80 - (indentationLevel + ' * '.length);
      var expandedLines = commentString.split('\n').expand((String s) {
        if (s.length < maxCommentLine) {
          return [s];
        }

        // Try to break the line into several lines.
        var splitted = [];
        var sb = new StringBuffer();

        for (var part in s.split(' ')) {
          if ((sb.length + part.length + 1) > maxCommentLine) {
            // If we have already data, we'll write a new line.
            if (sb.length > 0) {
              splitted.add('$sb');
              sb.clear();
            }
          }
          if (!sb.isEmpty) sb.write(' ');
          sb.write(part);
        }
        if (!sb.isEmpty) splitted.add('$sb');
        return splitted;
      });

      result.writeln('$spaces/**');
      for (var line in expandedLines) {
        line = line.trimRight();
        result.write('$spaces *');
        if (line.length > 0) {
          result.writeln(' $line');
        } else {
          result.writeln('');
        }
      }
      result.writeln('$spaces */');

      return '$result';
    }

    if (!commentString.contains('\n')) {
      var onelineComment = spaces + '/** ${escapeComment(commentString)} */\n';
      if (onelineComment.length <= 80) {
        return onelineComment;
      }
      return multilineComment();
    } else {
      return multilineComment();
    }
  }
}
