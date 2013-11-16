library discovery_api_client_generator;

import "dart:io";
import "dart:async";
import "dart:convert";
import 'package:google_discovery_v1_api/discovery_v1_api_client.dart';
import 'package:google_discovery_v1_api/discovery_v1_api_console.dart';

part "src/config.dart";
part "src/generator.dart";
part "src/properties.dart";
part "src/utils.dart";
part "src/writers.dart";

/**
 * [source] must be one of:
 *
 *  * A [String] representing the unparsed JSON content of a [RestDescription]
 *  * A [Map] representing the parsed JSON content of a [RestDescription]
 *  * An instance of [RestDescription]
 */
GenerateResult generateLibraryFromSource(source, String outputDirectory,
    {String prefix:'', bool check: false, bool force: false}) {

  if(source is String) {
    source = JSON.decode(source);
  }

  if(source is Map) {
    source = new RestDescription.fromJson(source);
  }

  assert(source is RestDescription);

  var generator = new Generator(source, prefix);

  return generator.generateClient(outputDirectory, check: check, force: force);
}

Future<GenerateResult> generateLibrary(String apiName, String apiVersion, String output,
    {String prefix:'', bool check: false, bool force: false}) {
  return _discoveryClient.apis.getRest(apiName, apiVersion)
      .then((RestDescription doc) => generateLibraryFromSource(doc, output,
                  prefix: prefix, check: check, force: force));
}

Future<List<GenerateResult>> generateAllLibraries(String output,
    {String prefix:'', bool check: false, bool force: false}) {

  var results = new List<GenerateResult>();
  return _discoveryClient.apis.list()
      .then((DirectoryList list) {
        return Future.forEach(list.items, (DirectoryListItems item) {
          return _discoveryClient.apis.getRest(item.name, item.version)
              .then((RestDescription doc) => generateLibraryFromSource(doc, output,
                  prefix: prefix, check: check, force: force))
              .then(results.add);
          });
      })
      .then((_) => results);
}

class GenerateResult {
  final String apiName;
  final String apiVersion;
  final String packagePath;
  final String message;

  GenerateResult._(this.apiName, this.apiVersion, this.packagePath, [this.message = '']) {
    assert(this.apiName != null);
    assert(this.apiVersion != null);
    assert(this.packagePath != null);
    assert(this.message != null);
  }

  bool get success => message.isEmpty;

  String get shortName => cleanName("${apiName}_${apiVersion}_api").toLowerCase();

  String toString() {
    var flag = success ? '[SUCCESS]' : '[FAIL]\r$message';
    return '$apiName $apiVersion @ $packagePath $flag';
  }
}

final _discoveryClient = new Discovery();
