#!/usr/bin/env dart

import 'dart:async';
import "dart:json" as JSON;
import "dart:io";
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
  print(parser.getUsage());
}

const _argHelp = 'help';
const _argFull = 'full';
const _argAll = 'all';
const _argForce = 'force';
const _argCheck = 'check';
const _argApi = 'api';
const _argVersion = 'versoin';
const _argUrl = 'url';
const _argInput = 'input';
const _argPrefix = 'prefix';
const _argOutput = 'output';
const _argDate = 'date';

void main() {
  final options = new Options();
  var parser = new ArgParser();
  parser.addOption(_argApi, abbr: "a", help: "Short name of the Google API (plus, drive, ...)");
  parser.addOption(_argVersion, abbr: "v", help: "Google API version (v1, v2, v1alpha, ...)");
  parser.addOption(_argInput, abbr: "i", help: "Local Discovery document file");
  parser.addOption(_argUrl, abbr: "u", help: "URL of a Discovery document");
  parser.addOption(_argPrefix, abbr: "p", help: "Prefix for library name", defaultsTo: "google");
  parser.addFlag(_argAll, help: "Create client libraries for all Google APIs", negatable: false);
  parser.addFlag(_argFull, help: "Create one library including all Google APIs", negatable: false);
  parser.addOption(_argOutput, abbr: "o", help: "Output Directory", defaultsTo: "output/");
  parser.addFlag(_argDate, help: "Create sub folder with current date", negatable: false);
  parser.addFlag(_argCheck, help: "Check for changes against existing version if available", negatable: false);
  parser.addFlag(_argForce, help: "Force client version update even if no changes", negatable: false);
  parser.addFlag(_argHelp, abbr: "h", help: "Display this information and exit", negatable: false);
  var result;
  try {
    result = parser.parse(options.arguments);
  } on FormatException catch(e) {
    print("Error parsing arguments:\n${e.message}\n");
    printUsage(parser);
    return;
  }

  bool help = result[_argHelp];

  if (help) {
    printUsage(parser);
    return;
  }

  bool full = result[_argFull];
  bool all = result[_argAll];

  String api = result[_argApi];
  String version = result[_argVersion];
  String input = result[_argInput];
  String url = result[_argUrl];

  if ((api == null || version == null)
      && input == null && url == null
      && !all && !full) {
    print("Missing arguments\n");
    printUsage(parser);
    return;
  }

  var argumentErrors = false;
  argumentErrors = argumentErrors ||
      (api != null &&  (input != null || url != null || all || full));
  argumentErrors = argumentErrors||
      (input != null && (url != null || all || full));
  argumentErrors = argumentErrors ||
      (url != null && (all || full));
  argumentErrors = argumentErrors ||
      (all && full);
  if (argumentErrors) {
    print("You can only define one kind of operation.\n");
    printUsage(parser);
    return;
  }

  var output = result[_argOutput];
  bool useDate = result[_argDate];
  assert(useDate != null);

  if (useDate) {
    output = "$output/${fileDate(new DateTime.now())}";
  }

  bool check = result[_argCheck];
  assert(check != null);

  bool force = result[_argForce];
  assert(force != null);

  String prefix = result[_argPrefix];
  assert(prefix != null && !prefix.isEmpty);

  if (!all && !full) {
    Future<String> loader;
    if (api != null) {
      loader = loadDocumentFromGoogle(api, version);
    } else if (url != null) {
      loader = loadCustomUrl(url);
    } else {
      assert(input != null);
      loader = loadDocumentFromFile(input);
    }

    loader.then((doc) {
      var generator = new Generator(doc, prefix);
      generator.generateClient(output, check: check, force: force);
    });
  } else {
    loadGoogleAPIList().then((apis) {
      if (full) {
        createFullClient(apis, output);
      }
      if (all) {
        apis["items"].forEach((item) {
          loadDocumentFromUrl(item["discoveryRestUrl"]).then((doc) {
            var generator = new Generator(doc, prefix);
            generator.generateClient(output, check: check, force: force);
          });
        });
      }
    });
  }
}