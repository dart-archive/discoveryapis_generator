part of drive_v2_api_client;

/** An item with user information and settings. */
class About {

  /** Information about supported additional roles per file type. The most specific type takes precedence. */
  List<AboutAdditionalRoleInfo> additionalRoleInfo;

  /** The domain sharing policy for the current user. */
  String domainSharingPolicy;

  /** The ETag of the item. */
  String etag;

  /** The allowable export formats. */
  List<AboutExportFormats> exportFormats;

  /** List of additional features enabled on this account. */
  List<AboutFeatures> features;

  /** The allowable import formats. */
  List<AboutImportFormats> importFormats;

  /** A boolean indicating whether the authenticated app is installed by the authenticated user. */
  bool isCurrentAppInstalled;

  /** This is always drive#about. */
  String kind;

  /** The largest change id. */
  String largestChangeId;

  /** List of max upload sizes for each file type. The most specific type takes precedence. */
  List<AboutMaxUploadSizes> maxUploadSizes;

  /** The name of the current user. */
  String name;

  /** The current user's ID as visible in the permissions collection. */
  String permissionId;

  /** The total number of quota bytes. */
  String quotaBytesTotal;

  /** The number of quota bytes used. */
  String quotaBytesUsed;

  /** The number of quota bytes used by all Google apps (Drive, Picasa, etc.). */
  String quotaBytesUsedAggregate;

  /** The number of quota bytes used by trashed items. */
  String quotaBytesUsedInTrash;

  /** The number of remaining change ids. */
  String remainingChangeIds;

  /** The id of the root folder. */
  String rootFolderId;

  /** A link back to this item. */
  String selfLink;

  /** The authenticated user. */
  User user;

  /** Create new About from JSON data */
  About.fromJson(Map json) {
    if (json.containsKey("additionalRoleInfo")) {
      additionalRoleInfo = [];
      json["additionalRoleInfo"].forEach((item) {
        additionalRoleInfo.add(new AboutAdditionalRoleInfo.fromJson(item));
      });
    }
    if (json.containsKey("domainSharingPolicy")) {
      domainSharingPolicy = json["domainSharingPolicy"];
    }
    if (json.containsKey("etag")) {
      etag = json["etag"];
    }
    if (json.containsKey("exportFormats")) {
      exportFormats = [];
      json["exportFormats"].forEach((item) {
        exportFormats.add(new AboutExportFormats.fromJson(item));
      });
    }
    if (json.containsKey("features")) {
      features = [];
      json["features"].forEach((item) {
        features.add(new AboutFeatures.fromJson(item));
      });
    }
    if (json.containsKey("importFormats")) {
      importFormats = [];
      json["importFormats"].forEach((item) {
        importFormats.add(new AboutImportFormats.fromJson(item));
      });
    }
    if (json.containsKey("isCurrentAppInstalled")) {
      isCurrentAppInstalled = json["isCurrentAppInstalled"];
    }
    if (json.containsKey("kind")) {
      kind = json["kind"];
    }
    if (json.containsKey("largestChangeId")) {
      largestChangeId = json["largestChangeId"];
    }
    if (json.containsKey("maxUploadSizes")) {
      maxUploadSizes = [];
      json["maxUploadSizes"].forEach((item) {
        maxUploadSizes.add(new AboutMaxUploadSizes.fromJson(item));
      });
    }
    if (json.containsKey("name")) {
      name = json["name"];
    }
    if (json.containsKey("permissionId")) {
      permissionId = json["permissionId"];
    }
    if (json.containsKey("quotaBytesTotal")) {
      quotaBytesTotal = json["quotaBytesTotal"];
    }
    if (json.containsKey("quotaBytesUsed")) {
      quotaBytesUsed = json["quotaBytesUsed"];
    }
    if (json.containsKey("quotaBytesUsedAggregate")) {
      quotaBytesUsedAggregate = json["quotaBytesUsedAggregate"];
    }
    if (json.containsKey("quotaBytesUsedInTrash")) {
      quotaBytesUsedInTrash = json["quotaBytesUsedInTrash"];
    }
    if (json.containsKey("remainingChangeIds")) {
      remainingChangeIds = json["remainingChangeIds"];
    }
    if (json.containsKey("rootFolderId")) {
      rootFolderId = json["rootFolderId"];
    }
    if (json.containsKey("selfLink")) {
      selfLink = json["selfLink"];
    }
    if (json.containsKey("user")) {
      user = new User.fromJson(json["user"]);
    }
  }

  /** Create JSON Object for About */
  Map toJson() {
    var output = new Map();

    if (additionalRoleInfo != null) {
      output["additionalRoleInfo"] = new List();
      additionalRoleInfo.forEach((item) {
        output["additionalRoleInfo"].add(item.toJson());
      });
    }
    if (domainSharingPolicy != null) {
      output["domainSharingPolicy"] = domainSharingPolicy;
    }
    if (etag != null) {
      output["etag"] = etag;
    }
    if (exportFormats != null) {
      output["exportFormats"] = new List();
      exportFormats.forEach((item) {
        output["exportFormats"].add(item.toJson());
      });
    }
    if (features != null) {
      output["features"] = new List();
      features.forEach((item) {
        output["features"].add(item.toJson());
      });
    }
    if (importFormats != null) {
      output["importFormats"] = new List();
      importFormats.forEach((item) {
        output["importFormats"].add(item.toJson());
      });
    }
    if (isCurrentAppInstalled != null) {
      output["isCurrentAppInstalled"] = isCurrentAppInstalled;
    }
    if (kind != null) {
      output["kind"] = kind;
    }
    if (largestChangeId != null) {
      output["largestChangeId"] = largestChangeId;
    }
    if (maxUploadSizes != null) {
      output["maxUploadSizes"] = new List();
      maxUploadSizes.forEach((item) {
        output["maxUploadSizes"].add(item.toJson());
      });
    }
    if (name != null) {
      output["name"] = name;
    }
    if (permissionId != null) {
      output["permissionId"] = permissionId;
    }
    if (quotaBytesTotal != null) {
      output["quotaBytesTotal"] = quotaBytesTotal;
    }
    if (quotaBytesUsed != null) {
      output["quotaBytesUsed"] = quotaBytesUsed;
    }
    if (quotaBytesUsedAggregate != null) {
      output["quotaBytesUsedAggregate"] = quotaBytesUsedAggregate;
    }
    if (quotaBytesUsedInTrash != null) {
      output["quotaBytesUsedInTrash"] = quotaBytesUsedInTrash;
    }
    if (remainingChangeIds != null) {
      output["remainingChangeIds"] = remainingChangeIds;
    }
    if (rootFolderId != null) {
      output["rootFolderId"] = rootFolderId;
    }
    if (selfLink != null) {
      output["selfLink"] = selfLink;
    }
    if (user != null) {
      output["user"] = user.toJson();
    }

    return output;
  }

  /** Return String representation of About */
  String toString() => JSON.stringify(this.toJson());

}

class AboutMaxUploadSizes {

  /** The max upload size for this type. */
  String size;

  /** The file type. */
  String type;

  /** Create new AboutMaxUploadSizes from JSON data */
  AboutMaxUploadSizes.fromJson(Map json) {
    if (json.containsKey("size")) {
      size = json["size"];
    }
    if (json.containsKey("type")) {
      type = json["type"];
    }
  }

  /** Create JSON Object for AboutMaxUploadSizes */
  Map toJson() {
    var output = new Map();

    if (size != null) {
      output["size"] = size;
    }
    if (type != null) {
      output["type"] = type;
    }

    return output;
  }

  /** Return String representation of AboutMaxUploadSizes */
  String toString() => JSON.stringify(this.toJson());

}

class AboutExportFormats {

  /** The content type to convert from. */
  String source;

  /** The possible content types to convert to. */
  List<String> targets;

  /** Create new AboutExportFormats from JSON data */
  AboutExportFormats.fromJson(Map json) {
    if (json.containsKey("source")) {
      source = json["source"];
    }
    if (json.containsKey("targets")) {
      targets = [];
      json["targets"].forEach((item) {
        targets.add(item);
      });
    }
  }

  /** Create JSON Object for AboutExportFormats */
  Map toJson() {
    var output = new Map();

    if (source != null) {
      output["source"] = source;
    }
    if (targets != null) {
      output["targets"] = new List();
      targets.forEach((item) {
        output["targets"].add(item);
      });
    }

    return output;
  }

  /** Return String representation of AboutExportFormats */
  String toString() => JSON.stringify(this.toJson());

}

class AboutFeatures {

  /** The name of the feature. */
  String featureName;

  /** The request limit rate for this feature, in queries per second. */
  num featureRate;

  /** Create new AboutFeatures from JSON data */
  AboutFeatures.fromJson(Map json) {
    if (json.containsKey("featureName")) {
      featureName = json["featureName"];
    }
    if (json.containsKey("featureRate")) {
      featureRate = json["featureRate"];
    }
  }

  /** Create JSON Object for AboutFeatures */
  Map toJson() {
    var output = new Map();

    if (featureName != null) {
      output["featureName"] = featureName;
    }
    if (featureRate != null) {
      output["featureRate"] = featureRate;
    }

    return output;
  }

  /** Return String representation of AboutFeatures */
  String toString() => JSON.stringify(this.toJson());

}

