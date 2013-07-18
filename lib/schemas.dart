library schemas;

import 'dart:core' as core;
import 'dart:json' as JSON;
import 'dart:collection' as dart_collection;

class DirectoryList {

  /** Indicate the version of the Discovery API used to generate this doc. */
  core.String discoveryVersion;

  /** The individual directory entries. One entry per api/version pair. */
  core.List<DirectoryListItems> items;

  /** The kind for this response. */
  core.String kind;

  /** Create new DirectoryList from JSON data */
  DirectoryList.fromJson(core.Map json) {
    if (json.containsKey("discoveryVersion")) {
      discoveryVersion = json["discoveryVersion"];
    }
    if (json.containsKey("items")) {
      items = json["items"].map((itemsItem) => new DirectoryListItems.fromJson(itemsItem)).toList();
    }
    if (json.containsKey("kind")) {
      kind = json["kind"];
    }
  }

  /** Create JSON Object for DirectoryList */
  core.Map toJson() {
    var output = new core.Map();

    if (discoveryVersion != null) {
      output["discoveryVersion"] = discoveryVersion;
    }
    if (items != null) {
      output["items"] = items.map((itemsItem) => itemsItem.toJson()).toList();
    }
    if (kind != null) {
      output["kind"] = kind;
    }

    return output;
  }

  /** Return String representation of DirectoryList */
  core.String toString() => JSON.stringify(this.toJson());

}

class DirectoryListItems {

  /** The description of this API. */
  core.String description;

  /** A link to the discovery document. */
  core.String discoveryLink;

  /** The URL for the discovery REST document. */
  core.String discoveryRestUrl;

  /** A link to human readable documentation for the API. */
  core.String documentationLink;

  /** Links to 16x16 and 32x32 icons representing the API. */
  DirectoryListItemsIcons icons;

  /** The id of this API. */
  core.String id;

  /** The kind for this response. */
  core.String kind;

  /** Labels for the status of this API, such as labs or deprecated. */
  core.List<core.String> labels;

  /** The name of the API. */
  core.String name;

  /** True if this version is the preferred version to use. */
  core.bool preferred;

  /** The title of this API. */
  core.String title;

  /** The version of the API. */
  core.String version;

  /** Create new DirectoryListItems from JSON data */
  DirectoryListItems.fromJson(core.Map json) {
    if (json.containsKey("description")) {
      description = json["description"];
    }
    if (json.containsKey("discoveryLink")) {
      discoveryLink = json["discoveryLink"];
    }
    if (json.containsKey("discoveryRestUrl")) {
      discoveryRestUrl = json["discoveryRestUrl"];
    }
    if (json.containsKey("documentationLink")) {
      documentationLink = json["documentationLink"];
    }
    if (json.containsKey("icons")) {
      icons = new DirectoryListItemsIcons.fromJson(json["icons"]);
    }
    if (json.containsKey("id")) {
      id = json["id"];
    }
    if (json.containsKey("kind")) {
      kind = json["kind"];
    }
    if (json.containsKey("labels")) {
      labels = json["labels"].toList();
    }
    if (json.containsKey("name")) {
      name = json["name"];
    }
    if (json.containsKey("preferred")) {
      preferred = json["preferred"];
    }
    if (json.containsKey("title")) {
      title = json["title"];
    }
    if (json.containsKey("version")) {
      version = json["version"];
    }
  }

  /** Create JSON Object for DirectoryListItems */
  core.Map toJson() {
    var output = new core.Map();

    if (description != null) {
      output["description"] = description;
    }
    if (discoveryLink != null) {
      output["discoveryLink"] = discoveryLink;
    }
    if (discoveryRestUrl != null) {
      output["discoveryRestUrl"] = discoveryRestUrl;
    }
    if (documentationLink != null) {
      output["documentationLink"] = documentationLink;
    }
    if (icons != null) {
      output["icons"] = icons.toJson();
    }
    if (id != null) {
      output["id"] = id;
    }
    if (kind != null) {
      output["kind"] = kind;
    }
    if (labels != null) {
      output["labels"] = labels.toList();
    }
    if (name != null) {
      output["name"] = name;
    }
    if (preferred != null) {
      output["preferred"] = preferred;
    }
    if (title != null) {
      output["title"] = title;
    }
    if (version != null) {
      output["version"] = version;
    }

    return output;
  }

