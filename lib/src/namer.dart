part of discovery_api_client_generator;

/**
 * Represents an identifier that can be given a name.
 */
class Identifier {
  String _name;
  bool _sealed = false;

  /**
   * The prefered name for this [Identifier].
   */
  final String preferredName;

  /**
   * Constructs a new [Identifier] with the given [preferredName]. The
   * identifier will be not sealed.
   */
  Identifier(this.preferredName);

  /**
   * The allocated name for this [Identifier]. This will be [:null:] until
   * [sealWithName] was called.
   */
  String get name => _name;

  /**
   * Seals this [Identifier] and gives it the name [name].
   */
  void sealWithName(String name) {
    if (_sealed) {
      throw new StateError('This Identifier(preferredName: $preferredName) '
                           'has already been sealed.');
    }
    _name = name;
    _sealed = true;
  }

  /**
   * Gets a string representation of this [Identifier]. This can only be called
   * after the identifier has been given a name.
   */
  String toString() {
    if (!_sealed) {
      throw new StateError('This Identifier(preferredName: $preferredName) '
                           'has not been sealed yet.');
    }
    return _name;
  }
}


/**
 * Allocate [Identifier]s for a lexical scope.
 */
class Scope {
  static RegExp _StartsWithDigit = new RegExp('^[0-9]');
  static RegExp _NonAscii = new RegExp('[^a-zA-z0-9]');

  final Scope parentScope;
  final List<Scope> childScopes = new List<Scope>();
  final List<Identifier> identifiers = new List<Identifier>();

  Scope({Scope parent}) : this.parentScope = parent;

  /**
   * Returns a valid identifier based on [preferredName] but different from all
   * other names previously returned by this method.
   */
  Identifier newIdentifier(String preferredName,
                           {bool removeUnderscores: true}) {
    var identifier = new Identifier(Scope.toValidIdentifier(
        preferredName, removeUnderscores: removeUnderscores));
    identifiers.add(identifier);
    return identifier;
  }

  /**
   * Creates a new child [Scope].
   */
  Scope newChildScope() {
    var child = new Scope(parent: this);
    childScopes.add(child);
    return child;
  }

  /**
   * Converts [preferredName] to a valid identifier.
   */
  static String toValidIdentifier(String preferredName,
                                  {bool removeUnderscores: true}) {
    // Replace all a_b with aB.
    if (removeUnderscores) {
      int index = -1;
      while ((index = preferredName.indexOf('_', 1)) > 0) {
        if (index < (preferredName.length - 1)) {
          var a = preferredName.substring(0, index);
          var b = preferredName.substring(index + 1, index + 2);
          var c = preferredName.substring(index + 2);
          preferredName = '$a${b.toUpperCase()}$c';
        } else {
          break;
        }
      }
    }

    preferredName = preferredName.replaceAll('-', '_').replaceAll('.', '_');
    preferredName = preferredName.replaceAll(_NonAscii, '_');

    if (preferredName.startsWith(_StartsWithDigit)) {
      preferredName = 'D$preferredName';
    } else if (preferredName.startsWith('_')) {
      preferredName = 'P$preferredName';
    }

    if (keywords.contains(preferredName)) {
      preferredName = '${preferredName}_';
    }
    return preferredName;
  }

  /**
   * Converts the first letter of [name] to an uppercase letter.
   */
  static String capitalize(String name) {
    return "${name.substring(0, 1).toUpperCase()}${name.substring(1)}";
  }
}


/**
 * Names [Identifier]s and avoids name collisions by renaming.
 *
 * For every named [Identifier], it's allocated name will be added to
 * [allocatedNames].
 *
 * When allocating a new name, a name collides if either the name collides
 * with the [parentNamer] or if the name ia already in [allocatedNames].
 *
 * When allocating a new name, the namer starts with the [Identifier]s preferred
 * name, and keeps appending _N where N is an integer until a name does not
 * collide.
 */
class IdentifierNamer {
  final IdentifierNamer parentNamer;
  final Set<String> allocatedNames;

  /**
   * If [parentNamer] is given, this namer will only allocated names which are
   *   - not taken by [parentNamer]
   *   - not in [allocatedNames]
   */
  IdentifierNamer({this.parentNamer})
      : allocatedNames = new Set<String>();

  /**
   * Reserves all given [allocatedNames] by default.
   */
  IdentifierNamer.fromNameSet(this.allocatedNames) : parentNamer = null;

