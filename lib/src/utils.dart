part of discovery_api_client_generator;

const List keywords = const [
  "assert", "break", "case", "catch", "class", "const", "continue",
  "default", "do", "else", "enum", "extends", "false", "final", "finally",
  "for", "if", "in", "is", "new", "null", "rethrow", "return", "super", "switch",
  "this", "throw", "true", "try", "var", "void", "while", "with"
];

final _cleanRegEx = new RegExp(r"[^\w$]");

String fileDate(DateTime date) => "${date.year}${(date.month < 10) ? 0 : ""}${date.month}${(date.day < 10) ? 0 : ""}${date.day}_${(date.hour < 10) ? 0 : ""}${date.hour}${(date.minute < 10) ? 0 : ""}${date.minute}${(date.second < 10) ? 0 : ""}${date.second}";
String capitalize(String string) => "${string.substring(0,1).toUpperCase()}${string.substring(1)}";
String cleanName(String name) => name.replaceAll(_cleanRegEx, "_");

String escapeProperty(String name) => keywords.contains(name) ? "${name}Property" : name;
String escapeMethod(String name) => keywords.contains(name) ? "${name}Method" : name;
String escapeParameter(String name) => keywords.contains(name) ? "${name}Parameter" : name;

void forEachOrdered(Map<String, dynamic> source, void func(String k, dynamic v)) {
  var orderdKeys = source.keys.toList()
      ..sort();

  for(var k in orderdKeys) {
    func(k, source[k]);
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
Copyright (c) 2013 Gerwin Sturm & Adam Singer

Licensed under the Apache License, Version 2.0 (the "License"); you may 
not use this file except in compliance with the License. You may obtain a 
copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
License for the specific language governing permissions and limitations 
under the License

------------------------
Based on http://code.google.com/p/google-api-dart-client

Copyright 2012 Google Inc.
Licensed under the Apache License, Version 2.0 (the "License"); you may 
not use this file except in compliance with the License. You may obtain a
copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
License for the specific language governing permissions and limitations 
under the License

""";

const String _contributors = """
Adam Singer (https://github.com/financeCoding)
Gerwin Sturm (https://github.com/Scarygami, http://scarygami.net/+)
Damon Douglas (https://github.com/damondouglas)
Kevin Moore (kevin@thinkpixellab.com)
""";

const String _gitIgnore ="""
packages
pubspec.lock
""";
