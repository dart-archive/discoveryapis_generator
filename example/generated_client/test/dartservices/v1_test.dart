library generated_client.dartservices.v1.test;

import "dart:core" as core;
import "dart:collection" as collection;
import "dart:async" as async;
import "dart:convert" as convert;

import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;
import 'package:unittest/unittest.dart' as unittest;

import 'package:generated_client/dartservices/v1.dart' as api;

class HttpServerMock extends http.BaseClient {
  core.Function _callback;
  core.bool _expectJson;

  void register(core.Function callback, core.bool expectJson) {
    _callback = callback;
    _expectJson = expectJson;
  }

  async.Future<http.StreamedResponse> send(http.BaseRequest request) {
    if (_expectJson) {
      return request.finalize()
          .transform(convert.UTF8.decoder)
          .join('')
          .then((core.String jsonString) {
        if (jsonString.isEmpty) {
          return _callback(request, null);
        } else {
          return _callback(request, convert.JSON.decode(jsonString));
        }
      });
    } else {
      var stream = request.finalize();
      if (stream == null) {
        return _callback(request, []);
      } else {
        return stream.toBytes().then((data) {
          return _callback(request, data);
        });
      }
    }
  }
}

http.StreamedResponse stringResponse(
    core.int status, core.Map headers, core.String body) {
  var stream = new async.Stream.fromIterable([convert.UTF8.encode(body)]);
  return new http.StreamedResponse(stream, status, headers: headers);
}

core.int buildCounterAnalysisIssue = 0;
buildAnalysisIssue() {
  var o = new api.AnalysisIssue();
  buildCounterAnalysisIssue++;
  if (buildCounterAnalysisIssue < 3) {
    o.charLength = 42;
    o.charStart = 42;
    o.kind = "foo";
    o.line = 42;
    o.location = "foo";
    o.message = "foo";
  }
  buildCounterAnalysisIssue--;
  return o;
}

checkAnalysisIssue(api.AnalysisIssue o) {
  buildCounterAnalysisIssue++;
  if (buildCounterAnalysisIssue < 3) {
    unittest.expect(o.charLength, unittest.equals(42));
    unittest.expect(o.charStart, unittest.equals(42));
    unittest.expect(o.kind, unittest.equals('foo'));
    unittest.expect(o.line, unittest.equals(42));
    unittest.expect(o.location, unittest.equals('foo'));
    unittest.expect(o.message, unittest.equals('foo'));
  }
  buildCounterAnalysisIssue--;
}

buildUnnamed0() {
  var o = new core.List<api.AnalysisIssue>();
  o.add(buildAnalysisIssue());
  o.add(buildAnalysisIssue());
  return o;
}

checkUnnamed0(core.List<api.AnalysisIssue> o) {
  unittest.expect(o, unittest.hasLength(2));
  checkAnalysisIssue(o[0]);
  checkAnalysisIssue(o[1]);
}

core.int buildCounterAnalysisResults = 0;
buildAnalysisResults() {
  var o = new api.AnalysisResults();
  buildCounterAnalysisResults++;
  if (buildCounterAnalysisResults < 3) {
    o.issues = buildUnnamed0();
  }
  buildCounterAnalysisResults--;
  return o;
}

checkAnalysisResults(api.AnalysisResults o) {
  buildCounterAnalysisResults++;
  if (buildCounterAnalysisResults < 3) {
    checkUnnamed0(o.issues);
  }
  buildCounterAnalysisResults--;
}

core.int buildCounterCompileResponse = 0;
buildCompileResponse() {
  var o = new api.CompileResponse();
  buildCounterCompileResponse++;
  if (buildCounterCompileResponse < 3) {
    o.result = "foo";
  }
  buildCounterCompileResponse--;
  return o;
}

checkCompileResponse(api.CompileResponse o) {
  buildCounterCompileResponse++;
  if (buildCounterCompileResponse < 3) {
    unittest.expect(o.result, unittest.equals('foo'));
  }
  buildCounterCompileResponse--;
}

