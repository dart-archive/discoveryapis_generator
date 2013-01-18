part of google_oauth2_client;

/// Polls until either the future is completed or the window is closed.
/// If the window was closed without the future being completed, completes
/// the future with an exception.
class _WindowPoller {
  Completer<Token> _completer;
  WindowBase _window;
  bool _complete = false;
  
  _WindowPoller(Completer<Token> this._completer, WindowBase this._window) {
    _completer.future.whenComplete(() {
      _complete = true;
    });
  }
  

  void poll() {
    if (_complete) {
      return;
    }
    if (_window.closed) {
      _completer.completeError(new Exception("User closed the window"));
    } else {
      window.setTimeout(poll, 500);
    }
  }
}

/// Opens a popup centered on the screen displaying the provided URL.
WindowBase _popup(String url) {
  // Popup is desigend for 650x600, but don't make one bigger than the screen!
  int width = min(650, window.screen.width - 20);
  int height = min(600, window.screen.height - 30);
  int left = (window.screen.width - width) ~/ 2;
  int top = (window.screen.height - height) ~/ 2;
  return window.open(url, "_blank", "toolbar=no,location=no,directories="
    "no,status=no,menubar=no,scrollbars=yes,resizable=yes,copyhistory=no,"
    "width=$width,height=$height,top=$top,left=$left");
}

/// Creates a hidden iframe displaying the provided URL.
IFrameElement _iframe(String url) {
  IFrameElement iframe = new Element.tag("iframe");
  iframe.src = url;
  iframe.style.position = "absolute";
  iframe.width = iframe.height = "1";
  iframe.style.top = iframe.style.left = "-100px";
  document.body.children.add(iframe);
  return iframe;
}

/// Returns a random unsigned 32-bit integer.
int random() {
  final ary = new Uint32Array(1);
  window.crypto.getRandomValues(ary);
  return ary[0];
}