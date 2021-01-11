// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library discoveryapis_generator.utils;

import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart';

const List keywords = [
  'assert', 'break', 'case', 'catch', 'class', 'const', 'continue',
  'default', 'do', 'else', 'enum', 'extends', 'false', 'final', 'finally',
  'for', 'if', 'in', 'is', 'new', 'null', 'rethrow', 'return', 'super',
  'switch',
  'this', 'throw', 'true', 'try', 'var', 'void', 'while', 'with',

  // This is not in the dart language specification 1.2 but is reserved
  // in dart2js and the dart VM.
  // See: http://dartbug.com/19515
  'external',

  // Can't override "runtimeType" from [Object.runtimeType]
  'runtimeType',
];

final _cleanRegEx = RegExp(r'[^\w$]');

String fileDate(DateTime date) =>
    "${date.year}${(date.month < 10) ? 0 : ""}${date.month}${(date.day < 10) ? 0 : ""}${date.day}_${(date.hour < 10) ? 0 : ""}${date.hour}${(date.minute < 10) ? 0 : ""}${date.minute}${(date.second < 10) ? 0 : ""}${date.second}";
String cleanName(String name) => name.replaceAll(_cleanRegEx, '_');

final DartFormatter _formatter = DartFormatter(lineEnding: '\n', pageWidth: 80);

String _formatSource(String source) => _formatter.format(source);

// TODO: Is this all we have to do?
String escapeString(String string) {
  return string
      .replaceAll(r'$', r'\$')
      .replaceAll("'", "\\'")
      .replaceAll('"', '\\"');
}

/// Escapes [comment] to ensure it can safely be used inside a /* ... */ block.
String escapeComment(String comment) {
  return comment
      .replaceAll('/*', ' / * ')
      .replaceAll('*/', ' * / ')
      .trimRight();
}

void orderedForEach(Map map, Function fun) {
  var keys = List.from(map.keys);
  keys.sort();
  for (var key in keys) {
    fun(key, map[key]);
  }
}

void writeDartSource(String path, String content) {
  writeString(path, _formatSource(content));
}

void writeString(String path, String content) {
  var file = File(path);
  file.writeAsStringSync(content);
}

void writeFile(String path, void Function(StringSink sink) writer) {
  var sink = StringBuffer();
  writer(sink);
  writeString(path, sink.toString());
}

String findPackageRoot(String path) {
  if (path == null) {
    return null;
  }
  if (path.startsWith('file:')) {
    path = fromUri(path);
  }
  path = absolute(path);
  while (path != dirname(path)) {
    // We use the pubspec.yaml file as an indicator of being in the package
    // root directory.
    var pubspec = File(join(path, 'pubspec.yaml'));
    if (pubspec.existsSync()) return path;
    path = dirname(path);
  }
  return null;
}

const String gitIgnore = '''
packages
pubspec.lock
''';

class GenerateResult {
  final String apiName;
  final String apiVersion;
  final String message;
  final String packagePath;
  bool success = false;
  bool info = false;

  GenerateResult(this.apiName, this.apiVersion, this.packagePath)
      : success = true,
        message = null {
    assert(apiName != null);
    assert(apiVersion != null);
    assert(packagePath != null);
  }

  GenerateResult.fromMessage(String message)
      : info = true,
        apiName = null,
        apiVersion = null,
        packagePath = null,
        message = message;

  GenerateResult.error(
      this.apiName, this.apiVersion, this.packagePath, this.message)
      : success = false {
    assert(apiName != null);
    assert(apiVersion != null);
    assert(packagePath != null);
    assert(message != null);
  }

  String get shortName =>
      cleanName('${apiName}_${apiVersion}_api').toLowerCase();

  @override
  String toString() {
    if (info) {
      assert(message != null);
      return message;
    } else {
      assert(apiName != null && apiVersion != null && packagePath != null);
      var flag = success ? '[SUCCESS]' : '[FAIL]';
      var msg = message != null && message.isNotEmpty ? ':\n$message' : '';
      return '$flag $apiName $apiVersion @ $packagePath $msg';
    }
  }
}

class GeneratorError implements Exception {
  final String api;
  final String version;
  final String message;

  GeneratorError(this.api, this.version, this.message);

  @override
  String toString() => 'Error while generating API for $api/$version: $message';
}