  /** Return String representation of DirectoryListItems */
  core.String toString() => JSON.stringify(this.toJson());

}

/** Links to 16x16 and 32x32 icons representing the API. */
class DirectoryListItemsIcons {

  /** The URL of the 16x16 icon. */
  core.String x16;

  /** The URL of the 32x32 icon. */
  core.String x32;

  /** Create new DirectoryListItemsIcons from JSON data */
  DirectoryListItemsIcons.fromJson(core.Map json) {
    if (json.containsKey("x16")) {
      x16 = json["x16"];
    }
    if (json.containsKey("x32")) {
      x32 = json["x32"];
    }
  }

  /** Create JSON Object for DirectoryListItemsIcons */
  core.Map toJson() {
    var output = new core.Map();

    if (x16 != null) {
      output["x16"] = x16;
    }
    if (x32 != null) {
      output["x32"] = x32;
    }

    return output;
  }

  /** Return String representation of DirectoryListItemsIcons */
  core.String toString() => JSON.stringify(this.toJson());

}

class JsonSchema {

  /** A reference to another schema. The value of this property is the "id" of another schema. */
  core.String $ref;

  /** If this is a schema for an object, this property is the schema for any additional properties with dynamic keys on this object. */
  JsonSchema additionalProperties;

  /** Additional information about this property. */
  JsonSchemaAnnotations annotations;

  /** The default value of this property (if one exists). */
  core.String defaultProperty;

  /** A description of this object. */
  core.String description;

  /** Values this parameter may take (if it is an enum). */
  core.List<core.String> enumProperty;

  /** The descriptions for the enums. Each position maps to the corresponding value in the "enum" array. */
  core.List<core.String> enumDescriptions;

  /** An additional regular expression or key that helps constrain the value. For more details see: http://tools.ietf.org/html/draft-zyp-json-schema-03#section-5.23 */
  core.String format;

  /** Unique identifier for this schema. */
  core.String id;

  /** If this is a schema for an array, this property is the schema for each element in the array. */
  JsonSchema items;

  /** Whether this parameter goes in the query or the path for REST requests. */
  core.String location;

  /** The maximum value of this parameter. */
  core.String maximum;

  /** The minimum value of this parameter. */
  core.String minimum;

  /** The regular expression this parameter must conform to. Uses Java 6 regex format: http://docs.oracle.com/javase/6/docs/api/java/util/regex/Pattern.html */
  core.String pattern;

  /** If this is a schema for an object, list the schema for each property of this object. */
  core.Map<core.String, JsonSchema> properties;

  /** The value is read-only, generated by the service. The value cannot be modified by the client. If the value is included in a POST, PUT, or PATCH request, it is ignored by the service. */
  core.bool readOnly;

  /** Whether this parameter may appear multiple times. */
  core.bool repeated;

  /** Whether the parameter is required. */
  core.bool required;

  /** The value type for this schema. A list of values can be found here: http://tools.ietf.org/html/draft-zyp-json-schema-03#section-5.1 */
  core.String type;

  /** Create new JsonSchema from JSON data */
  JsonSchema.fromJson(core.Map json) {
    if (json.containsKey("\$ref")) {
      $ref = json["\$ref"];
    }
    if (json.containsKey("additionalProperties")) {
      additionalProperties = new JsonSchema.fromJson(json["additionalProperties"]);
    }
    if (json.containsKey("annotations")) {
      annotations = new JsonSchemaAnnotations.fromJson(json["annotations"]);
    }
    if (json.containsKey("default")) {
      defaultProperty = json["default"];
    }
    if (json.containsKey("description")) {
      description = json["description"];
    }
    if (json.containsKey("enum")) {
      enumProperty = json["enum"].toList();
    }
    if (json.containsKey("enumDescriptions")) {
      enumDescriptions = json["enumDescriptions"].toList();
    }
    if (json.containsKey("format")) {
      format = json["format"];
    }
    if (json.containsKey("id")) {
      id = json["id"];
    }
    if (json.containsKey("items")) {
      items = new JsonSchema.fromJson(json["items"]);
    }
    if (json.containsKey("location")) {
      location = json["location"];
    }
    if (json.containsKey("maximum")) {
      maximum = json["maximum"];
    }
    if (json.containsKey("minimum")) {
      minimum = json["minimum"];
    }
    if (json.containsKey("pattern")) {
      pattern = json["pattern"];
    }
    if (json.containsKey("properties")) {
      properties = _mapMap(json["properties"], (propertiesItem) => new JsonSchema.fromJson(propertiesItem));
    }
    if (json.containsKey("readOnly")) {
      readOnly = json["readOnly"];
    }
    if (json.containsKey("repeated")) {
      repeated = json["repeated"];
    }
    if (json.containsKey("required")) {
      required = json["required"];
    }
    if (json.containsKey("type")) {
      type = json["type"];
    }
  }

