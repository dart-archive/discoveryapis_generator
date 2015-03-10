library discovery_api_client_generator;

import "dart:io";
import "dart:async";
import "dart:convert";
import 'package:http/http.dart' as http;
import 'package:yaml/yaml.dart';

import 'src/generated_googleapis/discovery/v1.dart';

part "src/apis_package_generator.dart";
part "src/dart_api_library.dart";
part "src/dart_api_test_library.dart";
part "src/dart_comments.dart";
part "src/dart_resources.dart";
part "src/dart_schemas.dart";
part "src/namer.dart";
part "src/package_configuration.dart";
part "src/utils.dart";
part "src/uri_template.dart";

/**
 * Specifaction of the pubspec.yaml for a generated package.
 */
class Pubspec {
  final String name;
  final String version;
  final String description;
  final String author;
  final String homepage;

  Pubspec(this.name,
          this.version,
          this.description,
          {this.author,
           this.homepage});

  String get sdkConstraint => '>=1.0.0 <2.0.0';

  Map<String, Object> get dependencies => const {
    'http': '\'>=0.11.1 <0.12.0\'',
    'crypto': '\'>=0.9.0 <0.10.0\'',
    '_discoveryapis_commons': '\'>=0.1.0 <0.2.0\'',
  };

  Map<String, Object> get devDependencies => const {
    'unittest': '\'>=0.10.0 <0.12.0\'',
  };
}

Future<List<DirectoryListItems>> listAllApis() {
  var client = new http.Client();
  return _discoveryClient(client).apis.list().then((DirectoryList list) {
    return list.items;
  }).whenComplete(() => client.close());
}

List<GenerateResult> generateApiPackage(List<RestDescription> descriptions,
                                        String outputDirectory,
                                        Pubspec pubspec) {
  var apisPackageGenerator = new ApisPackageGenerator(
      descriptions, pubspec, outputDirectory);

  return apisPackageGenerator.generateApiPackage();
}

List<GenerateResult> generateAllLibraries(String inputDirectory,
                                          String outputDirectory,
                                          Pubspec pubspec) {
  var apiDescriptions = new Directory(inputDirectory).listSync()
      .where((fse) => fse is File && fse.path.endsWith('.json'))
      .map((File file) {
    return new RestDescription.fromJson(JSON.decode(file.readAsStringSync()));
  }).toList();
  return generateApiPackage(apiDescriptions, outputDirectory, pubspec);
}

Future<List<GenerateResult>> downloadDiscoveryDocuments(
    String outputDir, {List<String> ids}) {
  var apiDescriptions = <RestDescription>[];

  var client = new http.Client();
  var discovery = _discoveryClient(client);
  return discovery.apis.list().then((DirectoryList list) {
    var futures = <Future>[];
    for (var item in list.items) {
      if (ids == null || ids.contains(item.id)) {
        futures.add(discovery.apis.getRest(item.name, item.version).then((doc) {
          apiDescriptions.add(doc);
        }));
      }
    }
    return Future.wait(futures).whenComplete(() => client.close());
  }).then((_) {
    var directory = new Directory(outputDir);
    if (directory.existsSync()) {
      print('Deleting directory $outputDir.');
      directory.deleteSync(recursive: true);
    }
    directory.createSync(recursive: true);

    for (var description in apiDescriptions) {
      var name = '$outputDir/${description.name}__${description.version}.json';
      var file = new File(name);
      var encoder = new JsonEncoder.withIndent('    ');
      file.writeAsStringSync(encoder.convert(description.toJson()));
      print('Written: $name');
    }
  });
}

class GenerateResult {
  final String apiName;
  final String apiVersion;
  final String message;
  final String packagePath;

  GenerateResult(this.apiName, this.apiVersion, this.packagePath)
      : message = '' {
    assert(this.apiName != null);
    assert(this.apiVersion != null);
    assert(this.packagePath != null);
  }

  GenerateResult.error(
     this.apiName, this.apiVersion, this.packagePath, this.message) {
    assert(this.apiName != null);
    assert(this.apiVersion != null);
    assert(this.packagePath != null);
    assert(this.message != null);
  }

  bool get success => message.isEmpty;

  String get shortName
      => cleanName("${apiName}_${apiVersion}_api").toLowerCase();

  String toString() {
    var flag = success ? '[SUCCESS]' : '[FAIL]';
    var msg = message != null && !message.isEmpty ? ':\n  => $message' : '';
    return '$flag $apiName $apiVersion @ $packagePath $msg';
  }
}

Future generateFromConfiguration(String configFile) {
  return listAllApis().then((List<DirectoryListItems> items) {
    var configuration = new DiscoveryPackagesConfiguration(configFile, items);

    // Print warnings for APIs not mentioned.
    if (configuration.missingApis.isNotEmpty) {
      print('WARNING: No configuration for the following APIs:');
      configuration.missingApis.forEach((id) => print('- $id'));
    }
    if (configuration.excessApis.isNotEmpty) {
      print('WARNING: The following APIs do not exist:');
      configuration.excessApis.forEach((id) => print('- $id'));
    }

    // Generate the packages.
    var configFileUri = new Uri.file(configFile);
    return configuration.generate(configFileUri.resolve('discovery').path,
                                  configFileUri.resolve('generated').path);
  });
}

DiscoveryApi _discoveryClient(http.Client client) => new DiscoveryApi(client);
