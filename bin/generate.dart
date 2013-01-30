import "dart:json" as JSON;
import "package:args/args.dart";
import "package:discovery_api_client_generator/generator.dart";

void printUsage(parser) {
  print("discovery_api_client_generator: creates a Client library based on a discovery document\n");
  print("Usage:");
  print("   generate.dart -a <API> - v <Version> [-o <Directory>] (to load from Google Discovery API)");
  print("or generate.dart -u <URL> [-o <Directory>] (to load discovery document from specified URL)");
  print("or generate.dart -i <File> [-o <Directory>] (to load discovery document from local file)");
  print("or generate.dart --all [-o <Directory>] (to create libraries for all Google APIs)");
  print("or generate.dart --full [-o <Directory>] (to create one library including all Google APIs)\n");
  print("or generate.dart --list [-o <Directory>] (to create a list of available APIs for scripting)\n");
  print(parser.getUsage());
}

void main() {
  final options = new Options();
  var parser = new ArgParser();
  parser.addOption("api", abbr: "a", help: "Short name of the Google API (plus, drive, ...)");
  parser.addOption("version", abbr: "v", help: "Google API version (v1, v2, v1alpha, ...)");
  parser.addOption("input", abbr: "i", help: "Local Discovery document file");
  parser.addOption("url", abbr: "u", help: "URL of a Discovery document");
  parser.addFlag("all", help: "Create client libraries for all Google APIs", negatable: false);
  parser.addFlag("full", help: "Create one library including all Google APIs", negatable: false);
  parser.addFlag("list", help: "Create a list of available APIs for scripting", negatable: false);
  parser.addOption("output", abbr: "o", help: "Output Directory", defaultsTo: "output/");
  parser.addFlag("date", help: "Create sub folder with current date", negatable: false);
  parser.addFlag("check", help: "Check for changes against existing version if available", negatable: false);
  parser.addFlag("force", help: "Force client version update even if no changes", negatable: false);
  parser.addFlag("help", abbr: "h", help: "Display this information and exit", negatable: false);
  var result;
  try {
    result = parser.parse(options.arguments);
  } on FormatException catch(e) {
    print("Error parsing arguments:\n${e.message}\n");
    printUsage(parser);
    return;
  }

  if (result["help"] != null && result["help"] == true) {
    printUsage(parser);
    return;
  }

  if ((result["api"] == null || result["version"] == null)
      && result["input"] == null && result["url"] == null
      && (result["all"] == null || result["all"] == false)
      && (result["full"] == null || result["full"] == false)
      && (result["list"] == null || result["list"] == false)) {
    print("Missing arguments\n");
    printUsage(parser);
    return;
  }

  var argumentErrors = false;
  argumentErrors = argumentErrors ||
      (result["api"] != null &&
        (result["input"] != null ||
         result["url"] != null ||
         (result["all"] != null && result["all"] == true) ||
         (result["full"] != null && result["full"] == true) ||
         (result["list"] != null && result["full"] == true))
      );
  argumentErrors = argumentErrors||
      (result["input"] != null &&
        (result["url"] != null ||
         (result["all"] != null && result["all"] == true) ||
         (result["full"] != null && result["full"] == true) ||
         (result["list"] != null && result["full"] == true))
      );
  argumentErrors = argumentErrors ||
      (result["url"] != null &&
        ((result["all"] != null && result["all"] == true) ||
         (result["full"] != null && result["full"] == true) ||
         (result["list"] != null && result["full"] == true))
      );
  argumentErrors = argumentErrors ||
      (result["all"] != null && result["all"] == true &&
        ((result["full"] != null && result["full"] == true) ||
         (result["list"] != null && result["full"] == true))
      );
  argumentErrors = argumentErrors ||
      (result["full"] != null && result["full"] == true &&
        ((result["list"] != null && result["full"] == true))
      );
  if (argumentErrors) {
    print("You can only define one kind of operation.\n");
    printUsage(parser);
    return;
  }

  var output = result["output"];
  if (result["date"] != null && result["date"] == true) {
    output = "$output/${fileDate(new Date.now())}";
  }

  var check = false;
  if (result["check"] != null && result["check"] == true) {
    check = true;
  }

  var force = false;
  if (result["force"] != null && result["force"] == true) {
    force = true;
  }

  if ((result["all"] == null || result["all"] == false) &&
      (result["full"] == null || result["full"] == false) &&
      (result["list"] == null || result["list"] == false)) {
    var loader;
    if (result["api"] !=null)
      loader = loadDocumentFromGoogle(result["api"], result["version"]);
    else if (result["url"] != null)
      loader = loadDocumentFromUrl(result["url"]);
    else if (result["input"] != null)
      loader = loadDocumentFromFile(result["input"]);

    loader.then((doc) {
      var generator = new Generator(doc);
      generator.generateClient(output, check: check, force: force);
    });
  } else {
    loadDocumentFromUrl("https://www.googleapis.com/discovery/v1/apis").then((data) {
      var apis = JSON.parse(data);
      if (result["full"] != null && result["full"] == true) {
        createFullClient(apis, output);
      }
      if (result["list"] != null && result["list"] == true) {
        createAPIList(apis, output);
      }
      if (result["all"] != null && result["all"] == true) {
        apis["items"].forEach((item) {
          loadDocumentFromUrl(item["discoveryRestUrl"]).then((doc) {
            var generator = new Generator(doc);
            generator.generateClient(output, check: check, force: force);
          });
        });
      }
    });
  }
}