  /** Create JSON Object for JsonSchema */
  core.Map toJson() {
    var output = new core.Map();

    if ($ref != null) {
      output["\$ref"] = $ref;
    }
    if (additionalProperties != null) {
      output["additionalProperties"] = additionalProperties.toJson();
    }
    if (annotations != null) {
      output["annotations"] = annotations.toJson();
    }
    if (defaultProperty != null) {
      output["default"] = defaultProperty;
    }
    if (description != null) {
      output["description"] = description;
    }
    if (enumProperty != null) {
      output["enum"] = enumProperty.toList();
    }
    if (enumDescriptions != null) {
      output["enumDescriptions"] = enumDescriptions.toList();
    }
    if (format != null) {
      output["format"] = format;
    }
    if (id != null) {
      output["id"] = id;
    }
    if (items != null) {
      output["items"] = items.toJson();
    }
    if (location != null) {
      output["location"] = location;
    }
    if (maximum != null) {
      output["maximum"] = maximum;
    }
    if (minimum != null) {
      output["minimum"] = minimum;
    }
    if (pattern != null) {
      output["pattern"] = pattern;
    }
    if (properties != null) {
      output["properties"] = _mapMap(properties, (propertiesItem) => propertiesItem.toJson());
    }
    if (readOnly != null) {
      output["readOnly"] = readOnly;
    }
    if (repeated != null) {
      output["repeated"] = repeated;
    }
    if (required != null) {
      output["required"] = required;
    }
    if (type != null) {
      output["type"] = type;
    }

    return output;
  }

  /** Return String representation of JsonSchema */
  core.String toString() => JSON.stringify(this.toJson());

}

/** Additional information about this property. */
class JsonSchemaAnnotations {

  /** A list of methods for which this property is required on requests. */
  core.List<core.String> required;

  /** Create new JsonSchemaAnnotations from JSON data */
  JsonSchemaAnnotations.fromJson(core.Map json) {
    if (json.containsKey("required")) {
      required = json["required"].toList();
    }
  }

  /** Create JSON Object for JsonSchemaAnnotations */
  core.Map toJson() {
    var output = new core.Map();

    if (required != null) {
      output["required"] = required.toList();
    }

    return output;
  }

  /** Return String representation of JsonSchemaAnnotations */
  core.String toString() => JSON.stringify(this.toJson());

}

class RestDescription {

  /** Authentication information. */
  RestDescriptionAuth auth;

  /** [DEPRECATED] The base path for REST requests. */
  core.String basePath;

  /** [DEPRECATED] The base URL for REST requests. */
  core.String baseUrl;

  /** The path for REST batch requests. */
  core.String batchPath;

  /** Indicates how the API name should be capitalized and split into various parts. Useful for generating pretty class names. */
  core.String canonicalName;

  /** The description of this API. */
  core.String description;

  /** Indicate the version of the Discovery API used to generate this doc. */
  core.String discoveryVersion;

  /** A link to human readable documentation for the API. */
  core.String documentationLink;

  /** The ETag for this response. */
  core.String etag;

  /** A list of supported features for this API. */
  core.List<core.String> features;

  /** Links to 16x16 and 32x32 icons representing the API. */
  RestDescriptionIcons icons;

  /** The ID of this API. */
  core.String id;

  /** The kind for this response. */
  core.String kind;

  /** Labels for the status of this API, such as labs or deprecated. */
  core.List<core.String> labels;

  /** API-level methods for this API. */
  core.Map<core.String, RestMethod> methods;

  /** The name of this API. */
  core.String name;

