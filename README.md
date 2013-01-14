# discovery_api_dart_client_generator

### Current state:

Not working:
Mediauploads "should" be working but there are CORS problems that might need to be fixed by Google.

Working:
POST and GET requests should be working.
Some basic error handling is included in case the API doesn't respond as expected...
Methods now only accept the parameters that are actually defined in the API Discovery document.

### Description

Dart application to create Dart API Client Libraries based on discovery documents

### Usage

```
   generator.dart -a <API> - v <Version> [-o <Directory>] (to load from Google Discovery API)
or generator.dart -u <URL> [-o <Directory>] (to load discovery document from specified URL)
or generator.dart -i <File> [-o <Directory>] (to load discovery document from local file)
or generator.dart -all [-o <Directory>] (to create libraries for all Google APIs)

-a, --api          Short name of the Google API (plus, drive, ...)
-v, --version      Google API version (v1, v2, v1alpha, ...)
-i, --input        Local Discovery document file
-u, --url          URL of a Discovery document
    --all          Create client libraries for all Google APIs
-o, --output       Output Directory
                   (defaults to "output/")

    --[no-]date    Create sub folder with current date (otherwise files might be overwritten)
                   (defaults to on)

-h, --help         Display this information and exit
```

### Licenses

```
Copyright (c) 2013 Gerwin Sturm, FoldedSoft e.U. / www.foldedsoft.at

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