class AboutAdditionalRoleInfo {

  /** The supported additional roles per primary role. */
  List<AboutAdditionalRoleInfoRoleSets> roleSets;

  /** The content type that this additional role info applies to. */
  String type;

  /** Create new AboutAdditionalRoleInfo from JSON data */
  AboutAdditionalRoleInfo.fromJson(Map json) {
    if (json.containsKey("roleSets")) {
      roleSets = [];
      json["roleSets"].forEach((item) {
        roleSets.add(new AboutAdditionalRoleInfoRoleSets.fromJson(item));
      });
    }
    if (json.containsKey("type")) {
      type = json["type"];
    }
  }

  /** Create JSON Object for AboutAdditionalRoleInfo */
  Map toJson() {
    var output = new Map();

    if (roleSets != null) {
      output["roleSets"] = new List();
      roleSets.forEach((item) {
        output["roleSets"].add(item.toJson());
      });
    }
    if (type != null) {
      output["type"] = type;
    }

    return output;
  }

  /** Return String representation of AboutAdditionalRoleInfo */
  String toString() => JSON.stringify(this.toJson());

}

class AboutAdditionalRoleInfoRoleSets {

  /** The supported additional roles with the primary role. */
  List<String> additionalRoles;

  /** A primary permission role. */
  String primaryRole;

  /** Create new AboutAdditionalRoleInfoRoleSets from JSON data */
  AboutAdditionalRoleInfoRoleSets.fromJson(Map json) {
    if (json.containsKey("additionalRoles")) {
      additionalRoles = [];
      json["additionalRoles"].forEach((item) {
        additionalRoles.add(item);
      });
    }
    if (json.containsKey("primaryRole")) {
      primaryRole = json["primaryRole"];
    }
  }

  /** Create JSON Object for AboutAdditionalRoleInfoRoleSets */
  Map toJson() {
    var output = new Map();

    if (additionalRoles != null) {
      output["additionalRoles"] = new List();
      additionalRoles.forEach((item) {
        output["additionalRoles"].add(item);
      });
    }
    if (primaryRole != null) {
      output["primaryRole"] = primaryRole;
    }

    return output;
  }

  /** Return String representation of AboutAdditionalRoleInfoRoleSets */
  String toString() => JSON.stringify(this.toJson());

}

class AboutImportFormats {

  /** The imported file's content type to convert from. */
  String source;

  /** The possible content types to convert to. */
  List<String> targets;

  /** Create new AboutImportFormats from JSON data */
  AboutImportFormats.fromJson(Map json) {
    if (json.containsKey("source")) {
      source = json["source"];
    }
    if (json.containsKey("targets")) {
      targets = [];
      json["targets"].forEach((item) {
        targets.add(item);
      });
    }
  }

  /** Create JSON Object for AboutImportFormats */
  Map toJson() {
    var output = new Map();

    if (source != null) {
      output["source"] = source;
    }
    if (targets != null) {
      output["targets"] = new List();
      targets.forEach((item) {
        output["targets"].add(item);
      });
    }

    return output;
  }

  /** Return String representation of AboutImportFormats */
  String toString() => JSON.stringify(this.toJson());

}

/** Information about a third-party application which the user has installed or given access to Google Drive. */
class App {

  /** Whether the app is authorized to access data on the user's Drive. */
  bool authorized;

  /** The various icons for the app. */
  List<AppIcons> icons;

  /** The ID of the app. */
  String id;

  /** Whether the app is installed. */
  bool installed;

  /** This is always drive#app. */
  String kind;

  /** The name of the app. */
  String name;

  /** The type of object this app creates (e.g. Chart). If empty, the app name should be used instead. */
  String objectType;

  /** The list of primary file extensions. */
  List<String> primaryFileExtensions;

  /** The list of primary mime types. */
  List<String> primaryMimeTypes;

  /** The product URL. */
  String productUrl;

  /** The list of secondary file extensions. */
  List<String> secondaryFileExtensions;

  /** The list of secondary mime types. */
  List<String> secondaryMimeTypes;

  /** Whether this app supports creating new objects. */
  bool supportsCreate;

  /** Whether this app supports importing Google Docs. */
  bool supportsImport;

  /** Whether the app is selected as the default handler for the types it supports. */
  bool useByDefault;

  /** Create new App from JSON data */
  App.fromJson(Map json) {
    if (json.containsKey("authorized")) {
      authorized = json["authorized"];
    }
    if (json.containsKey("icons")) {
      icons = [];
      json["icons"].forEach((item) {
        icons.add(new AppIcons.fromJson(item));
      });
    }
    if (json.containsKey("id")) {
      id = json["id"];
    }
    if (json.containsKey("installed")) {
      installed = json["installed"];
    }
    if (json.containsKey("kind")) {
      kind = json["kind"];
    }
    if (json.containsKey("name")) {
      name = json["name"];
    }
    if (json.containsKey("objectType")) {
      objectType = json["objectType"];
    }
    if (json.containsKey("primaryFileExtensions")) {
      primaryFileExtensions = [];
      json["primaryFileExtensions"].forEach((item) {
        primaryFileExtensions.add(item);
      });
    }
    if (json.containsKey("primaryMimeTypes")) {
      primaryMimeTypes = [];
      json["primaryMimeTypes"].forEach((item) {
        primaryMimeTypes.add(item);
      });
    }
    if (json.containsKey("productUrl")) {
      productUrl = json["productUrl"];
    }
    if (json.containsKey("secondaryFileExtensions")) {
      secondaryFileExtensions = [];
      json["secondaryFileExtensions"].forEach((item) {
        secondaryFileExtensions.add(item);
      });
    }
    if (json.containsKey("secondaryMimeTypes")) {
      secondaryMimeTypes = [];
      json["secondaryMimeTypes"].forEach((item) {
        secondaryMimeTypes.add(item);
      });
    }
    if (json.containsKey("supportsCreate")) {
      supportsCreate = json["supportsCreate"];
    }
    if (json.containsKey("supportsImport")) {
      supportsImport = json["supportsImport"];
    }
    if (json.containsKey("useByDefault")) {
      useByDefault = json["useByDefault"];
    }
  }

  /** Create JSON Object for App */
  Map toJson() {
    var output = new Map();

    if (authorized != null) {
      output["authorized"] = authorized;
    }
    if (icons != null) {
      output["icons"] = new List();
      icons.forEach((item) {
        output["icons"].add(item.toJson());
      });
    }
    if (id != null) {
      output["id"] = id;
    }
    if (installed != null) {
      output["installed"] = installed;
    }
    if (kind != null) {
      output["kind"] = kind;
    }
    if (name != null) {
      output["name"] = name;
    }
    if (objectType != null) {
      output["objectType"] = objectType;
    }
    if (primaryFileExtensions != null) {
      output["primaryFileExtensions"] = new List();
      primaryFileExtensions.forEach((item) {
        output["primaryFileExtensions"].add(item);
      });
    }
    if (primaryMimeTypes != null) {
      output["primaryMimeTypes"] = new List();
      primaryMimeTypes.forEach((item) {
        output["primaryMimeTypes"].add(item);
      });
    }
    if (productUrl != null) {
      output["productUrl"] = productUrl;
    }
    if (secondaryFileExtensions != null) {
      output["secondaryFileExtensions"] = new List();
      secondaryFileExtensions.forEach((item) {
        output["secondaryFileExtensions"].add(item);
      });
    }
    if (secondaryMimeTypes != null) {
      output["secondaryMimeTypes"] = new List();
      secondaryMimeTypes.forEach((item) {
        output["secondaryMimeTypes"].add(item);
      });
    }
    if (supportsCreate != null) {
      output["supportsCreate"] = supportsCreate;
    }
    if (supportsImport != null) {
      output["supportsImport"] = supportsImport;
    }
    if (useByDefault != null) {
      output["useByDefault"] = useByDefault;
    }

    return output;
  }

  /** Return String representation of App */
  String toString() => JSON.stringify(this.toJson());

}

class AppIcons {

  /** Category of the icon. Allowed values are:  
- application - icon for the application 
- document - icon for a file associated with the app 
- documentShared - icon for a shared file associated with the app */
  String category;

  /** URL for the icon. */
  String iconUrl;

  /** Size of the icon. Represented as the maximum of the width and height. */
  int size;

  /** Create new AppIcons from JSON data */
  AppIcons.fromJson(Map json) {
    if (json.containsKey("category")) {
      category = json["category"];
    }
    if (json.containsKey("iconUrl")) {
      iconUrl = json["iconUrl"];
    }
    if (json.containsKey("size")) {
      size = json["size"];
    }
  }

  /** Create JSON Object for AppIcons */
  Map toJson() {
    var output = new Map();

    if (category != null) {
      output["category"] = category;
    }
    if (iconUrl != null) {
      output["iconUrl"] = iconUrl;
    }
    if (size != null) {
      output["size"] = size;
    }

    return output;
  }

  /** Return String representation of AppIcons */
  String toString() => JSON.stringify(this.toJson());

}

/** A list of third-party applications which the user has installed or given access to Google Drive. */
class AppList {

  /** The ETag of the list. */
  String etag;

  /** The actual list of apps. */
  List<App> items;

  /** This is always drive#appList. */
  String kind;

  /** A link back to this list. */
  String selfLink;

