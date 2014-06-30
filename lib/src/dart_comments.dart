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
    var spaces = ' ' * indentationLevel;

    // TODO: Shorten long lines as well.
    if (!rawComment.contains('\n')) {
      return spaces + '/** ${escapeComment(rawComment)} */\n';
    } else {
      var sb = new StringBuffer();
      sb.writeln('$spaces/**');
      for (var line in rawComment.split('\n')) {
        sb.writeln('$spaces * ${line.trim()}');
      }
      sb.writeln('$spaces */');

      return '$sb';
    }
  }
}
