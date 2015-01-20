#!/usr/bin/env dart
// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import "dart:io";

import "package:args/args.dart";
import "package:discovery_api_client_generator/generator.dart";

ArgParser downloadCommandArgParser() {
  return new ArgParser()
      ..addOption('output-dir',
                  abbr: 'o',
                  help: 'Output directory of discovery documents.',
                  defaultsTo: 'googleapis-discovery-documents');
}

ArgParser generateCommandArgParser() {
  return new ArgParser()
      ..addOption('input-dir',
                  abbr: 'i',
                  help: 'Input directory of discovery documents.',
                  defaultsTo: 'googleapis-discovery-documents')
      ..addOption('output-dir',
                  abbr: 'o',
                  help: 'Output directory of the generated API package.',
                  defaultsTo: 'googleapis')
      ..addOption('package-name',
                  help: 'Name of the generated API package.',
                  defaultsTo: 'googleapis')
      ..addOption('package-version',
                  help: 'Version of the generated API package.',
                  defaultsTo: '0.1.0-dev')
      ..addOption('package-description',
                  help: 'Description of the generated API package.',
                  defaultsTo: 'Auto-generated client libraries.')
      ..addOption('package-author',
                  help: 'Author of the generated API package.')
      ..addOption('package-homepage',
                  help: 'Homepage of the generated API package.');
}

ArgParser runConfigCommandArgParser() {
  return new ArgParser()
      ..addOption('config-file',
                  help: 'Configuration file describing package generation.',
                  defaultsTo: 'config.yaml');
}

ArgParser globalArgParser() {
  return new ArgParser()
      ..addCommand('download', downloadCommandArgParser())
      ..addCommand('generate', generateCommandArgParser())
      ..addCommand('run_config', runConfigCommandArgParser())
      ..addFlag('help', abbr: 'h', help: 'Displays usage information.');
}

ArgResults parseArguments(ArgParser parser, List<String> arguments) {
  try {
    return parser.parse(arguments);
  } on FormatException catch(e) {
    dieWithUsage("Error parsing arguments:\n${e.message}\n");
  }
}

void dieWithUsage([String message]) {
  if (message != null) {
    print(message);
  }
  print("Usage:");
  print("The discovery generator has the following sub-commands:");
  print("");
  print("  download");
  print("  generate");
  print("  run_config");
  print("");
  print("The 'download' subcommand downloads all discovery documents. "
        "It takes the following options:");
  print("");
  print(downloadCommandArgParser().usage);
  print("");
  print("The 'generate' subcommand generated an API package from already"
        "downloaded discovery documents. It takes the following options:");
  print("");
  print(generateCommandArgParser().usage);
  print("");
  print("The 'run_config' subcommand downloads discovery documents and "
        "generates one or more API packages based on a configuration file. "
        "It takes the following options:");
  print("");
  print(runConfigCommandArgParser().usage);
  exit(1);
}

void main(List<String> arguments) {
  var parser = globalArgParser();
  var options = parseArguments(parser, arguments);
  var commandOptions = options.command;
  var subCommands = ['download', 'generate', 'run_config'];

  if (options['help']) {
    dieWithUsage();
  } else if (commandOptions == null ||
             !subCommands.contains(commandOptions.name)) {
    dieWithUsage('Invalid command');
  }

  switch (commandOptions.name) {
    case 'download':
      downloadDiscoveryDocuments(commandOptions['output-dir']);
      break;
    case 'generate':
      var pubspec = new Pubspec(commandOptions['package-name'],
                                commandOptions['package-version'],
                                commandOptions['package-description'],
                                author: commandOptions['package-author'],
                                homepage: commandOptions['package-homepage']);
      printResults(generateAllLibraries(commandOptions['input-dir'],
                                        commandOptions['output-dir'],
                                        pubspec));
      break;
    case 'run_config':
      var configFile = commandOptions['config-file'];
      generateFromConfiguration(configFile).then((_) => print('Done!'));
      break;
  }
}

void printResults(List<GenerateResult> results) {
  int successfull = 0;
  for (var result in results) {
    print(result);
    if (result.success) successfull++;
  }
  print("Successfull: $successfull, Failed: ${results.length - successfull}");
}
