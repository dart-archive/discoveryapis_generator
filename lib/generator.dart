library discovery_api_client_generator;

import "dart:io";
import "dart:async";
import "dart:json" as JSON;
import 'package:meta/meta.dart';
import 'package:discovery_api_client_generator/schemas.dart';

part "src/config.dart";
part "src/generator.dart";
part "src/loaders.dart";
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
Future<bool> generateLibraryFromSource(source, String output,
    {String prefix:'', bool check: false, bool force: false}) {

  if(source is String) {
    source = JSON.parse(source);
  }

  if(source is Map) {
    source = new RestDescription.fromJson(source);
  }

  assert(source is RestDescription);

  var generator = new Generator(source, prefix);

  return new Future.value(generator.generateClient(output,
                                                   check: check, force: force));
}

Future<bool> generateLibrary(String apiName, String apiVersion, String output,
    {String prefix:'', bool check: false, bool force: false}) {
  return loadDocumentFromGoogle(apiName, apiVersion)
      .then((String doc) => generateLibraryFromSource(doc, output,
                  prefix: prefix, check: check, force: force));
}

Future<Map<String, bool>> generateAllLibraries(String output,
    {String prefix:'', bool check: false, bool force: false}) {

  var results = new Map<String, bool>();
  return loadGoogleAPIList()
      .then((DirectoryList list) {
        return Future.forEach(list.items, (DirectoryListItems item) {
          return loadDocumentFromUrl(item.discoveryRestUrl)
              .then((String doc) => generateLibraryFromSource(doc, output,
                  prefix: prefix, check: check, force: force))
              .then((bool success) {
                var resultName = '${item.name} - ${item.version}';
                results[resultName] = success;
              });
          });
      })
      .then((_) => results);
}
