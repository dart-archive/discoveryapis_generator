part of discovery_api_client_generator;

class Config {
  String get clientVersion => "0.2";

  bool get isDev => true;

  String get dartEnvironmentVersionConstraint => '>=0.6.5';

  Map<String, String> get authors => const {
    'Adam Singer': 'financeCoding@gmail.com',
    'Gerwin Sturm': 'scarygami@gmail.com',
    'Kevin Moore': 'kevin@thinkpixellab.com'
  };

  Map<String, String> get dependencyVersions => const {
    'google_oauth2_client': """

    git:
      ref: dc2cf8209a3a7e09ad56f4e21505af5c71c97ade
      url: https://github.com/dart-gde/dart-google-oauth2-library.git""",
    'js': " '>=0.0.23'"
  };

  Map<String, String> get devDependencyVersions => const {
    'hop': " '>=0.23.0'"
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
