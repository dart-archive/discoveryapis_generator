part of discovery_api_client_generator;

class Config {
  String get clientVersion => "0.4";

  bool get isDev => false;

  String get dartEnvironmentVersionConstraint => '>=1.0.0 <2.0.0';

  Map<String, Object> get dependencyVersions => const {
    'http_base': "'>=0.0.1 <0.0.2'",
  };

  const Config();

  void writeAllDependencies(StringSink sink) {
    sink.writeln("dependencies:");
    forEachOrdered(dependencyVersions, (String lib, Object value) {
      if (value is String) {
        sink.writeln("  $lib: $value");
      } else if (value is Map) {
        sink.writeln("  $lib:\n");
        value.forEach((k, v) {
          sink.writeln("    $k: $v\n");
        });
      }
    });
  }

  String getLibraryVersion(int clientVersionBuild) {
    assert(clientVersionBuild >= 0);
    var value = "$clientVersion.${clientVersionBuild}";
    if(isDev) {
      value = "$value-dev";
    }
    return value;
  }
}
