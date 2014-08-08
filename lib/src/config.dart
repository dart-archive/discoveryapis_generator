part of discovery_api_client_generator;

class Config {
  final String name;
  final String version;

  Config(this.name, this.version);

  String get sdkConstraint => '>=1.0.0 <2.0.0';

  Map<String, Object> get dependencies => const {
    // The Upper bound is due to bug http://dartbug.com/20404
    'http_base': '\'>=0.0.2-dev <0.0.3\'',
    'crypto': '\'>=0.9.0 <0.10.0\'',
  };

  Map<String, Object> get devDependencies => const {
    'unittest': '\'>=0.10.0 <0.12.0\'',
  };
}
