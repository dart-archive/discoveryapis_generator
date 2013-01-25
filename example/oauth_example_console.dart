import "dart:io";
import "dart:async";
import "dart:json" as JSON;
import "package:google_oauth2_client/google_oauth2_console.dart";
import "package:drive_v2_api/drive_v2_api_console.dart" as drivelib;
import "package:http/http.dart" as http;

void main() {
  String identifier = "299615367852-n0kfup30mfj5emlclfgud9g76itapvk9.apps.googleusercontent.com";
  String secret = "8ini0niNxsDN0y42ye_UNubw";
  List scopes = [drivelib.Drive.DRIVE_FILE_SCOPE];
  final auth = new OAuth2Console(identifier: identifier, secret: secret, scopes: scopes);

  var drive = new drivelib.Drive(auth);
  drive.makeAuthRequests = true;
  drive.files.list(maxResults: 10).then((data) {
    print(data);
  }).catchError((error) {
    print("error = $error");
  });
}