  /**
   * Gives [Identifier] a unique name amongst al previously named identifiers
   * and amongst all identifiers of [parentNamer].
   */
  void nameIdentifier(Identifier identifier) {
    var preferredName = identifier.preferredName;

    int i = 0;
    var currentName = preferredName;
    while (_contains(currentName)) {
      i++;
      currentName = '${preferredName}_$i';
    }
    identifier.sealWithName(currentName);
    allocatedNames.add(currentName);
  }

  bool _contains(String name) {
    if (allocatedNames.contains(name)) return true;
    if (parentNamer != null) {
      if (parentNamer._contains(name)) return true;
    }
    return false;
  }
}


/**
 * Helper class for allocating unique names for generating an API library.
 */
class ApiLibraryNamer {
  Scope _libraryScope;

  /**
   * NOTE: Only exposed for testing.
   */
  final Scope importScope = new Scope();

  ApiLibraryNamer() {
    _libraryScope = importScope.newChildScope();
  }

  /**
   * NOTE: Only exposed for testing.
   */
  Scope get libraryScope => _libraryScope;

  String libraryName(String package, String api, String version) {
    package = Scope.toValidIdentifier(package, removeUnderscores: false);
    api = Scope.toValidIdentifier(api, removeUnderscores: false);
    version = Scope.toValidIdentifier(version, removeUnderscores: false);
    return '$package.$api.$version';
  }

  Identifier import(String name)
      => importScope.newIdentifier(name, removeUnderscores: false);

  Identifier apiClass(String name)
      => _libraryScope.newIdentifier('${Scope.capitalize(name)}Api');

  Identifier resourceClass(String name, {String parent}) {
    name = Scope.capitalize(name);

    if (parent != null && parent.length > 0) {
      // The parent of a resource is either the api class or another resource!
      if (!parent.endsWith('Api')) {
        throw new ArgumentError('The parent has to end with Api');
      }

      bool parentIsApiClass = !parent.endsWith('ResourceApi');
      if (parentIsApiClass) {
        // We never prefix resource names with the api class name.
        parent = '';
      } else {
        parent = parent.substring(0, parent.length - 'ResourceApi'.length);
      }
      name = '${parent}${name}';
    }

    return _libraryScope.newIdentifier('${Scope.capitalize(name)}ResourceApi');
  }

  String schemaClassName(String name, {String parent}) {
    if (parent != null) {
      name = '${parent}${Scope.capitalize(name)}';
    }
    return Scope.capitalize(name);
  }

  Identifier schemaClass(String name) {
    return _libraryScope.newIdentifier(Scope.capitalize(name));
  }

  Scope newClassScope() => _libraryScope.newChildScope();

  void nameAllIdentifiers() {
    //
    // This method implements the following algorithm:
    // a) name all [Identifier]s in the library scope:
    //    => api class, schema classes, resource classes
    // b) name all [Identifier]s in the class scopes
    //    => fields and methods
    // c) name all [Identifier]s in the method parameter lists
    //    => positional parameters, optional parameters
    // d) name all [Identifier]s in the import scope
    //
    // This is implicilty done by
    // - naming all [Indentifier]s (**) in scope X
    // - naming all child scopes (**) of X
    // (**) (which are already ordered)
    //
    // The import scope is root of a scope tree which contains all [Identifier]s
    //
    // Collisions are handled in the a),b),c) phases by renaming if a name
    // was already taken by either the current scope or a parent scope.
    //
    // Collisions are handled in the d) phase by renaming if a name was already
    // taken by any of the other scopes
    // (which names get collected in [allAllocatedNames])
    //   => This makes sure we rather rename a import than a method parameter,
    //      but still try to name imports with preferred names if possible.
    //      [e.g. if a method parameter is named 'core' we will rename the
    //            import to: import 'dart:core' as core_1;

    var allAllocatedNames = new Set<String>();

    nameScope(Scope scope, parentResolver) {
      var resolver = new IdentifierNamer(parentNamer: parentResolver);
      scope.identifiers.forEach(resolver.nameIdentifier);
      // Order does not matter because child scopes are independent of each
      // other.
      scope.childScopes.forEach(
          (childScope) => nameScope(childScope, resolver));

      allAllocatedNames.addAll(resolver.allocatedNames);
    }

    // Name library scope identifiers and down. the passed [IdentifierNamer] is
    // an empty root namer.
    nameScope(_libraryScope, new IdentifierNamer());

    // Name all import identifiers. In case we have clashes with any of the
    // other names already assigned, we'll rename the prefixed imports.
    var resolver = new IdentifierNamer.fromNameSet(allAllocatedNames);
    importScope.identifiers.forEach(resolver.nameIdentifier);
  }
}
