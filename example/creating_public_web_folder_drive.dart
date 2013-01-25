import "dart:io";
import "dart:async";
import "dart:json" as JSON;
import "package:google_oauth2_client/google_oauth2_console.dart";
import "package:drive_v2_api/drive_v2_api_console.dart" as drivelib;
import "package:http/http.dart" as http;

createPublicFolder(folderName, drivelib.Drive drive) {
  print("enter createPublicFolder");
  var body = {
    'title': folderName,
    'mimeType': "application/vnd.google-apps.folder"
  };

  drivelib.File file = new drivelib.File.fromJson(body);
  var request = drive.files.insert(file).then((drivelib.File newFile) {
        print("inserted: ${newFile.title} ${newFile.id}");

          var newPerms = new drivelib.Permission.fromJson({
            "value": "",
            "type": "anyone",
            "role": "reader"
          });

        drive.permissions.insert(newPerms, newFile.id).then((drivelib.Permission updatedPermission) {
          print("updatedPermission = ${updatedPermission.toJson()}");
          drive.files.get(newFile.id).then((drivelib.File fileWithLink) {
            print("public web url: ${fileWithLink.webViewLink}");
          });
        });
      });
}

void main() {
  showAll();
  String identifier = "299615367852-n0kfup30mfj5emlclfgud9g76itapvk9.apps.googleusercontent.com";
  String secret = "8ini0niNxsDN0y42ye_UNubw";
  List scopes = [drivelib.Drive.DRIVE_FILE_SCOPE, drivelib.Drive.DRIVE_SCOPE];
  print(scopes);
  final auth = new OAuth2Console(identifier: identifier, secret: secret, scopes: scopes);
  var drive = new drivelib.Drive(auth);
  drive.makeAuthRequests = true;
  createPublicFolder("public_folder", drive);
}