  /** Create new AppList from JSON data */
  AppList.fromJson(Map json) {
    if (json.containsKey("etag")) {
      etag = json["etag"];
    }
    if (json.containsKey("items")) {
      items = [];
      json["items"].forEach((item) {
        items.add(new App.fromJson(item));
      });
    }
    if (json.containsKey("kind")) {
      kind = json["kind"];
    }
    if (json.containsKey("selfLink")) {
      selfLink = json["selfLink"];
    }
  }

  /** Create JSON Object for AppList */
  Map toJson() {
    var output = new Map();

    if (etag != null) {
      output["etag"] = etag;
    }
    if (items != null) {
      output["items"] = new List();
      items.forEach((item) {
        output["items"].add(item.toJson());
      });
    }
    if (kind != null) {
      output["kind"] = kind;
    }
    if (selfLink != null) {
      output["selfLink"] = selfLink;
    }

    return output;
  }

  /** Return String representation of AppList */
  String toString() => JSON.stringify(this.toJson());

}

/** Representation of a change to a file. */
class Change {

  /** Whether the file has been deleted. */
  bool deleted;

  /** The updated state of the file. Present if the file has not been deleted. */
  File file;

  /** The ID of the file associated with this change. */
  String fileId;

  /** The ID of the change. */
  String id;

  /** This is always drive#change. */
  String kind;

  /** A link back to this change. */
  String selfLink;

  /** Create new Change from JSON data */
  Change.fromJson(Map json) {
    if (json.containsKey("deleted")) {
      deleted = json["deleted"];
    }
    if (json.containsKey("file")) {
      file = new File.fromJson(json["file"]);
    }
    if (json.containsKey("fileId")) {
      fileId = json["fileId"];
    }
    if (json.containsKey("id")) {
      id = json["id"];
    }
    if (json.containsKey("kind")) {
      kind = json["kind"];
    }
    if (json.containsKey("selfLink")) {
      selfLink = json["selfLink"];
    }
  }

  /** Create JSON Object for Change */
  Map toJson() {
    var output = new Map();

    if (deleted != null) {
      output["deleted"] = deleted;
    }
    if (file != null) {
      output["file"] = file.toJson();
    }
    if (fileId != null) {
      output["fileId"] = fileId;
    }
    if (id != null) {
      output["id"] = id;
    }
    if (kind != null) {
      output["kind"] = kind;
    }
    if (selfLink != null) {
      output["selfLink"] = selfLink;
    }

    return output;
  }

  /** Return String representation of Change */
  String toString() => JSON.stringify(this.toJson());

}

/** A list of changes for a user. */
class ChangeList {

  /** The ETag of the list. */
  String etag;

  /** The actual list of changes. */
  List<Change> items;

  /** This is always drive#changeList. */
  String kind;

  /** The current largest change ID. */
  String largestChangeId;

  /** A link to the next page of changes. */
  String nextLink;

  /** The page token for the next page of changes. */
  String nextPageToken;

  /** A link back to this list. */
  String selfLink;

  /** Create new ChangeList from JSON data */
  ChangeList.fromJson(Map json) {
    if (json.containsKey("etag")) {
      etag = json["etag"];
    }
    if (json.containsKey("items")) {
      items = [];
      json["items"].forEach((item) {
        items.add(new Change.fromJson(item));
      });
    }
    if (json.containsKey("kind")) {
      kind = json["kind"];
    }
    if (json.containsKey("largestChangeId")) {
      largestChangeId = json["largestChangeId"];
    }
    if (json.containsKey("nextLink")) {
      nextLink = json["nextLink"];
    }
    if (json.containsKey("nextPageToken")) {
      nextPageToken = json["nextPageToken"];
    }
    if (json.containsKey("selfLink")) {
      selfLink = json["selfLink"];
    }
  }

  /** Create JSON Object for ChangeList */
  Map toJson() {
    var output = new Map();

    if (etag != null) {
      output["etag"] = etag;
    }
    if (items != null) {
      output["items"] = new List();
      items.forEach((item) {
        output["items"].add(item.toJson());
      });
    }
    if (kind != null) {
      output["kind"] = kind;
    }
    if (largestChangeId != null) {
      output["largestChangeId"] = largestChangeId;
    }
    if (nextLink != null) {
      output["nextLink"] = nextLink;
    }
    if (nextPageToken != null) {
      output["nextPageToken"] = nextPageToken;
    }
    if (selfLink != null) {
      output["selfLink"] = selfLink;
    }

    return output;
  }

  /** Return String representation of ChangeList */
  String toString() => JSON.stringify(this.toJson());

}

/** A list of children of a file. */
class ChildList {

  /** The ETag of the list. */
  String etag;

  /** The actual list of children. */
  List<ChildReference> items;

  /** This is always drive#childList. */
  String kind;

  /** A link to the next page of children. */
  String nextLink;

  /** The page token for the next page of children. */
  String nextPageToken;

  /** A link back to this list. */
  String selfLink;

  /** Create new ChildList from JSON data */
  ChildList.fromJson(Map json) {
    if (json.containsKey("etag")) {
      etag = json["etag"];
    }
    if (json.containsKey("items")) {
      items = [];
      json["items"].forEach((item) {
        items.add(new ChildReference.fromJson(item));
      });
    }
    if (json.containsKey("kind")) {
      kind = json["kind"];
    }
    if (json.containsKey("nextLink")) {
      nextLink = json["nextLink"];
    }
    if (json.containsKey("nextPageToken")) {
      nextPageToken = json["nextPageToken"];
    }
    if (json.containsKey("selfLink")) {
      selfLink = json["selfLink"];
    }
  }

  /** Create JSON Object for ChildList */
  Map toJson() {
    var output = new Map();

    if (etag != null) {
      output["etag"] = etag;
    }
    if (items != null) {
      output["items"] = new List();
      items.forEach((item) {
        output["items"].add(item.toJson());
      });
    }
    if (kind != null) {
      output["kind"] = kind;
    }
    if (nextLink != null) {
      output["nextLink"] = nextLink;
    }
    if (nextPageToken != null) {
      output["nextPageToken"] = nextPageToken;
    }
    if (selfLink != null) {
      output["selfLink"] = selfLink;
    }

    return output;
  }

  /** Return String representation of ChildList */
  String toString() => JSON.stringify(this.toJson());

}

/** A reference to a file's child. */
class ChildReference {

  /** A link to the child. */
  String childLink;

  /** The ID of the child. */
  String id;

  /** This is always drive#childReference. */
  String kind;

  /** A link back to this reference. */
  String selfLink;

  /** Create new ChildReference from JSON data */
  ChildReference.fromJson(Map json) {
    if (json.containsKey("childLink")) {
      childLink = json["childLink"];
    }
    if (json.containsKey("id")) {
      id = json["id"];
    }
    if (json.containsKey("kind")) {
      kind = json["kind"];
    }
    if (json.containsKey("selfLink")) {
      selfLink = json["selfLink"];
    }
  }

  /** Create JSON Object for ChildReference */
  Map toJson() {
    var output = new Map();

    if (childLink != null) {
      output["childLink"] = childLink;
    }
    if (id != null) {
      output["id"] = id;
    }
    if (kind != null) {
      output["kind"] = kind;
    }
    if (selfLink != null) {
      output["selfLink"] = selfLink;
    }

    return output;
  }

  /** Return String representation of ChildReference */
  String toString() => JSON.stringify(this.toJson());

}

/** A JSON representation of a comment on a file in Google Drive. */
class Comment {

  /** A region of the document represented as a JSON string. See anchor documentation for details on how to define and interpret anchor properties. */
  String anchor;

  /** The user who wrote this comment. */
  User author;

  /** The ID of the comment. */
  String commentId;

  /** The plain text content used to create this comment. This is not HTML safe and should only be used as a starting point to make edits to a comment's content. */
  String content;

  /** The context of the file which is being commented on. */
  CommentContext context;

  /** The date when this comment was first created. */
  String createdDate;

  /** Whether this comment has been deleted. If a comment has been deleted the content will be cleared and this will only represent a comment that once existed. */
  bool deleted;

  /** The file which this comment is addressing. */
  String fileId;

  /** The title of the file which this comment is addressing. */
  String fileTitle;

  /** HTML formatted content for this comment. */
  String htmlContent;

  /** This is always drive#comment. */
  String kind;

  /** The date when this comment or any of its replies were last modified. */
  String modifiedDate;

  /** Replies to this post. */
  List<CommentReply> replies;

  /** A link back to this comment. */
  String selfLink;

  /** The status of this comment. Status can be changed by posting a reply to a comment with the desired status.  
- "open" - The comment is still open. 
- "resolved" - The comment has been resolved by one of its replies. */
  String status;

