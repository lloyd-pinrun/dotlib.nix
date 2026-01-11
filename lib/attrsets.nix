{
  dotlib,
  lib,
}: let
  attrsets = {
    /**
    # Type

    ```
    get :: String -> Any -> AttrSet -> Any
    ```
    */
    get = attr: default: set:
      lib.trivial.pipe attr [
        lib.lists.singleton
        (attrPath: lib.attrsets.attrByPath attrPath default set)
      ];

    /**
    # Type

    ```
    get :: String -> AttrSet -> Any
    ```
    */
    fetch = attr: set:
      lib.trivial.pipe attr [
        lib.lists.singleton
        (attrPath: lib.attrsets.getAttrFromPath attrPath set)
      ];

    /**
    # Type

    ```
    hasMember :: AttrSet -> String -> Bool
    ```
    */
    isMember = lib.trivial.flip builtins.hasAttr;

    /**
    # Type

    ```
    isEmpty :: AttrSet -> Bool
    ```
    */
    isEmpty = set: set == {};

    /**
    # Type

    ```
    mapNames :: (String -> String) -> AttrSet -> AttrSet
    ```
    */
    mapNames = fun: lib.attrsets.mapAttrs' (name: lib.attrsets.nameValuePair (fun name));

    /**
    # Type

    ```
    prefixNames :: String -> AttrSet -> AttrSet
    ```
    */
    prefixNames = dotlib.trivial.pipe' [dotlib.strings.prefix dotlib.attrsets.mapNames];
  };
in
  attrsets