buildUnnamed1() {
  var o = new core.Map<core.String, core.String>();
  o["x"] = "foo";
  o["y"] = "foo";
  return o;
}

checkUnnamed1(core.Map<core.String, core.String> o) {
  unittest.expect(o, unittest.hasLength(2));
  unittest.expect(o["x"], unittest.equals('foo'));
  unittest.expect(o["y"], unittest.equals('foo'));
}

core.int buildCounterDocumentResponse = 0;
buildDocumentResponse() {
  var o = new api.DocumentResponse();
  buildCounterDocumentResponse++;
  if (buildCounterDocumentResponse < 3) {
    o.info = buildUnnamed1();
  }
  buildCounterDocumentResponse--;
  return o;
}

checkDocumentResponse(api.DocumentResponse o) {
  buildCounterDocumentResponse++;
  if (buildCounterDocumentResponse < 3) {
    checkUnnamed1(o.info);
  }
  buildCounterDocumentResponse--;
}

core.int buildCounterSourceRequest = 0;
buildSourceRequest() {
  var o = new api.SourceRequest();
  buildCounterSourceRequest++;
  if (buildCounterSourceRequest < 3) {
    o.offset = 42;
    o.source = "foo";
  }
  buildCounterSourceRequest--;
  return o;
}

checkSourceRequest(api.SourceRequest o) {
  buildCounterSourceRequest++;
  if (buildCounterSourceRequest < 3) {
    unittest.expect(o.offset, unittest.equals(42));
    unittest.expect(o.source, unittest.equals('foo'));
  }
  buildCounterSourceRequest--;
}


