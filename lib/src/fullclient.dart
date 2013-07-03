part of discovery_api_client_generator;

void createFullClient(Map apis, String outputDirectory) {

  const fullLibraryName = "api_client";

  final pubspec = """
name: $fullLibraryName
version: $clientVersion.0
authors:
- Gerwin Sturm <scarygami@gmail.com>
- Adam Singer <financeCoding@gmail.com>
description: Auto-generated client library for accessing Google APIs
homepage: https://github.com/dart-gde/discovery_api_dart_client_generator
environment:
  sdk: '${dartEnvironmentVersionConstraint}'
dependencies:
  google_oauth2_client: '${googleOAuth2ClientVersionConstraint}'
  js: '${jsDependenciesVersionConstraint}'
""";

  void writeFullReadme(StringSink sink) {
    sink.write("""
# $fullLibraryName

### Description

Auto-generated client library for accessing the Google APIs.

Examples for how to use these libraries can be found here: https://github.com/dart-gde/dart_api_client_examples

### Supported APIs

""");

    apis["items"].forEach((item) {
      var name = item["name"];
      var version = item["version"];
      var title = item["title"];
      var link = item["documentationLink"];
      var description = item["description"];

      var libraryBrowserName = cleanName("${name}_${version}_api_browser");
      var libraryConsoleName = cleanName("${name}_${version}_api_console");

      sink.write("#### ");
      if (item.containsKey("icons") && item["icons"].containsKey("x16")) {
        sink.write("![Logo](${item["icons"]["x16"]}) ");
      }
      sink.write("$title - $name $version\n\n");
      sink.write("$description\n\n");
      if (link != null) {
        sink.write("[Official API Documentation]($link)\n\n");
      }
      sink.write("For web applications:\n```\nimport \"package:$fullLibraryName/$libraryBrowserName.dart\" as ${cleanName(name).toLowerCase()}client;\n```\n\n");
      sink.write("For console application:\n```\nimport \"package:$fullLibraryName/$libraryConsoleName.dart\" as ${cleanName(name).toLowerCase()}client;\n```\n\n");

      sink.write("```\nvar ${cleanName(name).toLowerCase()} = new ${cleanName(name).toLowerCase()}client.${capitalize(name)}();\n```\n");

      sink.write("\n");
    });

    sink.write("### Licenses\n\n```\n");
    sink.write(_license);
    sink.write("```\n");
  };

  (new Directory("$outputDirectory/lib/src")).createSync(recursive: true);


  _writeString("$outputDirectory/pubspec.yaml", pubspec);
  _writeFile("$outputDirectory/README.md", writeFullReadme);

  _writeString("$outputDirectory/LICENSE", _license);
  _writeString("$outputDirectory/CONTRIBUTORS", _contributors);
  _writeString("$outputDirectory/.gitignore", _gitIgnore);

  apis["items"].forEach((item) {
    loadDocumentFromUrl(item["discoveryRestUrl"]).then((doc) {
      var generator = new Generator(doc);
      generator.generateClient(outputDirectory, fullLibrary: true);
    });
  });
}