  /** The domain of the owner of this API. Together with the ownerName and a packagePath values, this can be used to generate a library for this API which would have a unique fully qualified name. */
  core.String ownerDomain;

  /** The name of the owner of this API. See ownerDomain. */
  core.String ownerName;

  /** The package of the owner of this API. See ownerDomain. */
  core.String packagePath;

  /** Common parameters that apply across all apis. */
  core.Map<core.String, JsonSchema> parameters;

  /** The protocol described by this document. */
  core.String protocol;

  /** The resources in this API. */
  core.Map<core.String, RestResource> resources;

  /** The version of this API. */
  core.String revision;

  /** The root URL under which all API services live. */
  core.String rootUrl;

  /** The schemas for this API. */
  core.Map<core.String, JsonSchema> schemas;

  /** The base path for all REST requests. */
  core.String servicePath;

  /** The title of this API. */
  core.String title;

  /** The version of this API. */
  core.String version;

  /** Create new RestDescription from JSON data */
  RestDescription.fromJson(core.Map json) {
    if (json.containsKey("auth")) {
      auth = new RestDescriptionAuth.fromJson(json["auth"]);
    }
    if (json.containsKey("basePath")) {
      basePath = json["basePath"];
    }
    if (json.containsKey("baseUrl")) {
      baseUrl = json["baseUrl"];
    }
    if (json.containsKey("batchPath")) {
      batchPath = json["batchPath"];
    }
    if (json.containsKey("canonicalName")) {
      canonicalName = json["canonicalName"];
    }
    if (json.containsKey("description")) {
      description = json["description"];
    }
    if (json.containsKey("discoveryVersion")) {
      discoveryVersion = json["discoveryVersion"];
    }
    if (json.containsKey("documentationLink")) {
      documentationLink = json["documentationLink"];
    }
    if (json.containsKey("etag")) {
      etag = json["etag"];
    }
    if (json.containsKey("features")) {
      features = json["features"].toList();
    }
    if (json.containsKey("icons")) {
      icons = new RestDescriptionIcons.fromJson(json["icons"]);
    }
    if (json.containsKey("id")) {
      id = json["id"];
    }
    if (json.containsKey("kind")) {
      kind = json["kind"];
    }
    if (json.containsKey("labels")) {
      labels = json["labels"].toList();
    }
    if (json.containsKey("methods")) {
      methods = _mapMap(json["methods"], (methodsItem) => new RestMethod.fromJson(methodsItem));
    }
    if (json.containsKey("name")) {
      name = json["name"];
    }
    if (json.containsKey("ownerDomain")) {
      ownerDomain = json["ownerDomain"];
    }
    if (json.containsKey("ownerName")) {
      ownerName = json["ownerName"];
    }
    if (json.containsKey("packagePath")) {
      packagePath = json["packagePath"];
    }
    if (json.containsKey("parameters")) {
      parameters = _mapMap(json["parameters"], (parametersItem) => new JsonSchema.fromJson(parametersItem));
    }
    if (json.containsKey("protocol")) {
      protocol = json["protocol"];
    }
    if (json.containsKey("resources")) {
      resources = _mapMap(json["resources"], (resourcesItem) => new RestResource.fromJson(resourcesItem));
    }
    if (json.containsKey("revision")) {
      revision = json["revision"];
    }
    if (json.containsKey("rootUrl")) {
      rootUrl = json["rootUrl"];
    }
    if (json.containsKey("schemas")) {
      schemas = _mapMap(json["schemas"], (schemasItem) => new JsonSchema.fromJson(schemasItem));
    }
    if (json.containsKey("servicePath")) {
      servicePath = json["servicePath"];
    }
    if (json.containsKey("title")) {
      title = json["title"];
    }
    if (json.containsKey("version")) {
      version = json["version"];
    }
  }

