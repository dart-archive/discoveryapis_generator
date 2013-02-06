import "dart:io";
import "dart:uri";
import "dart:async";
import "dart:json" as JSON;
import "package:args/args.dart";
import "package:discovery_api_client_generator/generator.dart";

String gituser;
String repouser;
String token;
String outputdir;
String prefix;
String pubserver;
bool force = false;
int forceVersion;
bool pubVerbose = false;
bool retryRequest = false;
bool retryAuto = false;
bool recreate = false;
int limit;
List failedUpload = [];
List completedUpload = [];
List<String> uploaders = ["scarygami@gmail.com", "financeCoding@gmail.com"];

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
        print("GitHub authentication successful.");
        completer.complete(true);
      } else {
        print("GitHub authentication failed.");
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
    print("No stored GitHub credentials found, trying to authenticate.");
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
    print("Stored GitHub credentials found. Checking...");
    checkCredentials(token)
      .then((success) {
        if (success) {
          print("GitHub credentials still valid.");
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
        print("Repository $gitname created successfully.");
        completer.complete(true);
      } else {
        print (onResponseBody.toString());
        print("Unable to create repository $gitname.");
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
        print("Repository $gitname found.");
        completer.complete(true);
      } else {
        if (response.statusCode == 404) {
          print("Repository $gitname not found. Attempting to create it...");
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

Future<bool> publish(String gitname) {
  var completer = new Completer<bool>();
  print("Publishing library to pub");
  var options = new ProcessOptions();
  options.workingDirectory = "$outputdir/$gitname/";
  var arguments = [];
  if (pubVerbose) {
    arguments.add("-v");
  }

  arguments.add("publish");
  arguments.add("--server=$pubserver");
  Process.start("pub", arguments, options)
  ..then((p) {
    StringBuffer stderrBuffer = new StringBuffer();
    p.stderr.onData = () {
      var s = new String.fromCharCodes(p.stderr.read());
      stderrBuffer.add(s);
      if (pubVerbose) {
        print(s);
      }
    };

    StringBuffer stdoutBuffer = new StringBuffer();
    p.stdout.onData = () {
      var s = new String.fromCharCodes(p.stdout.read());
      stdoutBuffer.add(s);
      if (pubVerbose) {
        print(s);
      }

      if (stdoutBuffer.toString().contains(r"Are you ready to upload your package")) {
        p.stdin.writeString('y\n');
      } else if (stdoutBuffer.toString().contains(r"warnings. Upload anyway")) {
        p.stdin.writeString('y\n');
      }
    };
    p.onExit = (code) {
      if (pubVerbose) {
        print("onExit: pub publish");
      }

      if (stderrBuffer.toString().contains(r"Failed to upload the package")) {
        print("Library $gitname upload failed.");
        completer.complete(false);
      } else if (stdoutBuffer.toString().contains(r"uploaded successfully.")) {
        print("Library $gitname uploaded successfully.");
        completer.complete(true);
      } else {
        print("Could not tell if package was uploaded or error happened.");
        completer.complete(false);
      }

      p.stdout.close();
    };
  })
  ..catchError((error) {
    print("catchError = $error");
    completer.completeError(error);
  });
  return completer.future;
}

Future<bool> setPubUploaders(String gitname, {int index: 0}) {
  var completer = new Completer();
  var options = new ProcessOptions();
  options.workingDirectory = "$outputdir/$gitname/";
  Process.run("pub", ["uploader", "add", uploaders[index]], options).then((p) {
    print(p.stdout);
    index++;
    if (index < uploaders.length) {
      setPubUploaders(gitname, index: index).then((v) => completer.complete(true));
    } else {
      completer.complete(true);
    }
  });
  return completer.future;
}

// API generation and push
Future handleAPI(String name, String version, String gitname, {retry: false}) {
  var completer = new Completer();
  print("");
  print("------------------------------------------------");
  print("$name $version - $gitname");
  print("Trying to find existing GitHub repository...");
  findRepository(name, version, gitname).then((success) {
    if (success) {
      print("Cloning current version of library from GitHub");
      Process.run("git", ["clone", "https://github.com/$repouser/$gitname.git", "$outputdir/$gitname"]).then((p) {
        print(p.stdout);

        print("Fetching API Description");
        loadDocumentFromGoogle(name, version).then((doc) {
          print("Checking for updates and regenerating library if necessary.");
          var generator = new Generator(doc, prefix);
          if (generator.generateClient(outputdir, check: true, force: force, forceVersion: forceVersion) || retry) {
            print("Committing changes to GitHub");
            var options = new ProcessOptions();
            options.workingDirectory = "$outputdir/$gitname/";
            Process.run("git", ["status"], options).then((p) {
              print(p.stdout);
              Process.run("git", ["add", "--all"], options).then((p) {
                print(p.stdout);
                Process.run("git", ["commit", "-m Automated update"], options).then((p) {
                  print(p.stdout);
                  Process.run("git", ["push", "https://$token@github.com/$repouser/$gitname.git", "master"], options).then((p) {
                    print(p.stdout);
                    if (pubserver != null) {
                      publish(gitname)
                        .then((completed) {
                          if (completed) {
                            setPubUploaders(gitname)
                              .then((v) => completer.complete(true))
                              .catchError((e) {
                                print("Error: setPubUploaders = $e");
                                completer.completeError(e);
                              });
                          } else {
                            completer.complete(false);
                          }
                        })
                        .catchError((e) {
                          print("Error: publish = $e");
                          completer.completeError(e);
                        });
                    } else {
                      completer.complete(true);
                    }
                  });
                });
              });
            });
          } else {
            completer.complete(true);
          }
        });

      });
    } else {
      print("Skipping $gitname");
      completer.complete(false);
    }
  });
  return completer.future;
}

// Force synchronous handling of APIs to prevent API Rate limits and processor overload
void handleAPIs(List apis, {retry: false}) {

  if (apis.length > 0) {
    var api = apis.removeAt(0);
    print(api["gitname"]);
    handleAPI(api["name"], api["version"], api["gitname"], retry: retry)
    ..then((bool completed) {
      if (completed) {
        completedUpload.add(api);
      } else {
        failedUpload.add(api);
      }

      if (apis.length == 0) {
        StringBuffer sb = new StringBuffer();
        List completedSummary = completedUpload.map((api) => 'COMPLETED: ${api["name"]}, ${api["version"]}, ${api["gitname"]}\n');
        print("------------------------------------------------");
        print("Completed Summary");
        sb.addAll(completedSummary);
        print(sb.toString());
        sb = new StringBuffer();

        if ((retryRequest || retryAuto) && failedUpload.length > 1) {
          List failedSummary = failedUpload.map((api) => 'FAILED: ${api["name"]}, ${api["version"]}, ${api["gitname"]}\n');
          sb.addAll(failedSummary);
          print("------------------------------------------------");
          print("Failed Summary");
          print(sb.toString());
          if (retryAuto) {
            handleAPIs(failedUpload, retry: true);
          } else {
            print("Retry Failed Upload (y)?");
            stdin.onData = () {
              var r = stdin.read();
              String retry = new String.fromCharCodes(r);
              if (retry[0].toLowerCase() == 'y') {
                handleAPIs(failedUpload, retry: true);
              }
              stdin.onData = null;
            };
          }
        } else {
          stdin.close();
        }
      } else {
        handleAPIs(apis, retry: retry);
      }
    })
    ..catchError((error) {
      print("Error: handleAPIs = $error");
    });
  }
}

void runUpdate() {
  print("Starting automated update of client libraries...");
  print("------------------------------------------------");
  print("");

  getCredentials()
    .then((tok) {
      token = tok;
      var tmpDir = new Directory(outputdir);
      if (tmpDir.existsSync()) {
        print("Emptying output folder before library update...");
        tmpDir.listSync().forEach((f) {
          if (f is File) {
            f.deleteSync();
          } else if (f is Directory) {
            f.deleteSync(recursive: true);
          }
        });
      }
      print("Fetching list of currently available Google APIs...");
      loadGoogleAPIList()
        .then((json) {
          var count = 0;
          if (limit == null) limit = json["items"].length;
          var apis = new List();

          json["items"].forEach((item) {
            count++;
            if (count <= limit) {
              var api = new Map();
              api["name"] = item["name"];
              api["version"] = item["version"];
              api["gitname"] = cleanName("dart_${item["name"]}_${item["version"]}_api_client").toLowerCase();
              apis.add(api);
            }
          });
          handleAPIs(apis);
        })
        .catchError((e) {
          print("Error fetching APIs - $e");
          exit(1);
        });
    })
    .catchError((e) => print("$e"));
}

void printUsage(parser) {
  print("discovery_api_client_generator update: automatically creates/updates GitHub repositories for the client libraries\n");
  print("Usage:");
  print(parser.getUsage());
}

void main() {
  final options = new Options();
  var parser = new ArgParser();
  parser.addOption("gituser", abbr: "g", help: "User to connect to GitHub with (required)");
  parser.addOption("repouser", abbr: "r", help: "Owner of the repositories (defaults to --gituser)");
  parser.addOption("output", abbr: "o", help: "Output directory where to generate the libraries", defaultsTo: "output/");
  parser.addOption("limit", abbr: "l", help: "Limit the number of repositories being generated (for testing)");
  // TODO: Set https://pub.dartlang.org as default, not setting this until tests complete
  parser.addOption("pubserver", help: "Server to use for publishing");
  parser.addOption("prefix", abbr: "p", help: "Prefix for library name", defaultsTo: "google");
  parser.addOption("version", abbr: "v", help: "Overwrite library version, only valid in combination with --force");  
  parser.addFlag("force", help: "Force client library update even if no changes", negatable: false);
  parser.addFlag("pub", help: "Publish library to pub", negatable: false);
  parser.addFlag("pub-verbose", help: "Make pub output verbose", negatable: false);
  parser.addFlag("retry-request", help: "Request user for retry on failed uploads", defaultsTo: false, negatable: false);
  parser.addFlag("retry-auto", help: "Auto retry failed uploads", defaultsTo: false, negatable: false);
  parser.addFlag("help", abbr: "h", help: "Display this information and exit", negatable: false);

  var result;
  try {
    result = parser.parse(options.arguments);
  } on FormatException catch(e) {
    print("Error parsing arguments:\n${e.message}\n");
    exit(1);
  }

  if (result["help"] != null && result["help"] == true) {
    printUsage(parser);
    exit(0);
  }

  if (result["gituser"] == null) {
    print("Please provide your GitHub Username with --gituser=YOURNAME\n");
    printUsage(parser);
    exit(1);
  }

  if (result["force"] != null && result["force"] == true) {
    force = true;
    if (result["version"] != null) {
      forceVersion = int.parse(result["version"], onError: (e) {
        print("Version has to be numeric - $e");
        printUsage(parser);
        exit(1);
      });
    }
  }

  if (result["pub"] != null && result["pub"] == true && result["pubserver"] != null) {
    pubserver = result["pubserver"];
    if (result["pub-verbose"] != null && result["pub-verbose"] == true) {
      pubVerbose = true;
    }

    if (result["retry-request"] != null && result["retry-request"] == true) {
      retryRequest = true;
    }

    if (result["retry-auto"] != null && result["retry-auto"] == true) {
      retryAuto = true;
    }
  }

  if (result["limit"] != null) limit = int.parse(result["limit"]);
  prefix = result["prefix"];

  gituser = result["gituser"];
  if (result["repouser"] == null) {
    repouser = gituser;
  } else {
    repouser = result["repouser"];
  }

  outputdir = result["output"];
  token = "";

  runUpdate();
}
