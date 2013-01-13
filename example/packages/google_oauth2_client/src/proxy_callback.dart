part of google_oauth2_client;

typedef void _ProxyCallback(String subject, List<String> args);

/// Sets up a channel for listening to the token information posted by the
/// authorization url using the postMessage flow.
///
/// We create a hidden iframe hosting the provider's 'postmessageRelay' page,
/// which receives token information from the authorization popup and posts
/// it to this document. We also add a message listener to this document.
/// It detects such messages and invokes the provided callback.
class _ProxyChannel {
  String _nonce;
  String _provider;
  String _expectedOrigin;
  IFrameElement _element;
  _ProxyCallback _callback;

  _ProxyChannel(String this._provider, _ProxyCallback this._callback) {
    _nonce = (0x7FFFFFFF & random()).toString();
    _expectedOrigin = _origin(_provider);
    _element = _iframe(_getProxyUrl());
    window.on.message.add(_onMessage);
  }

  void close() {
    _element.remove();
    window.on.message.remove(_onMessage);
  }

  void _onMessage(MessageEvent event) {
    if (event.origin != _expectedOrigin) return;
    var data;
    try {
      data = JSON.parse(event.data);
    } catch (e) {
      print("Invalid JSON received via postMessage: ${event.data}");
      return;
    }
    if (!(data is Map) || (data['t'] != _nonce)) {
      return;
    }
    String subject = data['s'];
    if (subject.endsWith(':$_nonce')) {
      subject = subject.substring(0, subject.length - _nonce.length - 1);
    }
    _callback(subject, data['a']);
  }

  /// Computes the javascript origin of an absolute URI.
  String _origin(String uriString) {
    final uri = new Uri.fromString(uriString);
    final portPart = (uri.port != 0) ? ":${uri.port}" : "";
    return "${uri.scheme}://${uri.domain}$portPart";
  }

  String _getProxyUrl() {
    Map<String, String> proxyParams = {"parent": window.location.origin};
    String proxyUrl = new UrlPattern("${_provider}postmessageRelay")
        .generate({}, proxyParams);
    return new Uri.fromString(proxyUrl)
        .resolve("#rpctoken=$_nonce&forcesecure=1").toString();
  }
}