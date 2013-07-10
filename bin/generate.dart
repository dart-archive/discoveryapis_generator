#!/usr/bin/env dart

import 'dart:async';
import "dart:json" as JSON;
import "dart:io";
import "package:args/args.dart";
import 'package:discovery_api_client_generator/schemas.dart';
import "package:discovery_api_client_generator/generator.dart";

void printUsage(parser) {
  print("""
discovery_api_client_generator: creates a Client library based on a discovery document

Usage:
   generate.dart -a <API> -v <Version> [-o <Directory>] (to load from Google Discovery API)
or generate.dart -u <URL> [-o <Directory>] (to load discovery document from specified URL)
or generate.dart -i <File> [-o <Directory>] (to load discovery document from local file)
or generate.dart --all [-o <Directory>] (to create libraries for all Google APIs)
""");
  print(parser.getUsage());
}

const _argHelp = 'help';
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
const _argNoPrefix = 'no-prefix';

ArgParser _getParser() => new ArgParser()
  ..addOption(_argApi, abbr: "a", help: "Short name of the Google API (plus, drive, ...)")
  ..addOption(_argVersion, abbr: "v", help: "Google API version (v1, v2, v1alpha, ...)")
  ..addOption(_argInput, abbr: "i", help: "Local Discovery document file")
  ..addOption(_argUrl, abbr: "u", help: "URL of a Discovery document")
  ..addOption(_argPrefix, abbr: "p", help: "Prefix for library name", defaultsTo: "google")
  ..addFlag(_argNoPrefix, help: "No prefix for library name", negatable: false)
  ..addFlag(_argAll, help: "Create client libraries for all Google APIs", negatable: false)
  ..addOption(_argOutput, abbr: "o", help: "Output Directory", defaultsTo: "output/")
  ..addFlag(_argDate, help: "Create sub folder with current date", negatable: false)
  ..addFlag(_argCheck, help: "Check for changes against existing version if available", negatable: false)
  ..addFlag(_argForce, help: "Force client version update even if no changes", negatable: false)
  ..addFlag(_argHelp, abbr: "h", help: "Display this information and exit", negatable: false);

ArgResults _getParserResults(ArgParser parser) {
  final options = new Options();
  try {
    return parser.parse(options.arguments);
  } on FormatException catch(e) {
    print("Error parsing arguments:\n${e.message}\n");
    printUsage(parser);
    exit(1);
  }
}

void main() {
  var parser = _getParser();
  var result = _getParserResults(parser);

  bool help = result[_argHelp];

  if (help) {
    printUsage(parser);
    return;
  }

  bool all = result[_argAll];

  String api = result[_argApi];
  String version = result[_argVersion];
  String input = result[_argInput];
  String url = result[_argUrl];

  if ((api == null || version == null)
      && input == null && url == null
      && !all) {
    print("Missing arguments\n");
    printUsage(parser);

    exit(1);
    // unneeded, but paranoid
    return;
  }

  var argumentErrors = false;
  argumentErrors = argumentErrors ||
      (api != null &&  (input != null || url != null || all));
  argumentErrors = argumentErrors||
      (input != null && (url != null || all));
  argumentErrors = argumentErrors ||
      (url != null && all);
  if (argumentErrors) {
    print("You can only define one kind of operation.\n");
    printUsage(parser);

    exit(1);
    // unneeded, but paranoid
    return;
  }

  String output = result[_argOutput];
  // TODO: validate valid path?

  bool useDate = result[_argDate];
  assert(useDate != null);

  if (useDate) {
    output = "$output/${fileDate(new DateTime.now())}";
  }

  bool check = result[_argCheck];
  assert(check != null);

  bool force = result[_argForce];
  assert(force != null);

  String prefix = "";

  bool no_prefix = result[_argNoPrefix];
  assert(no_prefix != null);

  if (!no_prefix) {
    prefix = result[_argPrefix];
    assert(prefix != null && !prefix.isEmpty);
  }

  if (!all) {
    Future<String> loader;
    if (api != null) {
      loader = loadDocumentFromGoogle(api, version);
    } else if (url != null) {
      loader = loadCustomUrl(url);
    } else {
      assert(input != null);
      loader = loadDocumentFromFile(input);
    }

    loader.then((String doc) {
      var generator = new Generator(doc, prefix);
      generator.generateClient(output, check: check, force: force);
    });
  } else {
    loadGoogleAPIList()
      .then((DirectoryList list) {
        Future.forEach(list.items, (DirectoryListItems item) {
          return loadDocumentFromUrl(item.discoveryRestUrl)
              .then((String doc) {
                var generator = new Generator(doc, prefix);
                generator.generateClient(output, check: check, force: force);
              });
        });
      });
  }
}
