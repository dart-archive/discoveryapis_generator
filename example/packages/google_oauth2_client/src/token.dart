part of google_oauth2_client;

/// An OAuth2 authentication token.
class Token {
  /// The token type, usually "Bearer"
  final String type;
  /// The raw token data used for authentication
  final String data;
  /// Time at which the token will be expired
  final Date expiry;
  /// The email address of the user, only set if the scopes include
  /// https://www.googleapis.com/auth/userinfo.email
  String get email => _email;
  /// A unique identifier of the user, only set if the scopes include
  /// https://www.googleapis.com/auth/userinfo.profile
  String get userId => _userId;
  String _email;
  String _userId;

  Token(String this.type, String this.data, Date this.expiry);

  factory Token.fromJson(String json) {
    final map = JSON.parse(json);
    final token = new Token(map['type'], map['data'],
        new Date.fromMillisecondsSinceEpoch(map['expiry']));
    token._email = map['email'];
    token._userId = map['userId'];
    return token;
  }

  bool get expired => new Date.now().compareTo(expiry) > 0;

  String toString() => "[Token type=$type, data=$data, expired=$expired, "
      "expiry=$expiry, email=$email, userId=$userId]";

  /// Query whether this token is still valid.
  Future<bool> validate(String clientId,
      {String service: "https://www.googleapis.com/oauth2/v1/tokeninfo"}) {
    String url = new UrlPattern(service).generate({}, {"access_token": data});
    var completer = new Completer();
    var request = new HttpRequest();
    request.on.loadEnd.add((Event e) {
      if (request.status == 200) {
        completer.complete(request.responseText);
      }
    });
    request.open("GET", url);
    request.send();

    return completer.future.then((json) {
      final data = JSON.parse(json);
      final valid = clientId == data['audience'];
      if (valid) {
        _email = data['email'];
        _userId = data['user_id'];
      }
      return valid;
    });
  }

  String toJson() {
    return JSON.stringify({
      "type": type,
      "data": data,
      "expiry": expiry.millisecondsSinceEpoch,
      "email": email,
      "userId": userId,
    });
  }

  static Token _parse(String data) {
    if (data == null) {
      throw new Exception("No auth token data");
    }

    Map<String, String> params = {};
    for (String kv in _tokenizeRelativeUrl(data)) {
      if (kv.isEmpty) {
        continue;
      }
      int eqIndex = kv.indexOf('=');
      if (eqIndex < 0) {
        params[kv] = "";
      } else {
        params[kv.substring(0, eqIndex)] = kv.substring(eqIndex + 1);
      }
    }

    if (params.containsKey('error')) {
      throw new AuthException(params['error'], params);
    }
    for (String param in ['access_token', 'token_type', 'expires_in']) {
      if (!params.containsKey(param)) {
        throw new Exception("Missing parameter $param");
      }
    }

    // Mark tokens as 'expired' 20 seconds early so it's still valid when used.
    Duration duration =
        new Duration(seconds: int.parse(params['expires_in']) - 20);
    return new Token(params['token_type'], params['access_token'],
        new Date.now().add(duration));
  }

  /// Extracts &-separated tokens from the path, query, and fragment of [uri].
  static List<String> _tokenizeRelativeUrl(String uri) {
    final u = new Uri.fromString(uri);
    final result = [];
    [u.path, u.query, u.fragment].forEach((x) {
      if (x != null) result.addAll(_tokenize(x));
    });
    return result;
  }

  static List<String> _tokenize(String data) {
    return data.isEmpty ? [] : data.split('&');
  }
}

class AuthException implements Exception {
  final String message;
  final Map<String, String> data;
  AuthException(this.message, this.data);
  toString() => "AuthException: $message";
}