  /** Create new Comment from JSON data */
  Comment.fromJson(Map json) {
    if (json.containsKey("anchor")) {
      anchor = json["anchor"];
    }
    if (json.containsKey("author")) {
      author = new User.fromJson(json["author"]);
    }
    if (json.containsKey("commentId")) {
      commentId = json["commentId"];
    }
    if (json.containsKey("content")) {
      content = json["content"];
    }
    if (json.containsKey("context")) {
      context = new CommentContext.fromJson(json["context"]);
    }
    if (json.containsKey("createdDate")) {
      createdDate = json["createdDate"];
    }
    if (json.containsKey("deleted")) {
      deleted = json["deleted"];
    }
    if (json.containsKey("fileId")) {
      fileId = json["fileId"];
    }
    if (json.containsKey("fileTitle")) {
      fileTitle = json["fileTitle"];
    }
    if (json.containsKey("htmlContent")) {
      htmlContent = json["htmlContent"];
    }
    if (json.containsKey("kind")) {
      kind = json["kind"];
    }
    if (json.containsKey("modifiedDate")) {
      modifiedDate = json["modifiedDate"];
    }
    if (json.containsKey("replies")) {
      replies = [];
      json["replies"].forEach((item) {
        replies.add(new CommentReply.fromJson(item));
      });
    }
    if (json.containsKey("selfLink")) {
      selfLink = json["selfLink"];
    }
    if (json.containsKey("status")) {
      status = json["status"];
    }
  }

  /** Create JSON Object for Comment */
  Map toJson() {
    var output = new Map();

    if (anchor != null) {
      output["anchor"] = anchor;
    }
    if (author != null) {
      output["author"] = author.toJson();
    }
    if (commentId != null) {
      output["commentId"] = commentId;
    }
    if (content != null) {
      output["content"] = content;
    }
    if (context != null) {
      output["context"] = context.toJson();
    }
    if (createdDate != null) {
      output["createdDate"] = createdDate;
    }
    if (deleted != null) {
      output["deleted"] = deleted;
    }
    if (fileId != null) {
      output["fileId"] = fileId;
    }
    if (fileTitle != null) {
      output["fileTitle"] = fileTitle;
    }
    if (htmlContent != null) {
      output["htmlContent"] = htmlContent;
    }
    if (kind != null) {
      output["kind"] = kind;
    }
    if (modifiedDate != null) {
      output["modifiedDate"] = modifiedDate;
    }
    if (replies != null) {
      output["replies"] = new List();
      replies.forEach((item) {
        output["replies"].add(item.toJson());
      });
    }
    if (selfLink != null) {
      output["selfLink"] = selfLink;
    }
    if (status != null) {
      output["status"] = status;
    }

    return output;
  }

  /** Return String representation of Comment */
  String toString() => JSON.stringify(this.toJson());

}

/** The context of the file which is being commented on. */
class CommentContext {

  /** The MIME type of the context snippet. */
  String type;

  /** Data representation of the segment of the file being commented on. In the case of a text file for example, this would be the actual text that the comment is about. */
  String value;

  /** Create new CommentContext from JSON data */
  CommentContext.fromJson(Map json) {
    if (json.containsKey("type")) {
      type = json["type"];
    }
    if (json.containsKey("value")) {
      value = json["value"];
    }
  }

  /** Create JSON Object for CommentContext */
  Map toJson() {
    var output = new Map();

    if (type != null) {
      output["type"] = type;
    }
    if (value != null) {
      output["value"] = value;
    }

    return output;
  }

  /** Return String representation of CommentContext */
  String toString() => JSON.stringify(this.toJson());

}

/** A JSON representation of a list of comments on a file in Google Drive. */
class CommentList {

  /** List of comments. */
  List<Comment> items;

  /** This is always drive#commentList. */
  String kind;

  /** The token to use to request the next page of results. */
  String nextPageToken;

  /** Create new CommentList from JSON data */
  CommentList.fromJson(Map json) {
    if (json.containsKey("items")) {
      items = [];
      json["items"].forEach((item) {
        items.add(new Comment.fromJson(item));
      });
    }
    if (json.containsKey("kind")) {
      kind = json["kind"];
    }
    if (json.containsKey("nextPageToken")) {
      nextPageToken = json["nextPageToken"];
    }
  }

  /** Create JSON Object for CommentList */
  Map toJson() {
    var output = new Map();

    if (items != null) {
      output["items"] = new List();
      items.forEach((item) {
        output["items"].add(item.toJson());
      });
    }
    if (kind != null) {
      output["kind"] = kind;
    }
    if (nextPageToken != null) {
      output["nextPageToken"] = nextPageToken;
    }

    return output;
  }

  /** Return String representation of CommentList */
  String toString() => JSON.stringify(this.toJson());

}

/** A JSON representation of a reply to a comment on a file in Google Drive. */
class CommentReply {

  /** The user who wrote this reply. */
  User author;

  /** The plain text content used to create this reply. This is not HTML safe and should only be used as a starting point to make edits to a reply's content. This field is required on inserts if no verb is specified (resolve/reopen). */
  String content;

  /** The date when this reply was first created. */
  String createdDate;

  /** Whether this reply has been deleted. If a reply has been deleted the content will be cleared and this will only represent a reply that once existed. */
  bool deleted;

  /** HTML formatted content for this reply. */
  String htmlContent;

  /** This is always drive#commentReply. */
  String kind;

  /** The date when this reply was last modified. */
  String modifiedDate;

  /** The ID of the reply. */
  String replyId;

  /** The action this reply performed to the parent comment. When creating a new reply this is the action to be perform to the parent comment. Possible values are:  
- "resolve" - To resolve a comment. 
- "reopen" - To reopen (un-resolve) a comment. */
  String verb;

  /** Create new CommentReply from JSON data */
  CommentReply.fromJson(Map json) {
    if (json.containsKey("author")) {
      author = new User.fromJson(json["author"]);
    }
    if (json.containsKey("content")) {
      content = json["content"];
    }
    if (json.containsKey("createdDate")) {
      createdDate = json["createdDate"];
    }
    if (json.containsKey("deleted")) {
      deleted = json["deleted"];
    }
    if (json.containsKey("htmlContent")) {
      htmlContent = json["htmlContent"];
    }
    if (json.containsKey("kind")) {
      kind = json["kind"];
    }
    if (json.containsKey("modifiedDate")) {
      modifiedDate = json["modifiedDate"];
    }
    if (json.containsKey("replyId")) {
      replyId = json["replyId"];
    }
    if (json.containsKey("verb")) {
      verb = json["verb"];
    }
  }

  /** Create JSON Object for CommentReply */
  Map toJson() {
    var output = new Map();

    if (author != null) {
      output["author"] = author.toJson();
    }
    if (content != null) {
      output["content"] = content;
    }
    if (createdDate != null) {
      output["createdDate"] = createdDate;
    }
    if (deleted != null) {
      output["deleted"] = deleted;
    }
    if (htmlContent != null) {
      output["htmlContent"] = htmlContent;
    }
    if (kind != null) {
      output["kind"] = kind;
    }
    if (modifiedDate != null) {
      output["modifiedDate"] = modifiedDate;
    }
    if (replyId != null) {
      output["replyId"] = replyId;
    }
    if (verb != null) {
      output["verb"] = verb;
    }

    return output;
  }

  /** Return String representation of CommentReply */
  String toString() => JSON.stringify(this.toJson());

}

/** A JSON representation of a list of replies to a comment on a file in Google Drive. */
class CommentReplyList {

  /** List of reply. */
  List<CommentReply> items;

  /** This is always drive#commentReplyList. */
  String kind;

  /** The token to use to request the next page of results. */
  String nextPageToken;

  /** Create new CommentReplyList from JSON data */
  CommentReplyList.fromJson(Map json) {
    if (json.containsKey("items")) {
      items = [];
      json["items"].forEach((item) {
        items.add(new CommentReply.fromJson(item));
      });
    }
    if (json.containsKey("kind")) {
      kind = json["kind"];
    }
    if (json.containsKey("nextPageToken")) {
      nextPageToken = json["nextPageToken"];
    }
  }

  /** Create JSON Object for CommentReplyList */
  Map toJson() {
    var output = new Map();

    if (items != null) {
      output["items"] = new List();
      items.forEach((item) {
        output["items"].add(item.toJson());
      });
    }
    if (kind != null) {
      output["kind"] = kind;
    }
    if (nextPageToken != null) {
      output["nextPageToken"] = nextPageToken;
    }

    return output;
  }

  /** Return String representation of CommentReplyList */
  String toString() => JSON.stringify(this.toJson());

}

/** The metadata for a file. */
class File {

  /** A link for opening the file in using a relevant Google editor or viewer. */
  String alternateLink;

  /** Whether this file is in the appdata folder. */
  bool appDataContents;

  /** Create time for this file (formatted ISO8601 timestamp). */
  String createdDate;

  /** A short description of the file. */
  String description;

  /** Short term download URL for the file. This will only be populated on files with content stored in Drive. */
  String downloadUrl;

  /** Whether the file can be edited by the current user. */
  bool editable;

  /** A link for embedding the file. */
  String embedLink;

  /** ETag of the file. */
  String etag;

  /** Whether this file has been explicitly trashed, as opposed to recursively trashed. This will only be populated if the file is trashed. */
  bool explicitlyTrashed;

  /** Links for exporting Google Docs to specific formats. */
  FileExportLinks exportLinks;

  /** The file extension used when downloading this file. This field is set from the title when inserting or uploading new content. This will only be populated on files with content stored in Drive. */
  String fileExtension;

  /** The size of the file in bytes. This will only be populated on files with content stored in Drive. */
  String fileSize;

  /** A link to the file's icon. */
  String iconLink;

  /** The id of the file. */
  String id;

  /** Metadata about image media. This will only be present for image types, and its contents will depend on what can be parsed from the image content. */
  FileImageMediaMetadata imageMediaMetadata;

