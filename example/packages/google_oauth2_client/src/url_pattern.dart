part of google_oauth2_client;

/** Produces part of a URL, when the template parameters are provided. */
typedef String _UrlPatternToken(Map<String, Object> params);
/** URL template with placeholders that can be filled in to produce a URL. */
class UrlPattern {
  List<_UrlPatternToken> _tokens;
  /**
   * Creates a UrlPattern from the specification [:pattern:].
   * See http://tools.ietf.org/html/draft-gregorio-uritemplate-07
   * We only implement a very simple subset for now.
   */
  UrlPattern(String pattern) : _tokens = [] {
    var cursor = 0;
    while (cursor < pattern.length) {
      final open = pattern.indexOf("{", cursor);
      if (open < 0) {
        final rest = pattern.substring(cursor);
        _tokens.add((params) => rest);
        cursor = pattern.length;
      } else {
        if (open > cursor) {
          final intermediate = pattern.substring(cursor, open);
          _tokens.add((params) => intermediate);
        }
        final close = pattern.indexOf("}", open);
        if (close < 0) throw new ArgumentError("Token meets end of text: $pattern");
        String variable = pattern.substring(open + 1, close);
        _tokens.add((params) => (params[variable] == null)
            ? 'null'
            : encodeUriComponent(params[variable].toString()));
        cursor = close + 1;
      }
    }
  }
  /** Generate a URL with the specified list of URL and query parameters. */
  String generate(Map<String, Object> urlParams, Map<String, Object> queryParams) {
    final buffer = new StringBuffer();
    _tokens.forEach((token) => buffer.add(token(urlParams)));
    var first = true;
    queryParams.forEach((key, value) {
      if (value == null) return;
      buffer.add(first ? '?' : '&');
      if (first) first = false;
      buffer.add(encodeUriComponent(key.toString()));
      buffer.add('=');
      buffer.add(encodeUriComponent(value.toString()));
    });
    return buffer.toString();
  }
}