  /** Create JSON Object for RestDescription */
  core.Map toJson() {
    var output = new core.Map();

    if (auth != null) {
      output["auth"] = auth.toJson();
    }
    if (basePath != null) {
      output["basePath"] = basePath;
    }
    if (baseUrl != null) {
      output["baseUrl"] = baseUrl;
    }
    if (batchPath != null) {
      output["batchPath"] = batchPath;
    }
    if (canonicalName != null) {
      output["canonicalName"] = canonicalName;
    }
    if (description != null) {
      output["description"] = description;
    }
    if (discoveryVersion != null) {
      output["discoveryVersion"] = discoveryVersion;
    }
    if (documentationLink != null) {
      output["documentationLink"] = documentationLink;
    }
    if (etag != null) {
      output["etag"] = etag;
    }
    if (features != null) {
      output["features"] = features.toList();
    }
    if (icons != null) {
      output["icons"] = icons.toJson();
    }
    if (id != null) {
      output["id"] = id;
    }
    if (kind != null) {
      output["kind"] = kind;
    }
    if (labels != null) {
      output["labels"] = labels.toList();
    }
    if (methods != null) {
      output["methods"] = _mapMap(methods, (methodsItem) => methodsItem.toJson());
    }
    if (name != null) {
      output["name"] = name;
    }
    if (ownerDomain != null) {
      output["ownerDomain"] = ownerDomain;
    }
    if (ownerName != null) {
      output["ownerName"] = ownerName;
    }
    if (packagePath != null) {
      output["packagePath"] = packagePath;
    }
    if (parameters != null) {
      output["parameters"] = _mapMap(parameters, (parametersItem) => parametersItem.toJson());
    }
    if (protocol != null) {
      output["protocol"] = protocol;
    }
    if (resources != null) {
      output["resources"] = _mapMap(resources, (resourcesItem) => resourcesItem.toJson());
    }
    if (revision != null) {
      output["revision"] = revision;
    }
    if (rootUrl != null) {
      output["rootUrl"] = rootUrl;
    }
    if (schemas != null) {
      output["schemas"] = _mapMap(schemas, (schemasItem) => schemasItem.toJson());
    }
    if (servicePath != null) {
      output["servicePath"] = servicePath;
    }
    if (title != null) {
      output["title"] = title;
    }
    if (version != null) {
      output["version"] = version;
    }

    return output;
  }

  /** Return String representation of RestDescription */
  core.String toString() => JSON.stringify(this.toJson());

}

/** Authentication information. */
class RestDescriptionAuth {

  /** OAuth 2.0 authentication information. */
  RestDescriptionAuthOauth2 oauth2;

  /** Create new RestDescriptionAuth from JSON data */
  RestDescriptionAuth.fromJson(core.Map json) {
    if (json.containsKey("oauth2")) {
      oauth2 = new RestDescriptionAuthOauth2.fromJson(json["oauth2"]);
    }
  }

  /** Create JSON Object for RestDescriptionAuth */
  core.Map toJson() {
    var output = new core.Map();

    if (oauth2 != null) {
      output["oauth2"] = oauth2.toJson();
    }

    return output;
  }

  /** Return String representation of RestDescriptionAuth */
  core.String toString() => JSON.stringify(this.toJson());

}

/** OAuth 2.0 authentication information. */
class RestDescriptionAuthOauth2 {

  /** Available OAuth 2.0 scopes. */
  core.Map<core.String, RestDescriptionAuthOauth2Scopes> scopes;

  /** Create new RestDescriptionAuthOauth2 from JSON data */
  RestDescriptionAuthOauth2.fromJson(core.Map json) {
    if (json.containsKey("scopes")) {
      scopes = _mapMap(json["scopes"], (scopesItem) => new RestDescriptionAuthOauth2Scopes.fromJson(scopesItem));
    }
  }

  /** Create JSON Object for RestDescriptionAuthOauth2 */
  core.Map toJson() {
    var output = new core.Map();

    if (scopes != null) {
      output["scopes"] = _mapMap(scopes, (scopesItem) => scopesItem.toJson());
    }

    return output;
  }

  /** Return String representation of RestDescriptionAuthOauth2 */
  core.String toString() => JSON.stringify(this.toJson());

}

/** The scope value. */
class RestDescriptionAuthOauth2Scopes {

  /** Description of scope. */
  core.String description;

  /** Create new RestDescriptionAuthOauth2Scopes from JSON data */
  RestDescriptionAuthOauth2Scopes.fromJson(core.Map json) {
    if (json.containsKey("description")) {
      description = json["description"];
    }
  }

  /** Create JSON Object for RestDescriptionAuthOauth2Scopes */
  core.Map toJson() {
    var output = new core.Map();

    if (description != null) {
      output["description"] = description;
    }

    return output;
  }

