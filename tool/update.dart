import "dart:io";
import "dart:uri";
import "dart:async";
import "dart:json" as JSON;
import "package:args/args.dart";

var gituser;
var repouser;
var token;
bool force = false;

void printUsage(parser) {
  print("discovery_api_dart_client_generator update: automatically creates/updates GitHub repositories for the client libraries\n");
  print("Usage:");
  print(parser.getUsage());
}

// Authentication stuff

Future<String> promptPassword() {
  var completer = new Completer<String>();
  var stream = new StringInputStream(stdin);
  stdout.writeString("Warning: If you didn't run this via run_update.sh your password will be displayed here until Dart has tty control.\n");
  stdout.writeString("Watch your back...\n");
  stdout.writeString("GitHub password for $gituser: ");
  
  stream.onLine = () {
    var str = stream.readLine();
    stdin.close();
    // scroll password out of view just in case...
    stdout.writeString("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
    completer.complete(str);
  };
  return completer.future;
}

Future<String> gitHubLogin() {
  var completer = new Completer<String>();
  promptPassword().then((pw) {
    var client = new HttpClient();

    client.addCredentials(Uri.parse("https://api.github.com/authorizations"), "realm", new HttpClientBasicCredentials(gituser, pw));

    HttpClientConnection connection = client.openUrl("POST", Uri.parse("https://api.github.com/authorizations"));

    // On connection request set the content type and key if available.
    connection.onRequest = (HttpClientRequest request) {
      var data = JSON.stringify({"scopes":["repo"],"note":"API Client Generator"});
      request.headers.set(HttpHeaders.CONTENT_TYPE, "application/json");
      request.headers.set(HttpHeaders.CONTENT_LENGTH, "${data.length}");
      request.outputStream.writeString(data);
      request.outputStream.close();
    };

    // On connection response read in data from stream, on close parse as json and return.
    connection.onResponse = (HttpClientResponse response) {
      StringInputStream stream = new StringInputStream(response.inputStream);
      StringBuffer onResponseBody = new StringBuffer();
      stream.onData = () {
        onResponseBody.add(stream.read());
      };

      stream.onClosed = () {
        if (response.statusCode == 201) {
          completer.complete(onResponseBody.toString());
        } else {
          completer.completeError(new HttpException("Error ${response.statusCode}: $onResponseBody"));
        }
        client.shutdown();
      };

      // Handle stream error
      stream.onError = (error) {
        completer.completeError(new StreamException("$error"));
      };
    };

    // Handle post error
    connection.onError = (error) {
      completer.completeError(new HttpException("$error"));
    };
  });
  return completer.future;
}

Future<bool> checkCredentials(String token) {
  var completer = new Completer<bool>();

  var client = new HttpClient();
  var connection = client.openUrl("GET", Uri.parse("https://api.github.com/user/repos"));

  connection.onRequest = (request) {
    request.headers.set(HttpHeaders.AUTHORIZATION, "token $token");
    request.outputStream.close();
  };

  connection.onResponse = (HttpClientResponse response) {
    var stream = new StringInputStream(response.inputStream);

    stream.onData = () => stream.read();

    stream.onClosed = () {
      if (response.statusCode == 200) {
        completer.complete(true);
      } else {
        completer.complete(false);
      }
      client.shutdown();
    };

    // Handle stream error
    stream.onError = (error) {
      completer.completeError(new StreamException("$error"));
    };
  };

  // Handle post error
  connection.onError = (error) {
    completer.completeError(new HttpException("$error"));
  };

  return completer.future;
}

Future<String> getCredentials() {
  var credentialsFile = new File("tool/githubtoken");
  var completer = new Completer<String>();
  if (!credentialsFile.existsSync()) {
    gitHubLogin()
      .then((data) {
        var json = JSON.parse(data);
        var token = json["token"];
        credentialsFile.writeAsStringSync(token);
        completer.complete(token);
      })
      .catchError((e) => completer.completeError(e));
  } else {
    var token = credentialsFile.readAsStringSync();
    checkCredentials(token)
      .then((success) {
        if (success) {
          completer.complete(token);
        } else {
          print("GitHub token no longer valid, trying to re-authenticate.");
          credentialsFile.delete();
          gitHubLogin()
          .then((data) {
            var json = JSON.parse(data);
            var token = json["token"];
            credentialsFile.writeAsStringSync(token);
            completer.complete(token);
          })
          .catchError((e) => completer.completeError(e));
        }
      })
      .catchError((e) {
        credentialsFile.writeAsStringSync(token);
        completer.completeError(e);
      });
  }
  return completer.future;
}

// GitHub stuff

Future<bool> createRepository(String name, String version, String gitname) {
  var completer = new Completer<bool>();
  var client = new HttpClient();
  var url;

  if (gituser != repouser) {
    url = "https://api.github.com/orgs/$repouser/repos";
  } else {
    url = "https://api.github.com/user/repos";
  }

  var connection = client.openUrl("POST", Uri.parse(url));

  connection.onRequest = (request) {
    var data = JSON.stringify(
      {
        "name": gitname,
        "description": "Auto-generated Dart client library to access the $name $version API"
      }
    );
    request.headers.set(HttpHeaders.AUTHORIZATION, "token $token");
    request.headers.set(HttpHeaders.CONTENT_TYPE, "application/json");
    request.headers.set(HttpHeaders.CONTENT_LENGTH, "${data.length}");
    request.outputStream.writeString(data);
    request.outputStream.close();
  };

  connection.onResponse = (HttpClientResponse response) {
    var stream = new StringInputStream(response.inputStream);

    StringBuffer onResponseBody = new StringBuffer();
    stream.onData = () {
      onResponseBody.add(stream.read());
    };

    stream.onClosed = () {
      if (response.statusCode == 201) {
        completer.complete(true);
      } else {
        print (onResponseBody.toString());
        completer.complete(false);
      }
      client.shutdown();
    };

    // Handle stream error
    stream.onError = (error) {
      completer.completeError(new StreamException("$error"));
    };
  };

  // Handle post error
  connection.onError = (error) {
    completer.completeError(new HttpException("$error"));
  };

  return completer.future;
}

Future<bool> findRepository(String name, String version, String gitname) {
  var completer = new Completer<bool>();
  var client = new HttpClient();
  var connection = client.openUrl("GET", Uri.parse("https://api.github.com/repos/$repouser/$gitname"));

  connection.onRequest = (request) {
    request.headers.set(HttpHeaders.AUTHORIZATION, "token $token");
    request.outputStream.close();
  };

  connection.onResponse = (HttpClientResponse response) {
    var stream = new StringInputStream(response.inputStream);

    stream.onData = () => stream.read();

    stream.onClosed = () {
      if (response.statusCode == 200) {
        completer.complete(true);
      } else {
        if (response.statusCode == 404) {
          createRepository(name, version, gitname).then((success) => completer.complete(success));
        } else {
          completer.complete(false);
        }
      }
      client.shutdown();
    };

    // Handle stream error
    stream.onError = (error) {
      completer.completeError(new StreamException("$error"));
    };
  };

  // Handle post error
  connection.onError = (error) {
    completer.completeError(new HttpException("$error"));
  };

  return completer.future;
}

// API generation and push

Future handleAPI(String name, String version, String gitname) {
  var completer = new Completer();
  findRepository(name, version, gitname).then((success) {
    if (success) {
      print("Repository $gitname found.");
      Process.run("git", ["clone", "https://github.com/$repouser/$gitname.git", "output/$gitname"]).then((p) {
        print(p.stdout);

        var params = "-a $name -v $version --check";
        if (force) params = "$params --force";
        Process.run("dart bin/generator.dart $params", []).then((p) {
          var result = p.stdout;
          print(result);
          if (result.indexOf("generated successfully") >= 0) {
            print("TODO: Commiting changes and pushing to GitHub");
          }
          completer.complete(true);
        });

      });
    } else {
      print("Repository not found and not able to create. Skipping $gitname");
      completer.complete(true);
    }
  });
  return completer.future;
}

// Force synchronous handling of APIs to prevent API Rate limits and processor overload
void handleAPIs(List apis) {
  if (apis.length > 0) {
    var api = apis.removeAt(0);
    print(api["gitname"]);
    handleAPI(api["name"], api["version"], api["gitname"]).then((v) => handleAPIs(apis));
  }
}

void main() {
  final options = new Options();
  var parser = new ArgParser();
  parser.addOption("gituser", abbr: "g", help: "User to connect to GitHub with", defaultsTo: "Scarygami");
  parser.addOption("repouser", abbr: "r", help: "Owner of the repositories (can be User or Organization)", defaultsTo: "Scarygami");
  parser.addOption("limit", abbr: "l", help: "Limit the number of repositories being generated (for testing)");
  parser.addFlag("force", help: "Force client version update even if no changes", negatable: false);
  parser.addFlag("help", abbr: "h", help: "Display this information and exit", negatable: false);

  var result;
  try {
    result = parser.parse(options.arguments);
  } on FormatException catch(e) {
    print("Error parsing arguments:\n${e.message}\n");
    printUsage(parser);
    return;
  }

  if (result["help"] != null && result["help"] == true) {
    printUsage(parser);
    return;
  }

  if (result["force"] != null && result["force"] == true) {
    force = true;
  }

  gituser = result["gituser"];
  repouser = result["repouser"];
  token = "";

  getCredentials()
    .then((tok) {
      token = tok;
      var tmpDir = new Directory("output/");
      if (tmpDir.existsSync()) {
        print("Emptying folder before library generation...");
        tmpDir.listSync().forEach((f) {
          if (f is File) {
            f.deleteSync();
          } else if (f is Directory) {
            f.deleteSync(recursive: true);
          }
        });
      }
      Process.run("dart", ["bin/generator.dart", "--list"]).then((p) {
        var file = new File("output/APIS");
        if (file.existsSync()) {
          var data = file.readAsStringSync();
          var json = JSON.parse(data);
          var count = 0;
          var limit = json["apis"].length;
          var apis = new List();
          if (result["limit"] != null) limit = int.parse(result["limit"]);
          json["apis"].forEach((item) {
            count++;
            if (count <= limit) {
              apis.add(item);
            }
          });
          handleAPIs(apis);
        } else {
          print("No API List found.");
          exit(1);
        }
      });
    })
    .catchError((e) => print("$e"));
}