part of discovery_api_client_generator;

String fileDate(DateTime date) => "${date.year}${(date.month < 10) ? 0 : ""}${date.month}${(date.day < 10) ? 0 : ""}${date.day}_${(date.hour < 10) ? 0 : ""}${date.hour}${(date.minute < 10) ? 0 : ""}${date.minute}${(date.second < 10) ? 0 : ""}${date.second}";
String capitalize(String string) => "${string.substring(0,1).toUpperCase()}${string.substring(1)}";
String cleanName(String name) => name.replaceAll(new RegExp(r"(\W)"), "_");

const Map parameterType = const {
  "string": "String",
  "number": "num",
  "integer": "int",
  "boolean": "bool"
};

String createLicense() {
  return """
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

""";
}

String createContributors() {
  return """
Adam Singer (https://github.com/financeCoding)
Gerwin Sturm (https://github.com/Scarygami, http://scarygami.net/+)
""";
}

String createGitIgnore() {
  return """
packages/
pubspec.lock
""";
}
