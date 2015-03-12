# discoveryapis_generator

[![Build Status](https://drone.io/github.com/dart-gde/discovery_api_dart_client_generator/status.png)](https://drone.io/github.com/dart-gde/discovery_api_dart_client_generator/latest)

### Description

Dart application to generate Dart API Client Libraries based on discovery 
documents.

This package is used to generate client libraries for packages exposing a REST
API using the [package:rpc](https://pub.dartlang.org/packages/rpc) package.

### Usage

```
$ dart bin/generate.dart -h
Usage:
The discovery generator supports the following subcommands:

  generate

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
```