  /** Return String representation of RestDescriptionAuthOauth2Scopes */
  core.String toString() => JSON.stringify(this.toJson());

}

/** Links to 16x16 and 32x32 icons representing the API. */
class RestDescriptionIcons {

  /** The URL of the 16x16 icon. */
  core.String x16;

  /** The URL of the 32x32 icon. */
  core.String x32;

  /** Create new RestDescriptionIcons from JSON data */
  RestDescriptionIcons.fromJson(core.Map json) {
    if (json.containsKey("x16")) {
      x16 = json["x16"];
    }
    if (json.containsKey("x32")) {
      x32 = json["x32"];
    }
  }

  /** Create JSON Object for RestDescriptionIcons */
  core.Map toJson() {
    var output = new core.Map();

    if (x16 != null) {
      output["x16"] = x16;
    }
    if (x32 != null) {
      output["x32"] = x32;
    }

    return output;
  }

  /** Return String representation of RestDescriptionIcons */
  core.String toString() => JSON.stringify(this.toJson());

}

class RestMethod {

  /** Description of this method. */
  core.String description;

  /** Whether this method requires an ETag to be specified. The ETag is sent as an HTTP If-Match or If-None-Match header. */
  core.bool etagRequired;

  /** HTTP method used by this method. */
  core.String httpMethod;

  /** A unique ID for this method. This property can be used to match methods between different versions of Discovery. */
  core.String id;

  /** Media upload parameters. */
  RestMethodMediaUpload mediaUpload;

  /** Ordered list of required parameters, serves as a hint to clients on how to structure their method signatures. The array is ordered such that the "most-significant" parameter appears first. */
  core.List<core.String> parameterOrder;

  /** Details for all parameters in this method. */
  core.Map<core.String, JsonSchema> parameters;

  /** The URI path of this REST method. Should be used in conjunction with the basePath property at the api-level. */
  core.String path;

  /** The schema for the request. */
  RestMethodRequest request;

  /** The schema for the response. */
  RestMethodResponse response;

  /** OAuth 2.0 scopes applicable to this method. */
  core.List<core.String> scopes;

  /** Whether this method supports media downloads. */
  core.bool supportsMediaDownload;

  /** Whether this method supports media uploads. */
  core.bool supportsMediaUpload;

  /** Whether this method supports subscriptions. */
  core.bool supportsSubscription;

  /** Create new RestMethod from JSON data */
  RestMethod.fromJson(core.Map json) {
    if (json.containsKey("description")) {
      description = json["description"];
    }
    if (json.containsKey("etagRequired")) {
      etagRequired = json["etagRequired"];
    }
    if (json.containsKey("httpMethod")) {
      httpMethod = json["httpMethod"];
    }
    if (json.containsKey("id")) {
      id = json["id"];
    }
    if (json.containsKey("mediaUpload")) {
      mediaUpload = new RestMethodMediaUpload.fromJson(json["mediaUpload"]);
    }
    if (json.containsKey("parameterOrder")) {
      parameterOrder = json["parameterOrder"].toList();
    }
    if (json.containsKey("parameters")) {
      parameters = _mapMap(json["parameters"], (parametersItem) => new JsonSchema.fromJson(parametersItem));
    }
    if (json.containsKey("path")) {
      path = json["path"];
    }
    if (json.containsKey("request")) {
      request = new RestMethodRequest.fromJson(json["request"]);
    }
    if (json.containsKey("response")) {
      response = new RestMethodResponse.fromJson(json["response"]);
    }
    if (json.containsKey("scopes")) {
      scopes = json["scopes"].toList();
    }
    if (json.containsKey("supportsMediaDownload")) {
      supportsMediaDownload = json["supportsMediaDownload"];
    }
    if (json.containsKey("supportsMediaUpload")) {
      supportsMediaUpload = json["supportsMediaUpload"];
    }
    if (json.containsKey("supportsSubscription")) {
      supportsSubscription = json["supportsSubscription"];
    }
  }

