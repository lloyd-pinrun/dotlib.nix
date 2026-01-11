{
  dotlib,
  lib,
}: let
  filesystem = rec {
    /**
    Return only the filename for the given `path`.

    # Type

    ```
    basename :: Path -> String
    ```
    */
    basename = path:
      lib.pipe path [
        toString
        (lib.strings.splitString "/")
        lib.lists.last
      ];

    /**
    Return the extension for the given `path`.

    # Type

    ```
    ext :: Path -> String
    ```
    */
    ext = path:
      lib.pipe path [
        basename
        (builtins.match ".*\\.([^.]+)$")
        (match:
          if match != null
          then (lib.strings.concatStrings (dotlib.lists.append "." match))
          else null)
      ];

    /**
    Determine whether a `path` has the given `extension`.

    # Type

    ```
    hasExt :: String -> Path -> Bool
    ```
    */
    hasExt = extension: path: (ext path) == extension;
  };
in
  filesystem