  /** Indexable text attributes for the file (can only be written) */
  FileIndexableText indexableText;

  /** The type of file. This is always drive#file. */
  String kind;

  /** A group of labels for the file. */
  FileLabels labels;

  /** Name of the last user to modify this file. This will only be populated if a user has edited this file. */
  String lastModifyingUserName;

  /** Last time this file was viewed by the user (formatted RFC 3339 timestamp). */
  String lastViewedByMeDate;

  /** An MD5 checksum for the content of this file. This will only be populated on files with content stored in Drive. */
  String md5Checksum;

  /** The MIME type of the file. This is only mutable on update when uploading new content. This field can be left blank, and the mimetype will be determined from the uploaded content's MIME type. */
  String mimeType;

  /** Last time this file was modified by the user (formatted RFC 3339 timestamp). Note that setting modifiedDate will also update the modifiedByMe date for the user which set the date. */
  String modifiedByMeDate;

  /** Last time this file was modified by anyone (formatted RFC 3339 timestamp). This is only mutable on update when the setModifiedDate parameter is set. */
  String modifiedDate;

  /** The original filename if the file was uploaded manually, or the original title if the file was inserted through the API. Note that renames of the title will not change the original filename. This will only be populated on files with content stored in Drive. */
  String originalFilename;

  /** Name(s) of the owner(s) of this file. */
  List<String> ownerNames;

  /** Collection of parent folders which contain this file.
Setting this field will put the file in all of the provided folders. On insert, if no folders are provided, the file will be placed in the default root folder. */
  List<ParentReference> parents;

  /** The number of quota bytes used by this file. */
  String quotaBytesUsed;

  /** A link back to this file. */
  String selfLink;

  /** Whether the file has been shared. */
  bool shared;

  /** Time at which this file was shared with the user (formatted RFC 3339 timestamp). */
  String sharedWithMeDate;

  /** Thumbnail for the file. Only accepted on upload and for files that are not already thumbnailed by Google. */
  FileThumbnail thumbnail;

  /** A link to the file's thumbnail. */
  String thumbnailLink;

  /** The title of this file. */
  String title;
  Permission userPermission;

  /** A link for downloading the content of the file in a browser using cookie based authentication. In cases where the content is shared publicly, the content can be downloaded without any credentials. */
  String webContentLink;

  /** A link only available on public folders for viewing their static web assets (HTML, CSS, JS, etc) via Google Drive's Website Hosting. */
  String webViewLink;

  /** Whether writers can share the document with other users. */
  bool writersCanShare;

  /** Create new File from JSON data */
  File.fromJson(Map json) {
    if (json.containsKey("alternateLink")) {
      alternateLink = json["alternateLink"];
    }
    if (json.containsKey("appDataContents")) {
      appDataContents = json["appDataContents"];
    }
    if (json.containsKey("createdDate")) {
      createdDate = json["createdDate"];
    }
    if (json.containsKey("description")) {
      description = json["description"];
    }
    if (json.containsKey("downloadUrl")) {
      downloadUrl = json["downloadUrl"];
    }
    if (json.containsKey("editable")) {
      editable = json["editable"];
    }
    if (json.containsKey("embedLink")) {
      embedLink = json["embedLink"];
    }
    if (json.containsKey("etag")) {
      etag = json["etag"];
    }
    if (json.containsKey("explicitlyTrashed")) {
      explicitlyTrashed = json["explicitlyTrashed"];
    }
    if (json.containsKey("exportLinks")) {
      exportLinks = new FileExportLinks.fromJson(json["exportLinks"]);
    }
    if (json.containsKey("fileExtension")) {
      fileExtension = json["fileExtension"];
    }
    if (json.containsKey("fileSize")) {
      fileSize = json["fileSize"];
    }
    if (json.containsKey("iconLink")) {
      iconLink = json["iconLink"];
    }
    if (json.containsKey("id")) {
      id = json["id"];
    }
    if (json.containsKey("imageMediaMetadata")) {
      imageMediaMetadata = new FileImageMediaMetadata.fromJson(json["imageMediaMetadata"]);
    }
    if (json.containsKey("indexableText")) {
      indexableText = new FileIndexableText.fromJson(json["indexableText"]);
    }
    if (json.containsKey("kind")) {
      kind = json["kind"];
    }
    if (json.containsKey("labels")) {
      labels = new FileLabels.fromJson(json["labels"]);
    }
    if (json.containsKey("lastModifyingUserName")) {
      lastModifyingUserName = json["lastModifyingUserName"];
    }
    if (json.containsKey("lastViewedByMeDate")) {
      lastViewedByMeDate = json["lastViewedByMeDate"];
    }
    if (json.containsKey("md5Checksum")) {
      md5Checksum = json["md5Checksum"];
    }
    if (json.containsKey("mimeType")) {
      mimeType = json["mimeType"];
    }
    if (json.containsKey("modifiedByMeDate")) {
      modifiedByMeDate = json["modifiedByMeDate"];
    }
    if (json.containsKey("modifiedDate")) {
      modifiedDate = json["modifiedDate"];
    }
    if (json.containsKey("originalFilename")) {
      originalFilename = json["originalFilename"];
    }
    if (json.containsKey("ownerNames")) {
      ownerNames = [];
      json["ownerNames"].forEach((item) {
        ownerNames.add(item);
      });
    }
    if (json.containsKey("parents")) {
      parents = [];
      json["parents"].forEach((item) {
        parents.add(new ParentReference.fromJson(item));
      });
    }
    if (json.containsKey("quotaBytesUsed")) {
      quotaBytesUsed = json["quotaBytesUsed"];
    }
    if (json.containsKey("selfLink")) {
      selfLink = json["selfLink"];
    }
    if (json.containsKey("shared")) {
      shared = json["shared"];
    }
    if (json.containsKey("sharedWithMeDate")) {
      sharedWithMeDate = json["sharedWithMeDate"];
    }
    if (json.containsKey("thumbnail")) {
      thumbnail = new FileThumbnail.fromJson(json["thumbnail"]);
    }
    if (json.containsKey("thumbnailLink")) {
      thumbnailLink = json["thumbnailLink"];
    }
    if (json.containsKey("title")) {
      title = json["title"];
    }
    if (json.containsKey("userPermission")) {
      userPermission = new Permission.fromJson(json["userPermission"]);
    }
    if (json.containsKey("webContentLink")) {
      webContentLink = json["webContentLink"];
    }
    if (json.containsKey("webViewLink")) {
      webViewLink = json["webViewLink"];
    }
    if (json.containsKey("writersCanShare")) {
      writersCanShare = json["writersCanShare"];
    }
  }

  /** Create JSON Object for File */
  Map toJson() {
    var output = new Map();

    if (alternateLink != null) {
      output["alternateLink"] = alternateLink;
    }
    if (appDataContents != null) {
      output["appDataContents"] = appDataContents;
    }
    if (createdDate != null) {
      output["createdDate"] = createdDate;
    }
    if (description != null) {
      output["description"] = description;
    }
    if (downloadUrl != null) {
      output["downloadUrl"] = downloadUrl;
    }
    if (editable != null) {
      output["editable"] = editable;
    }
    if (embedLink != null) {
      output["embedLink"] = embedLink;
    }
    if (etag != null) {
      output["etag"] = etag;
    }
    if (explicitlyTrashed != null) {
      output["explicitlyTrashed"] = explicitlyTrashed;
    }
    if (exportLinks != null) {
      output["exportLinks"] = exportLinks.toJson();
    }
    if (fileExtension != null) {
      output["fileExtension"] = fileExtension;
    }
    if (fileSize != null) {
      output["fileSize"] = fileSize;
    }
    if (iconLink != null) {
      output["iconLink"] = iconLink;
    }
    if (id != null) {
      output["id"] = id;
    }
    if (imageMediaMetadata != null) {
      output["imageMediaMetadata"] = imageMediaMetadata.toJson();
    }
    if (indexableText != null) {
      output["indexableText"] = indexableText.toJson();
    }
    if (kind != null) {
      output["kind"] = kind;
    }
    if (labels != null) {
      output["labels"] = labels.toJson();
    }
    if (lastModifyingUserName != null) {
      output["lastModifyingUserName"] = lastModifyingUserName;
    }
    if (lastViewedByMeDate != null) {
      output["lastViewedByMeDate"] = lastViewedByMeDate;
    }
    if (md5Checksum != null) {
      output["md5Checksum"] = md5Checksum;
    }
    if (mimeType != null) {
      output["mimeType"] = mimeType;
    }
    if (modifiedByMeDate != null) {
      output["modifiedByMeDate"] = modifiedByMeDate;
    }
    if (modifiedDate != null) {
      output["modifiedDate"] = modifiedDate;
    }
    if (originalFilename != null) {
      output["originalFilename"] = originalFilename;
    }
    if (ownerNames != null) {
      output["ownerNames"] = new List();
      ownerNames.forEach((item) {
        output["ownerNames"].add(item);
      });
    }
    if (parents != null) {
      output["parents"] = new List();
      parents.forEach((item) {
        output["parents"].add(item.toJson());
      });
    }
    if (quotaBytesUsed != null) {
      output["quotaBytesUsed"] = quotaBytesUsed;
    }
    if (selfLink != null) {
      output["selfLink"] = selfLink;
    }
    if (shared != null) {
      output["shared"] = shared;
    }
    if (sharedWithMeDate != null) {
      output["sharedWithMeDate"] = sharedWithMeDate;
    }
    if (thumbnail != null) {
      output["thumbnail"] = thumbnail.toJson();
    }
    if (thumbnailLink != null) {
      output["thumbnailLink"] = thumbnailLink;
    }
    if (title != null) {
      output["title"] = title;
    }
    if (userPermission != null) {
      output["userPermission"] = userPermission.toJson();
    }
    if (webContentLink != null) {
      output["webContentLink"] = webContentLink;
    }
    if (webViewLink != null) {
      output["webViewLink"] = webViewLink;
    }
    if (writersCanShare != null) {
      output["writersCanShare"] = writersCanShare;
    }

    return output;
  }

