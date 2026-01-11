{lib, ...}: let
  onlyDirs = builtins.filter (path: lib.filesystem.pathIsDirectory path);
  onlyFiles = builtins.filter (path: lib.filesystem.pathIsRegularFile path);
  topLevelPaths = paths: builtins.filter (path: ! (builtins.any (_path: _path != path && lib.strings.hasPrefix (toString _path + "/") (toString path)) paths)) paths;

  fileset = rec {
    /**
    Return a list of paths for all top-level files in the given `fileset`.

    # Inputs

    `fileset`

    : The fileset whose files to return.

    # Type

    ```
    files.all :: FileSet -> [ Path ]
    ```
    */
    files.all = fileset: let
      files = lib.pipe fileset [
        lib.fileset.toList
        onlyFiles
        topLevelPaths
      ];
    in
      files;

    /**
    Return a list of paths for all top-level files in the given `fileset` matching some `predicate`.

    # Inputs

    `predicate`

    : The predicate function to call on all files contained in given file set.
      A file is included in the resulting file set if this function returns true for it.

      This function is called with an attribute set containing these attributes:

      - `name` (String): The name of the file

      - `type` (String, one of `"regular"`, `"symlink"` or `"unknown"`): The type of the file.
        This matches result of calling [`builtins.readFileType`](https://nixos.org/manual/nix/stable/language/builtins.html#builtins-readFileType) on the file's path.

      - `hasExt` (String -> Bool): Whether the file has a certain file extension.
        `hasExt ext` is true only if `hasSuffix ".${ext}" name`.

        This also means that e.g. for a file with name `.gitignore`,
        `hasExt "gitignore"` is true.

      Other attributes may be added in the future.

    `fileset`

    : The fileset whose files to filter

    # Type

    ```
    files.filter :: ({name :: String, type :: String, hasExt :: (String -> Bool)} -> Bool) -> FileSet -> [ Path ]
    ```
    */
    files.filter = _fun: fileset: let
      files = lib.pipe fileset [
        lib.fileset.toList
        onlyFiles
        topLevelPaths
      ];
    in
      files;

    /**
    Return a list of path for only `.nix` files in the given `fileset`.

    # Type

    ```
    files.nix.all :: FileSet -> [ Path ]
    ```
    */
    files.nix.all = fileset: files.filter (file: file.hasExt "nix") fileset;

    /**
    Return a list of paths for all top-level directories in the given `fileset`.

    # Inputs

    `fileset`

    : The fileset whose directories to return.

    # Type

    ```
    dirs.all :: FileSet -> [ Path ]
    ```
    */
    dirs.all = fileset: let
      dirs = lib.pipe fileset [
        lib.fileset.toList
        onlyDirs
        topLevelPaths
      ];
    in
      dirs;

    /**
    Return a list of paths for all top-level directories in the given `fileset` matching some `predicate`.

    If the `predicate` includes a filter that would exclude directories, an empty list will be returned.

    # Inputs

    `predicate`

    : The predicate function to call on all files contained in given file set.
      A file is included in the resulting file set if this function returns true for it.

      This function is called with an attribute set containing these attributes:

      - `name` (String): The name of the file

      - `type` (String, one of `"regular"`, `"symlink"` or `"unknown"`): The type of the file.
        This matches result of calling [`builtins.readFileType`](https://nixos.org/manual/nix/stable/language/builtins.html#builtins-readFileType) on the file's path.

      - `hasExt` (String -> Bool): Whether the file has a certain file extension.
        `hasExt ext` is true only if `hasSuffix ".${ext}" name`.

        This also means that e.g. for a file with name `.gitignore`,
        `hasExt "gitignore"` is true.

      Other attributes may be added in the future.

    `fileset`

    : The fileset whose files to filter

    # Type

    ```
    dirs.filter :: ({name :: String, type :: String, hasExt :: (String -> Bool)} -> Bool) -> FileSet -> [ Path ]
    ```
    */
    dirs.filter = fun: fileset: let
      dirs = lib.pipe fileset [
        (lib.fileset.fileFilter fun)
        onlyDirs
        topLevelPaths
      ];
    in
      dirs;

    cwd = {
      files.all = files.all ./.;
      files.nix.all = files.nix.all ./.;
      files.filter = lib.trivial.flip files.filter ./.;
      dirs.all = dirs.all ./.;
      dirs.filter = lib.trivial.flip dirs.filter ./.;
    };
  };
in
  fileset
