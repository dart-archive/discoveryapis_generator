part of discovery_api_client_generator;

const List keywords = const [
  "assert", "break", "case", "catch", "class", "const", "continue",
  "default", "do", "else", "enum", "extends", "false", "final", "finally",
  "for", "if", "in", "is", "new", "null", "rethrow", "return", "super", "switch",
  "this", "throw", "true", "try", "var", "void", "while", "with",

  // This is not in the dart language specification 1.2 but is reserved
  // in dart2js and the dart VM.
  // See: http://dartbug.com/19515
  "external"
];

final _cleanRegEx = new RegExp(r"[^\w$]");

String fileDate(DateTime date) => "${date.year}${(date.month < 10) ? 0 : ""}${date.month}${(date.day < 10) ? 0 : ""}${date.day}_${(date.hour < 10) ? 0 : ""}${date.hour}${(date.minute < 10) ? 0 : ""}${date.minute}${(date.second < 10) ? 0 : ""}${date.second}";
String cleanName(String name) => name.replaceAll(_cleanRegEx, "_");

// TODO: Is this all we have to do?
String escapeString(String string){
  return string
      .replaceAll(r'$', r'\$')
      .replaceAll("'", "\\'")
      .replaceAll('"', '\\"');
}

/// Escapes [comment] to ensure it can safely be used inside a /* ... */ block.
String escapeComment(String comment) {
  return comment.replaceAll('/*', ' / * ').replaceAll('*/', ' * / ');
}

void orderedForEach(Map map, Function fun) {
  var keys = new List.from(map.keys);
  keys.sort();
  for (var key in keys) {
    fun(key, map[key]);
  }
}

void _writeString(String path, String content) {
  var file = new File(path);
  file.writeAsStringSync(content);
}

void _writeFile(String path, void writer(StringSink sink)) {
  var sink = new StringBuffer();
  writer(sink);
  _writeString(path, sink.toString());
}

const String _gitIgnore ="""
packages
pubspec.lock
""";

class GeneratorError implements Exception {
  final String api;
  final String version;
  final String message;

  GeneratorError(this.api, this.version, this.message);

  String toString() => 'Error while generating API for $api/$version: $message';
}