  /** Return String representation of File */
  String toString() => JSON.stringify(this.toJson());

}

/** Links for exporting Google Docs to specific formats. */
class FileExportLinks {

  /** Create new FileExportLinks from JSON data */
  FileExportLinks.fromJson(Map json) {
  }

  /** Create JSON Object for FileExportLinks */
  Map toJson() {
    var output = new Map();


    return output;
  }

  /** Return String representation of FileExportLinks */
  String toString() => JSON.stringify(this.toJson());

}

/** Thumbnail for the file. Only accepted on upload and for files that are not already thumbnailed by Google. */
class FileThumbnail {

  /** The URL-safe Base64 encoded bytes of the thumbnail image. */
  String image;

  /** The MIME type of the thumbnail. */
  String mimeType;

  /** Create new FileThumbnail from JSON data */
  FileThumbnail.fromJson(Map json) {
    if (json.containsKey("image")) {
      image = json["image"];
    }
    if (json.containsKey("mimeType")) {
      mimeType = json["mimeType"];
    }
  }

  /** Create JSON Object for FileThumbnail */
  Map toJson() {
    var output = new Map();

    if (image != null) {
      output["image"] = image;
    }
    if (mimeType != null) {
      output["mimeType"] = mimeType;
    }

    return output;
  }

  /** Return String representation of FileThumbnail */
  String toString() => JSON.stringify(this.toJson());

}

/** A group of labels for the file. */
class FileLabels {

  /** Whether this file is hidden from the user. */
  bool hidden;

  /** Whether viewers are prevented from downloading this file. */
  bool restricted;

  /** Whether this file is starred by the user. */
  bool starred;

  /** Whether this file has been trashed. */
  bool trashed;

  /** Whether this file has been viewed by this user. */
  bool viewed;

  /** Create new FileLabels from JSON data */
  FileLabels.fromJson(Map json) {
    if (json.containsKey("hidden")) {
      hidden = json["hidden"];
    }
    if (json.containsKey("restricted")) {
      restricted = json["restricted"];
    }
    if (json.containsKey("starred")) {
      starred = json["starred"];
    }
    if (json.containsKey("trashed")) {
      trashed = json["trashed"];
    }
    if (json.containsKey("viewed")) {
      viewed = json["viewed"];
    }
  }

  /** Create JSON Object for FileLabels */
  Map toJson() {
    var output = new Map();

    if (hidden != null) {
      output["hidden"] = hidden;
    }
    if (restricted != null) {
      output["restricted"] = restricted;
    }
    if (starred != null) {
      output["starred"] = starred;
    }
    if (trashed != null) {
      output["trashed"] = trashed;
    }
    if (viewed != null) {
      output["viewed"] = viewed;
    }

    return output;
  }

  /** Return String representation of FileLabels */
  String toString() => JSON.stringify(this.toJson());

}

/** Indexable text attributes for the file (can only be written) */
class FileIndexableText {

  /** The text to be indexed for this file */
  String text;

  /** Create new FileIndexableText from JSON data */
  FileIndexableText.fromJson(Map json) {
    if (json.containsKey("text")) {
      text = json["text"];
    }
  }

  /** Create JSON Object for FileIndexableText */
  Map toJson() {
    var output = new Map();

    if (text != null) {
      output["text"] = text;
    }

    return output;
  }

  /** Return String representation of FileIndexableText */
  String toString() => JSON.stringify(this.toJson());

}

/** Metadata about image media. This will only be present for image types, and its contents will depend on what can be parsed from the image content. */
class FileImageMediaMetadata {

  /** The aperture used to create the photo (f-number). */
  num aperture;

  /** The make of the camera used to create the photo. */
  String cameraMake;

  /** The model of the camera used to create the photo. */
  String cameraModel;

  /** The color space of the photo. */
  String colorSpace;

  /** The date and time the photo was taken (EXIF format timestamp). */
  String date;

  /** The exposure bias of the photo (APEX value). */
  num exposureBias;

  /** The exposure mode used to create the photo. */
  String exposureMode;

  /** The length of the exposure, in seconds. */
  num exposureTime;

  /** Whether a flash was used to create the photo. */
  bool flashUsed;

  /** The focal length used to create the photo, in millimeters. */
  num focalLength;

  /** The height of the image in pixels. */
  int height;

  /** The ISO speed used to create the photo. */
  int isoSpeed;

  /** The lens used to create the photo. */
  String lens;

  /** Geographic location information stored in the image. */
  FileImageMediaMetadataLocation location;

  /** The smallest f-number of the lens at the focal length used to create the photo (APEX value). */
  num maxApertureValue;

  /** The metering mode used to create the photo. */
  String meteringMode;

  /** The rotation in clockwise degrees from the image's original orientation. */
  int rotation;

  /** The type of sensor used to create the photo. */
  String sensor;

  /** The distance to the subject of the photo, in meters. */
  int subjectDistance;

  /** The white balance mode used to create the photo. */
  String whiteBalance;

  /** The width of the image in pixels. */
  int width;

  /** Create new FileImageMediaMetadata from JSON data */
  FileImageMediaMetadata.fromJson(Map json) {
    if (json.containsKey("aperture")) {
      aperture = json["aperture"];
    }
    if (json.containsKey("cameraMake")) {
      cameraMake = json["cameraMake"];
    }
    if (json.containsKey("cameraModel")) {
      cameraModel = json["cameraModel"];
    }
    if (json.containsKey("colorSpace")) {
      colorSpace = json["colorSpace"];
    }
    if (json.containsKey("date")) {
      date = json["date"];
    }
    if (json.containsKey("exposureBias")) {
      exposureBias = json["exposureBias"];
    }
    if (json.containsKey("exposureMode")) {
      exposureMode = json["exposureMode"];
    }
    if (json.containsKey("exposureTime")) {
      exposureTime = json["exposureTime"];
    }
    if (json.containsKey("flashUsed")) {
      flashUsed = json["flashUsed"];
    }
    if (json.containsKey("focalLength")) {
      focalLength = json["focalLength"];
    }
    if (json.containsKey("height")) {
      height = json["height"];
    }
    if (json.containsKey("isoSpeed")) {
      isoSpeed = json["isoSpeed"];
    }
    if (json.containsKey("lens")) {
      lens = json["lens"];
    }
    if (json.containsKey("location")) {
      location = new FileImageMediaMetadataLocation.fromJson(json["location"]);
    }
    if (json.containsKey("maxApertureValue")) {
      maxApertureValue = json["maxApertureValue"];
    }
    if (json.containsKey("meteringMode")) {
      meteringMode = json["meteringMode"];
    }
    if (json.containsKey("rotation")) {
      rotation = json["rotation"];
    }
    if (json.containsKey("sensor")) {
      sensor = json["sensor"];
    }
    if (json.containsKey("subjectDistance")) {
      subjectDistance = json["subjectDistance"];
    }
    if (json.containsKey("whiteBalance")) {
      whiteBalance = json["whiteBalance"];
    }
    if (json.containsKey("width")) {
      width = json["width"];
    }
  }

  /** Create JSON Object for FileImageMediaMetadata */
  Map toJson() {
    var output = new Map();

    if (aperture != null) {
      output["aperture"] = aperture;
    }
    if (cameraMake != null) {
      output["cameraMake"] = cameraMake;
    }
    if (cameraModel != null) {
      output["cameraModel"] = cameraModel;
    }
    if (colorSpace != null) {
      output["colorSpace"] = colorSpace;
    }
    if (date != null) {
      output["date"] = date;
    }
    if (exposureBias != null) {
      output["exposureBias"] = exposureBias;
    }
    if (exposureMode != null) {
      output["exposureMode"] = exposureMode;
    }
    if (exposureTime != null) {
      output["exposureTime"] = exposureTime;
    }
    if (flashUsed != null) {
      output["flashUsed"] = flashUsed;
    }
    if (focalLength != null) {
      output["focalLength"] = focalLength;
    }
    if (height != null) {
      output["height"] = height;
    }
    if (isoSpeed != null) {
      output["isoSpeed"] = isoSpeed;
    }
    if (lens != null) {
      output["lens"] = lens;
    }
    if (location != null) {
      output["location"] = location.toJson();
    }
    if (maxApertureValue != null) {
      output["maxApertureValue"] = maxApertureValue;
    }
    if (meteringMode != null) {
      output["meteringMode"] = meteringMode;
    }
    if (rotation != null) {
      output["rotation"] = rotation;
    }
    if (sensor != null) {
      output["sensor"] = sensor;
    }
    if (subjectDistance != null) {
      output["subjectDistance"] = subjectDistance;
    }
    if (whiteBalance != null) {
      output["whiteBalance"] = whiteBalance;
    }
    if (width != null) {
      output["width"] = width;
    }

    return output;
  }

