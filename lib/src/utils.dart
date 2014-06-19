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
String escapeString(String string) => string.replaceAll(r'$', r'\$');

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

const String _license = """
Copyright 2014, the Dart project authors. All rights reserved.
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above
      copyright notice, this list of conditions and the following
      disclaimer in the documentation and/or other materials provided
      with the distribution.
    * Neither the name of Google Inc. nor the names of its
      contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
""";

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
