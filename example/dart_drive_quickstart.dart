import "dart:html";
import "package:drive_v2_api_client/drive_v2_api_client.dart" as drivelib;
import "package:google_oauth2_client/google_oauth2_client.dart";

final CLIENT_ID = "796343192238.apps.googleusercontent.com";
final SCOPES = [drivelib.Drive.DRIVE_FILE_SCOPE];

void main() {
  var auth = new OAuth2(CLIENT_ID, SCOPES);
  var drive = new drivelib.Drive(auth);
  drive.makeAuthRequests = true;
  var filePicker = query("#filePicker");
  var loginButton = query("#login");
  var output = query("#text");
  
  void uploadFile(Event evt) {
    var file = evt.target.files[0];
    var reader = new FileReader();
    reader.readAsBinaryString(file);
    reader.on.load.add((Event e) {
      var contentType = file.type;
      if (contentType.isEmpty) {
        contentType = 'application/octet-stream';
      }
      var base64Data = window.btoa(reader.result);
      var newFile = new drivelib.File.fromJson({"title": file.name, "mimeType": contentType});
      output.appendHtml("Uploading file...<br>");
      drive.files.insert(newFile, content: base64Data, contentType: contentType)
        ..handleException((e) {
          output.appendHtml("$e<br>");
          return true;
        })
        ..then((data) {
          output.appendHtml("Uploaded file with ID <a href=\"${data.alternateLink}\" target=\"_blank\">${data.id}</a><br>");
        });
    });
  }
  
  filePicker.on.change.add(uploadFile);
  loginButton.on.click.add((Event e) {
    auth.login().then((token) {
      output.appendHtml("Got Token ${token.type} ${token.data}<br>");
      filePicker.style.display = "block";
    });
  });
}