  /** Return String representation of FileImageMediaMetadata */
  String toString() => JSON.stringify(this.toJson());

}

/** Geographic location information stored in the image. */
class FileImageMediaMetadataLocation {

  /** The altitude stored in the image. */
  num altitude;

  /** The latitude stored in the image. */
  num latitude;

  /** The longitude stored in the image. */
  num longitude;

  /** Create new FileImageMediaMetadataLocation from JSON data */
  FileImageMediaMetadataLocation.fromJson(Map json) {
    if (json.containsKey("altitude")) {
      altitude = json["altitude"];
    }
    if (json.containsKey("latitude")) {
      latitude = json["latitude"];
    }
    if (json.containsKey("longitude")) {
      longitude = json["longitude"];
    }
  }

  /** Create JSON Object for FileImageMediaMetadataLocation */
  Map toJson() {
    var output = new Map();

    if (altitude != null) {
      output["altitude"] = altitude;
    }
    if (latitude != null) {
      output["latitude"] = latitude;
    }
    if (longitude != null) {
      output["longitude"] = longitude;
    }

    return output;
  }

  /** Return String representation of FileImageMediaMetadataLocation */
  String toString() => JSON.stringify(this.toJson());

}

/** A list of files. */
class FileList {

  /** The ETag of the list. */
  String etag;

  /** The actual list of files. */
  List<File> items;

  /** This is always drive#fileList. */
  String kind;

  /** A link to the next page of files. */
  String nextLink;

  /** The page token for the next page of files. */
  String nextPageToken;

  /** A link back to this list. */
  String selfLink;

  /** Create new FileList from JSON data */
  FileList.fromJson(Map json) {
    if (json.containsKey("etag")) {
      etag = json["etag"];
    }
    if (json.containsKey("items")) {
      items = [];
      json["items"].forEach((item) {
        items.add(new File.fromJson(item));
      });
    }
    if (json.containsKey("kind")) {
      kind = json["kind"];
    }
    if (json.containsKey("nextLink")) {
      nextLink = json["nextLink"];
    }
    if (json.containsKey("nextPageToken")) {
      nextPageToken = json["nextPageToken"];
    }
    if (json.containsKey("selfLink")) {
      selfLink = json["selfLink"];
    }
  }

  /** Create JSON Object for FileList */
  Map toJson() {
    var output = new Map();

    if (etag != null) {
      output["etag"] = etag;
    }
    if (items != null) {
      output["items"] = new List();
      items.forEach((item) {
        output["items"].add(item.toJson());
      });
    }
    if (kind != null) {
      output["kind"] = kind;
    }
    if (nextLink != null) {
      output["nextLink"] = nextLink;
    }
    if (nextPageToken != null) {
      output["nextPageToken"] = nextPageToken;
    }
    if (selfLink != null) {
      output["selfLink"] = selfLink;
    }

    return output;
  }

  /** Return String representation of FileList */
  String toString() => JSON.stringify(this.toJson());

}

/** A list of a file's parents. */
class ParentList {

  /** The ETag of the list. */
  String etag;

  /** The actual list of parents. */
  List<ParentReference> items;

  /** This is always drive#parentList. */
  String kind;

  /** A link back to this list. */
  String selfLink;

  /** Create new ParentList from JSON data */
  ParentList.fromJson(Map json) {
    if (json.containsKey("etag")) {
      etag = json["etag"];
    }
    if (json.containsKey("items")) {
      items = [];
      json["items"].forEach((item) {
        items.add(new ParentReference.fromJson(item));
      });
    }
    if (json.containsKey("kind")) {
      kind = json["kind"];
    }
    if (json.containsKey("selfLink")) {
      selfLink = json["selfLink"];
    }
  }

  /** Create JSON Object for ParentList */
  Map toJson() {
    var output = new Map();

    if (etag != null) {
      output["etag"] = etag;
    }
    if (items != null) {
      output["items"] = new List();
      items.forEach((item) {
        output["items"].add(item.toJson());
      });
    }
    if (kind != null) {
      output["kind"] = kind;
    }
    if (selfLink != null) {
      output["selfLink"] = selfLink;
    }

    return output;
  }

  /** Return String representation of ParentList */
  String toString() => JSON.stringify(this.toJson());

}

/** A reference to a file's parent. */
class ParentReference {

  /** The ID of the parent. */
  String id;

  /** Whether or not the parent is the root folder. */
  bool isRoot;

  /** This is always drive#parentReference. */
  String kind;

  /** A link to the parent. */
  String parentLink;

  /** A link back to this reference. */
  String selfLink;

  /** Create new ParentReference from JSON data */
  ParentReference.fromJson(Map json) {
    if (json.containsKey("id")) {
      id = json["id"];
    }
    if (json.containsKey("isRoot")) {
      isRoot = json["isRoot"];
    }
    if (json.containsKey("kind")) {
      kind = json["kind"];
    }
    if (json.containsKey("parentLink")) {
      parentLink = json["parentLink"];
    }
    if (json.containsKey("selfLink")) {
      selfLink = json["selfLink"];
    }
  }

  /** Create JSON Object for ParentReference */
  Map toJson() {
    var output = new Map();

    if (id != null) {
      output["id"] = id;
    }
    if (isRoot != null) {
      output["isRoot"] = isRoot;
    }
    if (kind != null) {
      output["kind"] = kind;
    }
    if (parentLink != null) {
      output["parentLink"] = parentLink;
    }
    if (selfLink != null) {
      output["selfLink"] = selfLink;
    }

    return output;
  }

  /** Return String representation of ParentReference */
  String toString() => JSON.stringify(this.toJson());

}

/** A single permission for a file. */
class Permission {

  /** Additional roles for this user. Only commenter is currently allowed. */
  List<String> additionalRoles;

  /** The authkey parameter required for this permission. */
  String authKey;

  /** The ETag of the permission. */
  String etag;

  /** The ID of the permission. */
  String id;

  /** This is always drive#permission. */
  String kind;

  /** The name for this permission. */
  String name;

  /** A link to the profile photo, if available. */
  String photoLink;

  /** The primary role for this user. Allowed values are:  
- owner 
- reader 
- writer */
  String role;

  /** A link back to this permission. */
  String selfLink;

  /** The account type. Allowed values are:  
- user 
- group 
- domain 
- anyone */
  String type;

  /** The email address or domain name for the entity. This is not populated in responses. */
  String value;

  /** Whether the link is required for this permission. */
  bool withLink;

  /** Create new Permission from JSON data */
  Permission.fromJson(Map json) {
    if (json.containsKey("additionalRoles")) {
      additionalRoles = [];
      json["additionalRoles"].forEach((item) {
        additionalRoles.add(item);
      });
    }
    if (json.containsKey("authKey")) {
      authKey = json["authKey"];
    }
    if (json.containsKey("etag")) {
      etag = json["etag"];
    }
    if (json.containsKey("id")) {
      id = json["id"];
    }
    if (json.containsKey("kind")) {
      kind = json["kind"];
    }
    if (json.containsKey("name")) {
      name = json["name"];
    }
    if (json.containsKey("photoLink")) {
      photoLink = json["photoLink"];
    }
    if (json.containsKey("role")) {
      role = json["role"];
    }
    if (json.containsKey("selfLink")) {
      selfLink = json["selfLink"];
    }
    if (json.containsKey("type")) {
      type = json["type"];
    }
    if (json.containsKey("value")) {
      value = json["value"];
    }
    if (json.containsKey("withLink")) {
      withLink = json["withLink"];
    }
  }

  /** Create JSON Object for Permission */
  Map toJson() {
    var output = new Map();

    if (additionalRoles != null) {
      output["additionalRoles"] = new List();
      additionalRoles.forEach((item) {
        output["additionalRoles"].add(item);
      });
    }
    if (authKey != null) {
      output["authKey"] = authKey;
    }
    if (etag != null) {
      output["etag"] = etag;
    }
    if (id != null) {
      output["id"] = id;
    }
    if (kind != null) {
      output["kind"] = kind;
    }
    if (name != null) {
      output["name"] = name;
    }
    if (photoLink != null) {
      output["photoLink"] = photoLink;
    }
    if (role != null) {
      output["role"] = role;
    }
    if (selfLink != null) {
      output["selfLink"] = selfLink;
    }
    if (type != null) {
      output["type"] = type;
    }
    if (value != null) {
      output["value"] = value;
    }
    if (withLink != null) {
      output["withLink"] = withLink;
    }

    return output;
  }

  /** Return String representation of Permission */
  String toString() => JSON.stringify(this.toJson());

}

/** A list of permissions associated with a file. */
class PermissionList {

  /** The ETag of the list. */
  String etag;

  /** The actual list of permissions. */
  List<Permission> items;

  /** This is always drive#permissionList. */
  String kind;

  /** A link back to this list. */
  String selfLink;

