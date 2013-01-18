part of google_oauth2_client;

/// An OAuth2 authentication context.
class OAuth2 {
  String _clientId;
  List<String> _scopes;
  String _provider;
  Function _tokenLoaded;

  Future<_ProxyChannel> _channel;

  /// Future of the token we're waiting for.
  Future<Token> _tokenFuture;
  /// Destination for not-yet-validated tokens we're waiting to receive over
  /// the proxy channel.
  Completer<Token> _tokenCompleter;
  /// The last fetched token.
  Token __token; // Double-underscore because it has a private setter _token.

  /// Creates an OAuth2 context for the application identified by [clientId]
  /// and the permissions described by [scopes].
  /// If [tokenLoaded] is provided, it will be called with a [Token] when one
  /// is available. This can be used e.g. to set up a 'logged in' view.
  OAuth2(String clientId, List<String> scopes,
      {String provider:"https://accounts.google.com/o/oauth2/",
      tokenLoaded(Token token)})
      : _clientId = clientId,
      _scopes = scopes,
      _provider = provider,
      _tokenLoaded = tokenLoaded {
    _channel = _createFutureChannel();
    // Attempt an immediate login, we may already be authorized.
    login(immediate:true);
  }

  /// Set up the proxy iframe in the provider's origin that will receive
  /// postMessages and relay them to us.
  /// This completes asynchronously as the proxy iframe is not ready to use
  /// until we've received an 'oauth2relayReady' message from it.
  Future<_ProxyChannel> _createFutureChannel() {
    final completer = new Completer<_ProxyChannel>();
    var channel;
    channel = new _ProxyChannel(_provider, (subject, args) {
      switch (subject) {
        case "oauth2relayReady":
          completer.complete(channel);
          break;
        case "oauth2callback":
          try {
            Token token = Token._parse(args[0]);
            _tokenCompleter.complete(token);
          } catch (exception) {
            _tokenCompleter.completeError(exception);
          }
          break;
      }
    });
    return completer.future;
  }

  /// Get the URI that prompts the user for pemission (if required).
  String _getAuthorizeUri(bool immediate) {
    Map<String, String> queryParams = {
      "response_type": "token",
      "client_id": _clientId,
      "origin": window.location.origin,
      "redirect_uri": "postmessage", // Response will post to the proxy iframe
      "scope": Strings.join(_scopes, " "),
      "immediate": immediate,
    };
    return new UrlPattern("${_provider}auth").generate({}, queryParams);
  }

  /// Deletes the stored token
  logout() {
    _token = null;
  }

  /// Attempt to authenticate.
  /// If you have an existing valid token, it will be immediately returned.
  /// If you have an expired token, it will be silently renewed (override
  ///   with immediate:false)
  /// If you have no token, a popup prompt will be displayed.
  /// If the user declines, closes the popup, or the service returns a token
  /// that cannot be validated, an exception will be delivered.
  Future<Token> login({immediate: null}) {
    if (token != null) {
      if (token.expired) {
        if (immediate == null) {
          immediate = true; // We should be able to simply renew
        }
      } else { // We already have a good token
        return new Future<Token>.immediate(token);
      }
    }
    if (immediate == null) {
      immediate = false;
    }

    // Login may already be in progress
    if (_tokenFuture != null) {
      // An in-progress request will satisfy an immediate request
      // (even if it's not immediate).
      if (!immediate) {
        Completer result = new Completer<Token>();
        _tokenFuture
          .then((value) => result.complete(value))
          .catchError((e) {
            login(immediate:immediate)
              .then((value) => result.complete(value))
              .catchError((e) => result.completeError(e));
          });
        return result.future;
      }
    } else {
      Completer<Token> tokenCompleter = new Completer();
      tokenCompleter.future
        .then((token) {
          _tokenFuture = null;
          _token = token;
        })
        .catchError((e) {
          _tokenFuture = null;
          _token = null;
        });

      _tokenFuture = tokenCompleter.future;

      completeByPromptingUser() {
        _tokenCompleter = _wrapValidation(tokenCompleter);

        // Synchronous if the channel is already open -> avoids popup blocker
        
        _channel
          .then((value) {
            String uri = _getAuthorizeUri(immediate);
            if (immediate) {
              IFrameElement iframe = _iframe(uri);
              _tokenCompleter.future.whenComplete(() => iframe.remove());
            } else {
              WindowBase popup = _popup(uri);
              new _WindowPoller(_tokenCompleter, popup).poll();
            }          
          })
          .catchError((e) {
            return _tokenCompleter.completeError(e);
          });
      }

      final stored = _storedToken;
      if ((stored != null) && !stored.expired) {
        stored.validate(_clientId)
          .then((v) => tokenCompleter.complete(stored))
          .catchError((e) => completeByPromptingUser());
      } else {
        completeByPromptingUser();
      }
    }
    return _tokenFuture;
  }

  Future<HttpRequest> authenticate(HttpRequest request) =>
      login().then((token) {
        request.setRequestHeader("Authorization", "${token.type} ${token.data}");
        return request;
      });

  /// Returns the OAuth2 token, if one is currently available.
  Token get token => __token;

  set _token(Token value) {
    final invokeCallbacks = (__token == null) && (value != null);
    try {
      _storedToken = value;
    } catch (e) {
      print("Failed to cache OAuth2 token: $e");
    }
    __token = value;
    if (invokeCallbacks && (_tokenLoaded != null)) { window.setTimeout(() {
      try {
        _tokenLoaded(value);
      } catch (e) {
        print("Failed to invoke tokenLoaded callback: $e");
      }
    }, 0);
    }
  }

  Token get _storedToken => window.localStorage.containsKey(_storageKey)
      ? new Token.fromJson(window.localStorage[_storageKey])
      : null;

  set _storedToken(Token value) => (value == null)
      ? window.localStorage.remove(_storageKey)
      : window.localStorage[_storageKey] = value.toJson();

  /// Returns a unique identifier for this context for use in localStorage.
  String get _storageKey => JSON.stringify({
    "clientId": _clientId,
    "scopes": _scopes,
    "provider": _provider,
  });

  /// Takes a completer that accepts validated tokens, and returns a completer
  /// that accepts unvalidated tokens.
  Completer<Token> _wrapValidation(Completer<Token> validTokenCompleter) {
    Completer<Token> result = new Completer();
    result.future
      .then((value) {
        value.validate(_clientId)
          .then((validation) {
            if (validation) {
              validTokenCompleter.complete(value);
            } else {
              validTokenCompleter.completeError(new Exception("Server returned token is invalid"));
            }          
          })
          .catchError((e) => validTokenCompleter.completeError(e));
      })
      .catchError((e) => validTokenCompleter.completeError(e));

    return result;
  }
}