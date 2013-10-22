part of discovery_api_client_generator;

class Config {
  String get clientVersion => "0.4";

  bool get isDev => false;

  String get dartEnvironmentVersionConstraint => '>=0.8.1';

  Map<String, String> get authors => const {
    'Adam Singer': 'financeCoding@gmail.com',
    'Gerwin Sturm': 'scarygami@gmail.com',
    'Kevin Moore': 'kevin@thinkpixellab.com'
  };

  Map<String, String> get dependencyVersions => const {
    'google_oauth2_client': " '>=0.3.0'",
    'js': " '>=0.0.25'"
  };

  Map<String, String> get devDependencyVersions => const {
    'hop': " '>=0.25.1'"
  };

  const Config();

  void writeAllDependencies(StringSink sink) {
    sink.writeln("dependencies:");
    forEachOrdered(dependencyVersions, (String lib, String constraint) {
      sink.writeln("  $lib:$constraint");
    });

    sink.writeln("dev_dependencies:");
    forEachOrdered(devDependencyVersions, (String lib, String constraint) {
      sink.writeln("  $lib:$constraint");
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
