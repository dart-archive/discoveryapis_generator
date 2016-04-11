# Changelog - discoveryapis_generator

## v0.8.0

- Remove crypto dependency from generated libraries and upgrade sdk
  dependency to dart 1.13

## v0.7.2

- Update the code generator to only generate imports for libraries that are used
  (this avoids having analysis warnings for unused imports in the generate
  code).
- Add a command-line option to not generate library prefixes for the `dart:core`
  and `dart:async` libraries (`--no-core-prefixes`).

## v0.7.1+1

- Make findPackageRoot handle 'file:' paths.

## v0.7.1

- Fix bug in windows path handling.

## v0.7.0

- Add support for generating API files inside an existing package instead of
  generating an entirely new package.
- Changed the generators command names to 'package' and 'files' respectively
  to make it clear what is being generated.
- Added support for generating a client stub API using the same message classes
  as used on the server.

## v0.6.1

- Updated README

## v0.6.0

- Change generator to use the discoveryapis_commons package for generated code
- Remove googleapis commands and split out separate googleapis library

## v0.5.0

- Merged new generator implementation from experimental branch to master

## 0.4.5 2014-05-16 (SDK 1.4.0-dev.6.7 r36210)

- Set `uploadType` as `multipart` by default
- Rev up bot_io

## 0.4.4 2014-03-22 (SDK 1.3.0-dev.5.2 r34229)

- Added Geo JSON support
- Added support for schema array object
- Added support for schema any object
- Updated generated dependencies
- Cleaned up hop runner

## v0.4.3

## v0.4.2

## v0.4.1

## v0.4.0

## v0.3.0

## v0.2.8

## v0.2.6

## v0.2.5
