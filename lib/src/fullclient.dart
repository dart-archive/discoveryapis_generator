part of discovery_api_client_generator;

void createFullClient(Map apis, String outputDirectory) {

  String fullLibraryName = "api_client";

  String createFullPubspec() {
    return """
name: $fullLibraryName
version: $clientVersion.0
description: Auto-generated client library for accessing Google APIs
homepage: https://github.com/dart-gde/discovery_api_dart_client_generator
authors:
- Gerwin Sturm <scarygami@gmail.com>
- Adam Singer <financeCoding@gmail.com>

dependencies:
  js: '>=0.0.14'
  google_oauth2_client: '>=0.2.1'

""";
  }

  String createFullReadme() {
    var tmp = new StringBuffer();
    tmp.add("""
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

      tmp.add("#### ");
      if (item.containsKey("icons") && item["icons"].containsKey("x16")) {
        tmp.add("![Logo](${item["icons"]["x16"]}) ");
      }
      tmp.add("$title - $name $version\n\n");
      tmp.add("$description\n\n");
      if (link != null) {
        tmp.add("[Official API Documentation]($link)\n\n");
      }
      tmp.add("For web applications:\n```\nimport \"package:api_client/$libraryBrowserName.dart\" as ${cleanName(name).toLowerCase()}client;\n```\n\n");
      tmp.add("For console application:\n```\nimport \"package:api_client/$libraryConsoleName.dart\" as ${cleanName(name).toLowerCase()}client;\n```\n\n");

      tmp.add("```\nvar ${cleanName(name).toLowerCase()} = new ${cleanName(name).toLowerCase()}client.${capitalize(name)}();\n```\n");

      tmp.add("\n");
    });

    tmp.add("### Licenses\n\n```\n");
    tmp.add(createLicense());
    tmp.add("```\n");
    return tmp.toString();
  };

  (new Directory("$outputDirectory/lib/src")).createSync(recursive: true);

  (new File("$outputDirectory/pubspec.yaml")).writeAsStringSync(createFullPubspec());
  (new File("$outputDirectory/README.md")).writeAsStringSync(createFullReadme());
  (new File("$outputDirectory/LICENSE")).writeAsStringSync(createLicense());
  (new File("$outputDirectory/CONTRIBUTORS")).writeAsStringSync(createContributors());
  (new File("$outputDirectory/.gitignore")).writeAsStringSync(createGitIgnore());

  apis["items"].forEach((item) {
    loadDocumentFromUrl(item["discoveryRestUrl"]).then((doc) {
      var generator = new Generator(doc);
      generator.generateClient(outputDirectory, fullLibrary: true);
    });
  });
}