main() {
  unittest.group("obj-schema-AnalysisIssue", () {
    unittest.test("to-json--from-json", () {
      var o = buildAnalysisIssue();
      var od = new api.AnalysisIssue.fromJson(o.toJson());
      checkAnalysisIssue(od);
    });
  });


  unittest.group("obj-schema-AnalysisResults", () {
    unittest.test("to-json--from-json", () {
      var o = buildAnalysisResults();
      var od = new api.AnalysisResults.fromJson(o.toJson());
      checkAnalysisResults(od);
    });
  });


  unittest.group("obj-schema-CompileResponse", () {
    unittest.test("to-json--from-json", () {
      var o = buildCompileResponse();
      var od = new api.CompileResponse.fromJson(o.toJson());
      checkCompileResponse(od);
    });
  });


  unittest.group("obj-schema-DocumentResponse", () {
    unittest.test("to-json--from-json", () {
      var o = buildDocumentResponse();
      var od = new api.DocumentResponse.fromJson(o.toJson());
      checkDocumentResponse(od);
    });
  });


  unittest.group("obj-schema-SourceRequest", () {
    unittest.test("to-json--from-json", () {
      var o = buildSourceRequest();
      var od = new api.SourceRequest.fromJson(o.toJson());
      checkSourceRequest(od);
    });
  });


  unittest.group("resource-DartservicesApi", () {
    unittest.test("method--analyze", () {

      var mock = new HttpServerMock();
      api.DartservicesApi res = new api.DartservicesApi(mock);
      var arg_request = buildSourceRequest();
      mock.register(unittest.expectAsync((http.BaseRequest req, json) {
        var obj = new api.SourceRequest.fromJson(json);
        checkSourceRequest(obj);

        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 20), unittest.equals("api/dartservices/v1/"));
        pathOffset += 20;
        unittest.expect(path.substring(pathOffset, pathOffset + 7), unittest.equals("analyze"));
        pathOffset += 7;

        var query = (req.url).query;
        var queryOffset = 0;
        var queryMap = {};
        addQueryParam(n, v) => queryMap.putIfAbsent(n, () => []).add(v);
        parseBool(n) {
          if (n == "true") return true;
          if (n == "false") return false;
          if (n == null) return null;
          throw new core.ArgumentError("Invalid boolean: $n");
        }
        if (query.length > 0) {
          for (var part in query.split("&")) {
            var keyvalue = part.split("=");
            addQueryParam(core.Uri.decodeQueryComponent(keyvalue[0]), core.Uri.decodeQueryComponent(keyvalue[1]));
          }
        }


        var h = {
          "content-type" : "application/json; charset=utf-8",
        };
        var resp = convert.JSON.encode(buildAnalysisResults());
        return new async.Future.value(stringResponse(200, h, resp));
      }), true);
      res.analyze(arg_request).then(unittest.expectAsync(((api.AnalysisResults response) {
        checkAnalysisResults(response);
      })));
    });

    unittest.test("method--analyzeGet", () {

      var mock = new HttpServerMock();
      api.DartservicesApi res = new api.DartservicesApi(mock);
      var arg_source = "foo";
      mock.register(unittest.expectAsync((http.BaseRequest req, json) {
        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 20), unittest.equals("api/dartservices/v1/"));
        pathOffset += 20;
        unittest.expect(path.substring(pathOffset, pathOffset + 7), unittest.equals("analyze"));
        pathOffset += 7;

        var query = (req.url).query;
        var queryOffset = 0;
        var queryMap = {};
        addQueryParam(n, v) => queryMap.putIfAbsent(n, () => []).add(v);
        parseBool(n) {
          if (n == "true") return true;
          if (n == "false") return false;
          if (n == null) return null;
          throw new core.ArgumentError("Invalid boolean: $n");
        }
        if (query.length > 0) {
          for (var part in query.split("&")) {
            var keyvalue = part.split("=");
            addQueryParam(core.Uri.decodeQueryComponent(keyvalue[0]), core.Uri.decodeQueryComponent(keyvalue[1]));
          }
        }
        unittest.expect(queryMap["source"].first, unittest.equals(arg_source));


        var h = {
          "content-type" : "application/json; charset=utf-8",
        };
        var resp = convert.JSON.encode(buildAnalysisResults());
        return new async.Future.value(stringResponse(200, h, resp));
      }), true);
      res.analyzeGet(source: arg_source).then(unittest.expectAsync(((api.AnalysisResults response) {
        checkAnalysisResults(response);
      })));
    });

    unittest.test("method--compile", () {

      var mock = new HttpServerMock();
      api.DartservicesApi res = new api.DartservicesApi(mock);
      var arg_request = buildSourceRequest();
      mock.register(unittest.expectAsync((http.BaseRequest req, json) {
        var obj = new api.SourceRequest.fromJson(json);
        checkSourceRequest(obj);

        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 20), unittest.equals("api/dartservices/v1/"));
        pathOffset += 20;
        unittest.expect(path.substring(pathOffset, pathOffset + 7), unittest.equals("compile"));
        pathOffset += 7;

        var query = (req.url).query;
        var queryOffset = 0;
        var queryMap = {};
        addQueryParam(n, v) => queryMap.putIfAbsent(n, () => []).add(v);
        parseBool(n) {
          if (n == "true") return true;
          if (n == "false") return false;
          if (n == null) return null;
          throw new core.ArgumentError("Invalid boolean: $n");
        }
        if (query.length > 0) {
          for (var part in query.split("&")) {
            var keyvalue = part.split("=");
            addQueryParam(core.Uri.decodeQueryComponent(keyvalue[0]), core.Uri.decodeQueryComponent(keyvalue[1]));
          }
        }


        var h = {
          "content-type" : "application/json; charset=utf-8",
        };
        var resp = convert.JSON.encode(buildCompileResponse());
        return new async.Future.value(stringResponse(200, h, resp));
      }), true);
      res.compile(arg_request).then(unittest.expectAsync(((api.CompileResponse response) {
        checkCompileResponse(response);
      })));
    });

    unittest.test("method--compileGet", () {

      var mock = new HttpServerMock();
      api.DartservicesApi res = new api.DartservicesApi(mock);
      var arg_source = "foo";
      mock.register(unittest.expectAsync((http.BaseRequest req, json) {
        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 20), unittest.equals("api/dartservices/v1/"));
        pathOffset += 20;
        unittest.expect(path.substring(pathOffset, pathOffset + 7), unittest.equals("compile"));
        pathOffset += 7;

        var query = (req.url).query;
        var queryOffset = 0;
        var queryMap = {};
        addQueryParam(n, v) => queryMap.putIfAbsent(n, () => []).add(v);
        parseBool(n) {
          if (n == "true") return true;
          if (n == "false") return false;
          if (n == null) return null;
          throw new core.ArgumentError("Invalid boolean: $n");
        }
        if (query.length > 0) {
          for (var part in query.split("&")) {
            var keyvalue = part.split("=");
            addQueryParam(core.Uri.decodeQueryComponent(keyvalue[0]), core.Uri.decodeQueryComponent(keyvalue[1]));
          }
        }
        unittest.expect(queryMap["source"].first, unittest.equals(arg_source));


        var h = {
          "content-type" : "application/json; charset=utf-8",
        };
        var resp = convert.JSON.encode(buildCompileResponse());
        return new async.Future.value(stringResponse(200, h, resp));
      }), true);
      res.compileGet(source: arg_source).then(unittest.expectAsync(((api.CompileResponse response) {
        checkCompileResponse(response);
      })));
    });

    unittest.test("method--complete", () {

      var mock = new HttpServerMock();
      api.DartservicesApi res = new api.DartservicesApi(mock);
      var arg_request = buildSourceRequest();
      mock.register(unittest.expectAsync((http.BaseRequest req, json) {
        var obj = new api.SourceRequest.fromJson(json);
        checkSourceRequest(obj);

        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 20), unittest.equals("api/dartservices/v1/"));
        pathOffset += 20;
        unittest.expect(path.substring(pathOffset, pathOffset + 8), unittest.equals("complete"));
        pathOffset += 8;

        var query = (req.url).query;
        var queryOffset = 0;
        var queryMap = {};
        addQueryParam(n, v) => queryMap.putIfAbsent(n, () => []).add(v);
        parseBool(n) {
          if (n == "true") return true;
          if (n == "false") return false;
          if (n == null) return null;
          throw new core.ArgumentError("Invalid boolean: $n");
        }
        if (query.length > 0) {
          for (var part in query.split("&")) {
            var keyvalue = part.split("=");
            addQueryParam(core.Uri.decodeQueryComponent(keyvalue[0]), core.Uri.decodeQueryComponent(keyvalue[1]));
          }
        }


        var h = {
          "content-type" : "application/json; charset=utf-8",
        };
        var resp = "";
        return new async.Future.value(stringResponse(200, h, resp));
      }), true);
      res.complete(arg_request).then(unittest.expectAsync((_) {}));
    });

    unittest.test("method--completeGet", () {

      var mock = new HttpServerMock();
      api.DartservicesApi res = new api.DartservicesApi(mock);
      var arg_source = "foo";
      var arg_offset = 42;
      mock.register(unittest.expectAsync((http.BaseRequest req, json) {
        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 20), unittest.equals("api/dartservices/v1/"));
        pathOffset += 20;
        unittest.expect(path.substring(pathOffset, pathOffset + 8), unittest.equals("complete"));
        pathOffset += 8;

        var query = (req.url).query;
        var queryOffset = 0;
        var queryMap = {};
        addQueryParam(n, v) => queryMap.putIfAbsent(n, () => []).add(v);
        parseBool(n) {
          if (n == "true") return true;
          if (n == "false") return false;
          if (n == null) return null;
          throw new core.ArgumentError("Invalid boolean: $n");
        }
        if (query.length > 0) {
          for (var part in query.split("&")) {
            var keyvalue = part.split("=");
            addQueryParam(core.Uri.decodeQueryComponent(keyvalue[0]), core.Uri.decodeQueryComponent(keyvalue[1]));
          }
        }
        unittest.expect(queryMap["source"].first, unittest.equals(arg_source));
        unittest.expect(core.int.parse(queryMap["offset"].first), unittest.equals(arg_offset));


        var h = {
          "content-type" : "application/json; charset=utf-8",
        };
        var resp = "";
        return new async.Future.value(stringResponse(200, h, resp));
      }), true);
      res.completeGet(source: arg_source, offset: arg_offset).then(unittest.expectAsync((_) {}));
    });

    unittest.test("method--document", () {

      var mock = new HttpServerMock();
      api.DartservicesApi res = new api.DartservicesApi(mock);
      var arg_request = buildSourceRequest();
      mock.register(unittest.expectAsync((http.BaseRequest req, json) {
        var obj = new api.SourceRequest.fromJson(json);
        checkSourceRequest(obj);

        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 20), unittest.equals("api/dartservices/v1/"));
        pathOffset += 20;
        unittest.expect(path.substring(pathOffset, pathOffset + 8), unittest.equals("document"));
        pathOffset += 8;

        var query = (req.url).query;
        var queryOffset = 0;
        var queryMap = {};
        addQueryParam(n, v) => queryMap.putIfAbsent(n, () => []).add(v);
        parseBool(n) {
          if (n == "true") return true;
          if (n == "false") return false;
          if (n == null) return null;
          throw new core.ArgumentError("Invalid boolean: $n");
        }
        if (query.length > 0) {
          for (var part in query.split("&")) {
            var keyvalue = part.split("=");
            addQueryParam(core.Uri.decodeQueryComponent(keyvalue[0]), core.Uri.decodeQueryComponent(keyvalue[1]));
          }
        }


        var h = {
          "content-type" : "application/json; charset=utf-8",
        };
        var resp = convert.JSON.encode(buildDocumentResponse());
        return new async.Future.value(stringResponse(200, h, resp));
      }), true);
      res.document(arg_request).then(unittest.expectAsync(((api.DocumentResponse response) {
        checkDocumentResponse(response);
      })));
    });

    unittest.test("method--documentGet", () {

      var mock = new HttpServerMock();
      api.DartservicesApi res = new api.DartservicesApi(mock);
      var arg_source = "foo";
      var arg_offset = 42;
      mock.register(unittest.expectAsync((http.BaseRequest req, json) {
        var path = (req.url).path;
        var pathOffset = 0;
        var index;
        var subPart;
        unittest.expect(path.substring(pathOffset, pathOffset + 1), unittest.equals("/"));
        pathOffset += 1;
        unittest.expect(path.substring(pathOffset, pathOffset + 20), unittest.equals("api/dartservices/v1/"));
        pathOffset += 20;
        unittest.expect(path.substring(pathOffset, pathOffset + 8), unittest.equals("document"));
        pathOffset += 8;

        var query = (req.url).query;
        var queryOffset = 0;
        var queryMap = {};
        addQueryParam(n, v) => queryMap.putIfAbsent(n, () => []).add(v);
        parseBool(n) {
          if (n == "true") return true;
          if (n == "false") return false;
          if (n == null) return null;
          throw new core.ArgumentError("Invalid boolean: $n");
        }
        if (query.length > 0) {
          for (var part in query.split("&")) {
            var keyvalue = part.split("=");
            addQueryParam(core.Uri.decodeQueryComponent(keyvalue[0]), core.Uri.decodeQueryComponent(keyvalue[1]));
          }
        }
        unittest.expect(queryMap["source"].first, unittest.equals(arg_source));
        unittest.expect(core.int.parse(queryMap["offset"].first), unittest.equals(arg_offset));


        var h = {
          "content-type" : "application/json; charset=utf-8",
        };
        var resp = convert.JSON.encode(buildDocumentResponse());
        return new async.Future.value(stringResponse(200, h, resp));
      }), true);
      res.documentGet(source: arg_source, offset: arg_offset).then(unittest.expectAsync(((api.DocumentResponse response) {
        checkDocumentResponse(response);
      })));
    });

  });


}

