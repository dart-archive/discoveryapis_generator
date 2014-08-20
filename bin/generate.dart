#!/usr/bin/env dart

import 'dart:async';
import "dart:io";
import "dart:convert";

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

ArgParser globalArgParser() {
  return new ArgParser()
      ..addCommand('download', downloadCommandArgParser())
      ..addCommand('generate', generateCommandArgParser())
      ..addOption('help',
                  abbr: 'h',
                  help: 'Displays usage information.');
}

ArgResults parseArguments(ArgParser parser, List<String> arguments) {
  try {
    return parser.parse(arguments);
  } on FormatException catch(e) {
    dieWithUsage(parser, "Error parsing arguments:\n${e.message}\n");
  }
}

void dieWithUsage(ArgParser parser, [String message]) {
  if (message != null) {
    print(message);
  }
  print("Usage:");
  print(parser.getUsage());
  exit(1);
}

void main(List<String> arguments) {
  var parser = globalArgParser();
  var options = parseArguments(parser, arguments);
  var commandOptions = options.command;

  if (options['help'] != null ||
      commandOptions == null ||
      !['download', 'generate'].contains(commandOptions.name)) {
    dieWithUsage(parser, 'Invalid command');
  }

  switch (commandOptions.name) {
    case 'download' :
      downloadDiscoveryDocuments(commandOptions['output-dir']);
      break;
    case 'generate' :
      var pubspec = new Pubspec(commandOptions['package-name'],
                                commandOptions['package-version'],
                                commandOptions['package-description'],
                                author: commandOptions['package-author'],
                                homepage: commandOptions['package-homepage']);
      printResults(generateAllLibraries(commandOptions['input-dir'],
                                        commandOptions['output-dir'],
                                        pubspec));
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
  /*if (successfull != results.length) {
    exit(1);
  }*/
}

Future<String> _loadDocumentFromUrl(String url) {
  var client = new HttpClient();

  return client.getUrl(Uri.parse(url))
      .then((HttpClientRequest request) => request.close())
      .then((HttpClientResponse response) => UTF8.decodeStream(response))
      .whenComplete(() {
        client.close();
      });
}

Future<String> _loadDocumentFromFile(String fileName) {
  final file = new File(fileName);
  return file.readAsString();
}
