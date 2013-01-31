# discovery_api_client_generator

### Description

Dart application to create Dart API Client Libraries based on discovery documents

Examples for how to use the generated client libraries can be found here: https://github.com/dart-gde/dart_api_client_examples

### Usage

```
   generate.dart -a <API> - v <Version> [-o <Directory>] (to load from Google Discovery API)
or generate.dart -u <URL> [-o <Directory>] (to load discovery document from specified URL)
or generate.dart -i <File> [-o <Directory>] (to load discovery document from local file)
or generate.dart --all [-o <Directory>] (to create libraries for all Google APIs)
or generate.dart --full [-o <Directory>] (to create one library including all Google APIs)

-a, --api          Short name of the Google API (plus, drive, ...)
-v, --version      Google API version (v1, v2, v1alpha, ...)
-i, --input        Local Discovery document file
-u, --url          URL of a Discovery document
    --all          Create client libraries for all Google APIs
    --full         Create one library including all Google APIs
-o, --output       Output Directory
                   (defaults to "output/")

    --date         Create sub folder with current date (otherwise files might be overwritten)
    --check        Check for changes against existing version if available
    --force        Force client version update even if no changes

-h, --help         Display this information and exit
```

### Licenses

```
Copyright (c) 2013 Gerwin Sturm & Adam Singer

Licensed under the Apache License, Version 2.0 (the "License"); you may not
use this file except in compliance with the License. You may obtain a copy of
the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
License for the specific language governing permissions and limitations under
the License

------------------------
Based on http://code.google.com/p/google-api-dart-client

Copyright 2012 Google Inc.
Licensed under the Apache License, Version 2.0 (the "License"); you may not
use this file except in compliance with the License. You may obtain a copy of
the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
License for the specific language governing permissions and limitations under
the License
```