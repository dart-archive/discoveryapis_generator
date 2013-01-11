import "dart:html" as html;
import "package:drive_v2_api_client/drive.dart";
import "package:dart-google-oauth2-library/oauth2.dart";

final CLIENT_ID = "796343192238.apps.googleusercontent.com";
final SCOPES = ["https://www.googleapis.com/auth/drive.file"];

void main() {
  var auth = new OAuth2(CLIENT_ID, SCOPES);
  var drive = new Drive(null, auth);
  drive.makeAuthRequests = true;
  var filePicker = html.query("#filePicker");
  var loginButton = html.query("#login");
  var output = html.query("#text");
  
  void uploadFile(html.Event evt) {
    var file = evt.target.files[0];
    var reader = new html.FileReader();
    reader.readAsBinaryString(file);
    reader.on.load.add((html.Event e) {
      var contentType = file.type;
      if (contentType.isEmpty) {
        contentType = 'application/octet-stream';
      }
      var base64Data = html.window.btoa(reader.result);
      var newFile = new File.fromJson({"title": file.name, "mimeType": contentType});
      drive.files.insert(newFile, content: base64Data, contentType: contentType).then((data) {
        output.appendHtml("Uploaded file with ID ${data.id}<br>");
      });
    });
  }
  
  filePicker.on.change.add(uploadFile);
  loginButton.on.click.add((html.Event e) {
    auth.login().then((token) {
      output.appendHtml("Got Token ${token.type} ${token.data}<br>");
      filePicker.style.display = "block";
    });
  });
}