  /** Create JSON Object for RestMethod */
  core.Map toJson() {
    var output = new core.Map();

    if (description != null) {
      output["description"] = description;
    }
    if (etagRequired != null) {
      output["etagRequired"] = etagRequired;
    }
    if (httpMethod != null) {
      output["httpMethod"] = httpMethod;
    }
    if (id != null) {
      output["id"] = id;
    }
    if (mediaUpload != null) {
      output["mediaUpload"] = mediaUpload.toJson();
    }
    if (parameterOrder != null) {
      output["parameterOrder"] = parameterOrder.toList();
    }
    if (parameters != null) {
      output["parameters"] = _mapMap(parameters, (parametersItem) => parametersItem.toJson());
    }
    if (path != null) {
      output["path"] = path;
    }
    if (request != null) {
      output["request"] = request.toJson();
    }
    if (response != null) {
      output["response"] = response.toJson();
    }
    if (scopes != null) {
      output["scopes"] = scopes.toList();
    }
    if (supportsMediaDownload != null) {
      output["supportsMediaDownload"] = supportsMediaDownload;
    }
    if (supportsMediaUpload != null) {
      output["supportsMediaUpload"] = supportsMediaUpload;
    }
    if (supportsSubscription != null) {
      output["supportsSubscription"] = supportsSubscription;
    }

    return output;
  }

  /** Return String representation of RestMethod */
  core.String toString() => JSON.stringify(this.toJson());

}

/** Media upload parameters. */
class RestMethodMediaUpload {

  /** MIME Media Ranges for acceptable media uploads to this method. */
  core.List<core.String> accept;

  /** Maximum size of a media upload, such as "1MB", "2GB" or "3TB". */
  core.String maxSize;

  /** Supported upload protocols. */
  RestMethodMediaUploadProtocols protocols;

  /** Create new RestMethodMediaUpload from JSON data */
  RestMethodMediaUpload.fromJson(core.Map json) {
    if (json.containsKey("accept")) {
      accept = json["accept"].toList();
    }
    if (json.containsKey("maxSize")) {
      maxSize = json["maxSize"];
    }
    if (json.containsKey("protocols")) {
      protocols = new RestMethodMediaUploadProtocols.fromJson(json["protocols"]);
    }
  }

  /** Create JSON Object for RestMethodMediaUpload */
  core.Map toJson() {
    var output = new core.Map();

    if (accept != null) {
      output["accept"] = accept.toList();
    }
    if (maxSize != null) {
      output["maxSize"] = maxSize;
    }
    if (protocols != null) {
      output["protocols"] = protocols.toJson();
    }

    return output;
  }

  /** Return String representation of RestMethodMediaUpload */
  core.String toString() => JSON.stringify(this.toJson());

}

/** Supported upload protocols. */
class RestMethodMediaUploadProtocols {

  /** Supports the Resumable Media Upload protocol. */
  RestMethodMediaUploadProtocolsResumable resumable;

  /** Supports uploading as a single HTTP request. */
  RestMethodMediaUploadProtocolsSimple simple;

  /** Create new RestMethodMediaUploadProtocols from JSON data */
  RestMethodMediaUploadProtocols.fromJson(core.Map json) {
    if (json.containsKey("resumable")) {
      resumable = new RestMethodMediaUploadProtocolsResumable.fromJson(json["resumable"]);
    }
    if (json.containsKey("simple")) {
      simple = new RestMethodMediaUploadProtocolsSimple.fromJson(json["simple"]);
    }
  }

  /** Create JSON Object for RestMethodMediaUploadProtocols */
  core.Map toJson() {
    var output = new core.Map();

    if (resumable != null) {
      output["resumable"] = resumable.toJson();
    }
    if (simple != null) {
      output["simple"] = simple.toJson();
    }

    return output;
  }

  /** Return String representation of RestMethodMediaUploadProtocols */
  core.String toString() => JSON.stringify(this.toJson());

}

/** Supports the Resumable Media Upload protocol. */
class RestMethodMediaUploadProtocolsResumable {

  /** True if this endpoint supports uploading multipart media. */
  core.bool multipart;

  /** The URI path to be used for upload. Should be used in conjunction with the basePath property at the api-level. */
  core.String path;

  /** Create new RestMethodMediaUploadProtocolsResumable from JSON data */
  RestMethodMediaUploadProtocolsResumable.fromJson(core.Map json) {
    if (json.containsKey("multipart")) {
      multipart = json["multipart"];
    }
    if (json.containsKey("path")) {
      path = json["path"];
    }
  }

