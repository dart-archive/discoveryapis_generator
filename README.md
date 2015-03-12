# discoveryapis_generator

[![Build Status](https://drone.io/github.com/dart-gde/discovery_api_dart_client_generator/status.png)](https://drone.io/github.com/dart-gde/discovery_api_dart_client_generator/latest)

### Description

Dart application to generate Dart API Client Libraries based on discovery documents.

Besides generating client libraries for the Google APIs (See [package:googleapis](https://pub.dartlang.org/packages/googleapis) and [package:googleapis_beta](https://pub.dartlang.org/packages/googleapis_beta)) this package is used to generate client libraries for
packages exposing a REST API using the [package:rpc](https://pub.dartlang.org/packages/rpc)
package.

Examples for how to use the generated client libraries can be found here:
https://github.com/dart-lang/googleapis_examples

### Usage

```
$ dart bin/generate.dart -h
Usage:
The discovery generator supports the following subcommands:

  download
  generate
  run_config

The 'download' subcommand downloads all discovery documents. It takes the following options:

-o, --output-dir    Output directory of discovery documents.
                    (defaults to "googleapis-discovery-documents")

The 'generate' subcommand generates an API package from already downloaded discovery documents. It takes the following options:

-i, --input-dir              Input directory of discovery documents.
                             (defaults to "googleapis-discovery-documents")

-o, --output-dir             Output directory of the generated API package.
                             (defaults to "googleapis")

    --package-name           Name of the generated API package.
                             (defaults to "googleapis")

    --package-version        Version of the generated API package.
                             (defaults to "0.1.0-dev")

    --package-description    Description of the generated API package.
                             (defaults to "Auto-generated client libraries.")

    --package-author         Author of the generated API package.
    --package-homepage       Homepage of the generated API package.

The 'run_config' subcommand downloads discovery documents and generates one or more API packages based on a configuration file. It takes the following options:

--config-file    Configuration file describing package generation.
                 (defaults to "config.yaml")
```

## Clone dart-lang/discoveryapis_generator

```
$ git clone https://github.com/dart-lang/discoveryapis_generator
$ cd discoveryapis_generator
$ pub get
```