  /** Create new PermissionList from JSON data */
  PermissionList.fromJson(Map json) {
    if (json.containsKey("etag")) {
      etag = json["etag"];
    }
    if (json.containsKey("items")) {
      items = [];
      json["items"].forEach((item) {
        items.add(new Permission.fromJson(item));
      });
    }
    if (json.containsKey("kind")) {
      kind = json["kind"];
    }
    if (json.containsKey("selfLink")) {
      selfLink = json["selfLink"];
    }
  }

  /** Create JSON Object for PermissionList */
  Map toJson() {
    var output = new Map();

    if (etag != null) {
      output["etag"] = etag;
    }
    if (items != null) {
      output["items"] = new List();
      items.forEach((item) {
        output["items"].add(item.toJson());
      });
    }
    if (kind != null) {
      output["kind"] = kind;
    }
    if (selfLink != null) {
      output["selfLink"] = selfLink;
    }

    return output;
  }

  /** Return String representation of PermissionList */
  String toString() => JSON.stringify(this.toJson());

}

/** A single revision of a file. */
class Revision {

  /** Short term download URL for the file. This will only be populated on files with content stored in Drive. */
  String downloadUrl;

  /** The ETag of the revision. */
  String etag;

  /** Links for exporting Google Docs to specific formats. */
  RevisionExportLinks exportLinks;

  /** The size of the revision in bytes. This will only be populated on files with content stored in Drive. */
  String fileSize;

  /** The ID of the revision. */
  String id;

  /** This is always drive#revision. */
  String kind;

  /** Name of the last user to modify this revision. */
  String lastModifyingUserName;

  /** An MD5 checksum for the content of this revision. This will only be populated on files with content stored in Drive. */
  String md5Checksum;

  /** The MIME type of the revision. */
  String mimeType;

  /** Last time this revision was modified (formatted RFC 3339 timestamp). */
  String modifiedDate;

  /** The original filename when this revision was created. This will only be populated on files with content stored in Drive. */
  String originalFilename;

  /** Whether this revision is pinned to prevent automatic purging. This will only be populated and can only be modified on files with content stored in Drive which are not Google Docs. Revisions can also be pinned when they are created through the drive.files.insert/update/copy by using the pinned query parameter. */
  bool pinned;

  /** Whether subsequent revisions will be automatically republished. This is only populated and can only be modified for Google Docs. */
  bool publishAuto;

  /** Whether this revision is published. This is only populated and can only be modified for Google Docs. */
  bool published;

  /** A link to the published revision. */
  String publishedLink;

  /** Whether this revision is published outside the domain. This is only populated and can only be modified for Google Docs. */
  bool publishedOutsideDomain;

  /** A link back to this revision. */
  String selfLink;

  /** Create new Revision from JSON data */
  Revision.fromJson(Map json) {
    if (json.containsKey("downloadUrl")) {
      downloadUrl = json["downloadUrl"];
    }
    if (json.containsKey("etag")) {
      etag = json["etag"];
    }
    if (json.containsKey("exportLinks")) {
      exportLinks = new RevisionExportLinks.fromJson(json["exportLinks"]);
    }
    if (json.containsKey("fileSize")) {
      fileSize = json["fileSize"];
    }
    if (json.containsKey("id")) {
      id = json["id"];
    }
    if (json.containsKey("kind")) {
      kind = json["kind"];
    }
    if (json.containsKey("lastModifyingUserName")) {
      lastModifyingUserName = json["lastModifyingUserName"];
    }
    if (json.containsKey("md5Checksum")) {
      md5Checksum = json["md5Checksum"];
    }
    if (json.containsKey("mimeType")) {
      mimeType = json["mimeType"];
    }
    if (json.containsKey("modifiedDate")) {
      modifiedDate = json["modifiedDate"];
    }
    if (json.containsKey("originalFilename")) {
      originalFilename = json["originalFilename"];
    }
    if (json.containsKey("pinned")) {
      pinned = json["pinned"];
    }
    if (json.containsKey("publishAuto")) {
      publishAuto = json["publishAuto"];
    }
    if (json.containsKey("published")) {
      published = json["published"];
    }
    if (json.containsKey("publishedLink")) {
      publishedLink = json["publishedLink"];
    }
    if (json.containsKey("publishedOutsideDomain")) {
      publishedOutsideDomain = json["publishedOutsideDomain"];
    }
    if (json.containsKey("selfLink")) {
      selfLink = json["selfLink"];
    }
  }

  /** Create JSON Object for Revision */
  Map toJson() {
    var output = new Map();

    if (downloadUrl != null) {
      output["downloadUrl"] = downloadUrl;
    }
    if (etag != null) {
      output["etag"] = etag;
    }
    if (exportLinks != null) {
      output["exportLinks"] = exportLinks.toJson();
    }
    if (fileSize != null) {
      output["fileSize"] = fileSize;
    }
    if (id != null) {
      output["id"] = id;
    }
    if (kind != null) {
      output["kind"] = kind;
    }
    if (lastModifyingUserName != null) {
      output["lastModifyingUserName"] = lastModifyingUserName;
    }
    if (md5Checksum != null) {
      output["md5Checksum"] = md5Checksum;
    }
    if (mimeType != null) {
      output["mimeType"] = mimeType;
    }
    if (modifiedDate != null) {
      output["modifiedDate"] = modifiedDate;
    }
    if (originalFilename != null) {
      output["originalFilename"] = originalFilename;
    }
    if (pinned != null) {
      output["pinned"] = pinned;
    }
    if (publishAuto != null) {
      output["publishAuto"] = publishAuto;
    }
    if (published != null) {
      output["published"] = published;
    }
    if (publishedLink != null) {
      output["publishedLink"] = publishedLink;
    }
    if (publishedOutsideDomain != null) {
      output["publishedOutsideDomain"] = publishedOutsideDomain;
    }
    if (selfLink != null) {
      output["selfLink"] = selfLink;
    }

    return output;
  }

  /** Return String representation of Revision */
  String toString() => JSON.stringify(this.toJson());

}

/** Links for exporting Google Docs to specific formats. */
class RevisionExportLinks {

  /** Create new RevisionExportLinks from JSON data */
  RevisionExportLinks.fromJson(Map json) {
  }

  /** Create JSON Object for RevisionExportLinks */
  Map toJson() {
    var output = new Map();


    return output;
  }

  /** Return String representation of RevisionExportLinks */
  String toString() => JSON.stringify(this.toJson());

}

/** A list of revisions of a file. */
class RevisionList {

  /** The ETag of the list. */
  String etag;

  /** The actual list of revisions. */
  List<Revision> items;

  /** This is always drive#revisionList. */
  String kind;

  /** A link back to this list. */
  String selfLink;

  /** Create new RevisionList from JSON data */
  RevisionList.fromJson(Map json) {
    if (json.containsKey("etag")) {
      etag = json["etag"];
    }
    if (json.containsKey("items")) {
      items = [];
      json["items"].forEach((item) {
        items.add(new Revision.fromJson(item));
      });
    }
    if (json.containsKey("kind")) {
      kind = json["kind"];
    }
    if (json.containsKey("selfLink")) {
      selfLink = json["selfLink"];
    }
  }

  /** Create JSON Object for RevisionList */
  Map toJson() {
    var output = new Map();

    if (etag != null) {
      output["etag"] = etag;
    }
    if (items != null) {
      output["items"] = new List();
      items.forEach((item) {
        output["items"].add(item.toJson());
      });
    }
    if (kind != null) {
      output["kind"] = kind;
    }
    if (selfLink != null) {
      output["selfLink"] = selfLink;
    }

    return output;
  }

  /** Return String representation of RevisionList */
  String toString() => JSON.stringify(this.toJson());

}

/** The JSON template for a user. */
class User {

  /** A plain text displayable name for this user. */
  String displayName;

  /** Whether this user is the same as the authenticated user of which the request was made on behalf. */
  bool isAuthenticatedUser;

  /** This is always drive#user. */
  String kind;

  /** The user's profile picture. */
  UserPicture picture;

  /** Create new User from JSON data */
  User.fromJson(Map json) {
    if (json.containsKey("displayName")) {
      displayName = json["displayName"];
    }
    if (json.containsKey("isAuthenticatedUser")) {
      isAuthenticatedUser = json["isAuthenticatedUser"];
    }
    if (json.containsKey("kind")) {
      kind = json["kind"];
    }
    if (json.containsKey("picture")) {
      picture = new UserPicture.fromJson(json["picture"]);
    }
  }

  /** Create JSON Object for User */
  Map toJson() {
    var output = new Map();

    if (displayName != null) {
      output["displayName"] = displayName;
    }
    if (isAuthenticatedUser != null) {
      output["isAuthenticatedUser"] = isAuthenticatedUser;
    }
    if (kind != null) {
      output["kind"] = kind;
    }
    if (picture != null) {
      output["picture"] = picture.toJson();
    }

    return output;
  }

  /** Return String representation of User */
  String toString() => JSON.stringify(this.toJson());

}

/** The user's profile picture. */
class UserPicture {

  /** A URL that points to a profile picture of this user. */
  String url;

  /** Create new UserPicture from JSON data */
  UserPicture.fromJson(Map json) {
    if (json.containsKey("url")) {
      url = json["url"];
    }
  }

  /** Create JSON Object for UserPicture */
  Map toJson() {
    var output = new Map();

    if (url != null) {
      output["url"] = url;
    }

    return output;
  }

  /** Return String representation of UserPicture */
  String toString() => JSON.stringify(this.toJson());

}