  /** Create JSON Object for RestMethodMediaUploadProtocolsResumable */
  core.Map toJson() {
    var output = new core.Map();

    if (multipart != null) {
      output["multipart"] = multipart;
    }
    if (path != null) {
      output["path"] = path;
    }

    return output;
  }

  /** Return String representation of RestMethodMediaUploadProtocolsResumable */
  core.String toString() => JSON.stringify(this.toJson());

}

/** Supports uploading as a single HTTP request. */
class RestMethodMediaUploadProtocolsSimple {

  /** True if this endpoint supports upload multipart media. */
  core.bool multipart;

  /** The URI path to be used for upload. Should be used in conjunction with the basePath property at the api-level. */
  core.String path;

  /** Create new RestMethodMediaUploadProtocolsSimple from JSON data */
  RestMethodMediaUploadProtocolsSimple.fromJson(core.Map json) {
    if (json.containsKey("multipart")) {
      multipart = json["multipart"];
    }
    if (json.containsKey("path")) {
      path = json["path"];
    }
  }

  /** Create JSON Object for RestMethodMediaUploadProtocolsSimple */
  core.Map toJson() {
    var output = new core.Map();

    if (multipart != null) {
      output["multipart"] = multipart;
    }
    if (path != null) {
      output["path"] = path;
    }

    return output;
  }

  /** Return String representation of RestMethodMediaUploadProtocolsSimple */
  core.String toString() => JSON.stringify(this.toJson());

}

/** The schema for the request. */
class RestMethodRequest {

  /** Schema ID for the request schema. */
  core.String $ref;

  /** parameter name. */
  core.String parameterName;

  /** Create new RestMethodRequest from JSON data */
  RestMethodRequest.fromJson(core.Map json) {
    if (json.containsKey("\$ref")) {
      $ref = json["\$ref"];
    }
    if (json.containsKey("parameterName")) {
      parameterName = json["parameterName"];
    }
  }

  /** Create JSON Object for RestMethodRequest */
  core.Map toJson() {
    var output = new core.Map();

    if ($ref != null) {
      output["\$ref"] = $ref;
    }
    if (parameterName != null) {
      output["parameterName"] = parameterName;
    }

    return output;
  }

  /** Return String representation of RestMethodRequest */
  core.String toString() => JSON.stringify(this.toJson());

}

/** The schema for the response. */
class RestMethodResponse {

  /** Schema ID for the response schema. */
  core.String $ref;

  /** Create new RestMethodResponse from JSON data */
  RestMethodResponse.fromJson(core.Map json) {
    if (json.containsKey("\$ref")) {
      $ref = json["\$ref"];
    }
  }

  /** Create JSON Object for RestMethodResponse */
  core.Map toJson() {
    var output = new core.Map();

    if ($ref != null) {
      output["\$ref"] = $ref;
    }

    return output;
  }

  /** Return String representation of RestMethodResponse */
  core.String toString() => JSON.stringify(this.toJson());

}

class RestResource {

  /** Methods on this resource. */
  core.Map<core.String, RestMethod> methods;

  /** Sub-resources on this resource. */
  core.Map<core.String, RestResource> resources;

  /** Create new RestResource from JSON data */
  RestResource.fromJson(core.Map json) {
    if (json.containsKey("methods")) {
      methods = _mapMap(json["methods"], (methodsItem) => new RestMethod.fromJson(methodsItem));
    }
    if (json.containsKey("resources")) {
      resources = _mapMap(json["resources"], (resourcesItem) => new RestResource.fromJson(resourcesItem));
    }
  }

  /** Create JSON Object for RestResource */
  core.Map toJson() {
    var output = new core.Map();

    if (methods != null) {
      output["methods"] = _mapMap(methods, (methodsItem) => methodsItem.toJson());
    }
    if (resources != null) {
      output["resources"] = _mapMap(resources, (resourcesItem) => resourcesItem.toJson());
    }

    return output;
  }

  /** Return String representation of RestResource */
  core.String toString() => JSON.stringify(this.toJson());

}

core.Map _mapMap(core.Map source, [core.Object convert(core.Object source) = null]) {
  assert(source != null);
  var result = new dart_collection.LinkedHashMap();
  source.forEach((core.String key, value) {
    assert(key != null);
    if(convert == null) {
      result[key] = value;
    } else {
      result[key] = convert(value);
    }
  });
  return result;
}
