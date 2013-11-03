import "dart:io";
import "dart:async";
import "dart:convert";
import "package:args/args.dart";
import 'package:google_discovery_v1_api/discovery_v1_api_client.dart';
import 'package:google_discovery_v1_api/discovery_v1_api_console.dart';
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
List<String> uploaders = ["scarygami@gmail.com", "financeCoding@gmail.com",
                          "kevin@thinkpixellab.com"];
String userAgent = "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/28.0.1468.0 Safari/537.36";

// Authentication stuff

Future<String> promptPassword() {
  var completer = new Completer<String>();
  StreamSubscription stdinSubscription;

  stdout.write("Warning: If you didn't run this via run_update.sh your password will be displayed here until Dart has tty control.\n");
  stdout.write("Watch your back...\n");
  stdout.write("GitHub password for $gituser: ");

  stdinSubscription = stdin
      .transform(UTF8.decoder)
      .transform(new LineSplitter())
      .listen((String line){
        stdinSubscription.cancel();
        // scroll password out of view just in case...
        stdout.write("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
        var str = line.replaceAll("\r", "").replaceAll("\n", "");
        completer.complete(str);
      });

  return completer.future;
}

Future<String> gitHubLogin() {
  var completer = new Completer<String>();
  promptPassword().then((pw) {
    var client = new HttpClient();
    var githubAuthorizationUri = Uri.parse("https://api.github.com/authorizations");

    client.addCredentials(githubAuthorizationUri, "realm", new HttpClientBasicCredentials(gituser, pw));

    Future<HttpClientRequest> connection = client.openUrl("POST", githubAuthorizationUri);

    connection
      .then((request){
        var data = JSON.encode({"scopes": ["repo"], "note": "API Client Generator"});
        request.headers.set(HttpHeaders.USER_AGENT, userAgent);
        request.headers.set(HttpHeaders.CONTENT_TYPE, "application/json");
        request.headers.set(HttpHeaders.CONTENT_LENGTH, "${data.length}");
        request.headers.set(HttpHeaders.USER_AGENT, userAgent);

        request.write(data);
        request.done
          .then((response) {
            StringBuffer onResponseBody = new StringBuffer();
            response.transform(UTF8.decoder)
              .listen((String data) => onResponseBody.write(data),
              onError: (error) => completer.completeError(error),
              onDone: () {
                if (response.statusCode == 201) {
                  completer.complete(onResponseBody.toString());
                } else {
                  completer.completeError(new HttpException("Error ${response.statusCode}: $onResponseBody"));
                }
                client.close();
              });
          })
          .catchError((error) {
            completer.completeError(error);
          });
        request.close();
      })
      .catchError((error) {
        completer.completeError(new HttpException("$error"));
      });
  });

  return completer.future;
}


Future<bool> checkCredentials(String token) {
  var completer = new Completer<bool>();
  var client = new HttpClient();

  Future<HttpClientRequest> connection = client.openUrl("GET", Uri.parse("https://api.github.com/user/repos"));

  connection.then((request){
    request.headers.set(HttpHeaders.USER_AGENT, userAgent);
    request.headers.set(HttpHeaders.AUTHORIZATION, "token $token");

    request.done.then((response) {
      response.listen((data) {
          // No need to read data, response.statusCode is enough
        },
        onError: (error) {
          completer.completeError(error);
        },
        onDone: () {
          if (response.statusCode == 200) {
            print("GitHub authentication successful.");
            completer.complete(true);
          } else {
            print("GitHub authentication failed.");
            completer.complete(false);
          }
          client.close();
        }
      );
    }, onError:(error){
      completer.completeError(new HttpException("$error"));
    });

    request.close();

  }, onError:(error){
    completer.completeError(new HttpException("$error"));
  });

  return completer.future;
}

Future<String> getCredentials() {
  var credentialsFile = new File("tool/githubtoken");
  var completer = new Completer<String>();
  if (!credentialsFile.existsSync()) {
    print("No stored GitHub credentials found, trying to authenticate.");
    gitHubLogin()
      .then((data) {
        var json = JSON.decode(data);
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
            var json = JSON.decode(data);
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
  String url;

  if (gituser != repouser) {
    url = "https://api.github.com/orgs/$repouser/repos";
  } else {
    url = "https://api.github.com/user/repos";
  }

  Future<HttpClientRequest> connection = client.openUrl("POST", Uri.parse(url));

  connection.then((request){
    var data = JSON.encode(
        {
          "name": gitname,
          "description": "Auto-generated Dart client library to access the $name $version API"
        }
    );
    request.headers.set(HttpHeaders.USER_AGENT, userAgent);
    request.headers.set(HttpHeaders.AUTHORIZATION, "token $token");
    request.headers.set(HttpHeaders.CONTENT_TYPE, "application/json");
    request.headers.set(HttpHeaders.CONTENT_LENGTH, "${data.length}");

    request.write(data);

    request.done.then((response){

      StringBuffer onResponseBody = new StringBuffer();

      response.transform(UTF8.decoder).listen(
          (String data) => onResponseBody.write(data),
          onError: (error) => completer.completeError(error),
          onDone:() {
            if (response.statusCode == 201) {
              print("Repository $gitname created successfully.");
              completer.complete(true);
            } else {
              print (onResponseBody.toString());
              print("Unable to create repository $gitname.");
              completer.complete(false);
            }
            client.close();
          });
    }, onError: (error) {
      completer.completeError(error);
    });
    request.close();

  }, onError: (error) {
    completer.completeError(error);
  });

  return completer.future;
}

Future<bool> findRepository(String name, String version, String gitname) {
  var completer = new Completer<bool>();
  var client = new HttpClient();

  Future<HttpClientRequest> connection = client.openUrl("GET", Uri.parse("https://api.github.com/repos/$repouser/$gitname"));

  connection.then((request){

    request.headers.set(HttpHeaders.USER_AGENT, userAgent);
    request.headers.set(HttpHeaders.AUTHORIZATION, "token $token");

    request.done.then((response){

      response.listen((data){
        // No need to read data, response.statusCode is enough
      }, onError:(error){
        completer.completeError(error);
      }, onDone:(){
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
        client.close();
      });
    }, onError:(error){
      completer.completeError(new HttpException("$error"));
    });
    request.close();
  }, onError:(error){
    completer.completeError(new HttpException("$error"));
  });

  return completer.future;
}

Future<bool> publish(String gitname) {
  var completer = new Completer<bool>();
  print("Publishing library to pub");
  var workingDirectory = "$outputdir/$gitname/";
  var arguments = [];
  if (pubVerbose) {
    arguments.add("-v");
  }

  arguments.add("publish");
  arguments.add("--server=$pubserver");
  Process.start("pub", arguments, workingDirectory: workingDirectory)
  ..then((p) {
    StringBuffer stderrBuffer = new StringBuffer();
    p.stderr.transform(UTF8.decoder).listen((String data) {
      stderrBuffer.write(data);

      if (pubVerbose) {
        print(data);
      }
    });

    StringBuffer stdoutBuffer = new StringBuffer();
    bool calledReady = false;
    bool calledWarnings = false;
    p.stdout.transform(UTF8.decoder).listen((String data) {
      stdoutBuffer.write(data);

      if (pubVerbose) {
        print(data);
      }

      if (stdoutBuffer.toString().contains(r"Are you ready to upload your package")) {
        if (!calledReady) {
          calledReady = true;
          p.stdin.write('y\n');
        }
      } else if (stdoutBuffer.toString().contains(new RegExp("warning(s)?. Upload anyway"))) {
        if (!calledWarnings) {
          calledWarnings = true;
          p.stdin.write('y\n');
        }
      }

    });

    p.exitCode.then((code) {
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
    },onError: (error) {
      print("catchError = $error");
      completer.completeError(error);
    });

  });

  return completer.future;
}

Future<bool> setPubUploaders(String gitname, {int index: 0}) {
  var workingDirectory = "$outputdir/$gitname/";
  return Process.run("pub", ["uploader", "--server=$pubserver", "add", uploaders[index]], workingDirectory: workingDirectory).then((p) {
    print("---\nstderr");
    print(p.stderr);
    print("---\nstdout");
    print(p.stdout);
    print("Exit code ${p.exitCode}");
    index++;
    if (index < uploaders.length) {
      return setPubUploaders(gitname, index: index)
          .then((v) => true);
    } else {
      return true;
    }
  });
}

// API generation and push
Future handleAPI(String name, String version, String gitname, {retry: false}) {

  var apis = (new Discovery()).apis;

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
        apis.getRest(name, version).then((doc) {
          print("Checking for updates and regenerating library if necessary.");
          //XXX: Ripped form generateLibraryFromSource
          if(doc is String) {
            doc = JSON.decode(doc);
          }

          if(doc is Map) {
            doc = new RestDescription.fromJson(doc);
          }

          var generator = new Generator(doc, prefix);
          GenerateResult generatedResult = generator.generateClient(outputdir, check: true, force: force, forceVersion: forceVersion);
          print("Library generated ${generatedResult.success}");
          if (generatedResult.success || retry) {
            print("Committing changes to GitHub");
            var workingDirectory = "$outputdir/$gitname/";
            Process.run("git", ["status"], workingDirectory: workingDirectory).then((p) {
              print(p.stdout);
              Process.run("git", ["add", "--all"], workingDirectory: workingDirectory).then((p) {
                print(p.stdout);
                Process.run("git", ["commit", "-m Automated update"], workingDirectory: workingDirectory).then((p) {
                  print(p.stdout);
                  Process.run("git", ["push", "https://$token@github.com/$repouser/$gitname.git", "master"], workingDirectory: workingDirectory).then((p) {
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
        var completedSummary = completedUpload.map((api) => 'COMPLETED: ${api["name"]}, ${api["version"]}, ${api["gitname"]}\n');
        print("------------------------------------------------");
        print("Completed Summary");
        sb.writeAll(completedSummary);
        print(sb.toString());
        sb = new StringBuffer();

        if ((retryRequest || retryAuto) && failedUpload.length > 1) {
          List failedSummary = failedUpload.map((api) => 'FAILED: ${api["name"]}, ${api["version"]}, ${api["gitname"]}\n');
          sb.writeAll(failedSummary);
          print("------------------------------------------------");
          print("Failed Summary");
          print(sb.toString());
          if (retryAuto) {
            handleAPIs(failedUpload, retry: true);
          } else {
            print("Retry Failed Upload (y)?");
            StreamSubscription stdinSubscription;
            stdinSubscription = stdin
                .transform(UTF8.decoder)
                .transform(new LineSplitter())
                .listen((String line) {
                  stdinSubscription.cancel();
                  String retry = line.replaceAll("\r", "").replaceAll("\n", "");

                  if (retry[0].toLowerCase() == 'y') {
                    handleAPIs(failedUpload, retry: true);
                  }
                }, onError: (error){
                  print("Retry failed onError: ${error}");
                });
          }
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

  var apis = (new Discovery()).apis;

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
      apis.list()
        .then((DirectoryList list) {
          var count = 0;
          if (limit == null) limit = list.items.length;
          var apis = new List();

          list.items.forEach((DirectoryListItems item) {
            count++;
            if (count <= limit) {
              var api = new Map();
              api["name"] = item.name;
              api["version"] = item.version;
              api["gitname"] = cleanName("dart_${item.name}_${item.version}_api_client").toLowerCase();
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

void main(List<String> arguments) {
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

  ArgResults result;
  try {
    result = parser.parse(arguments);
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
