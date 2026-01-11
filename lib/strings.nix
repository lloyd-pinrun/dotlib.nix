{
  dotlib,
  lib,
}: let
  strings = rec {
    /**
    # Type
    Converts the first character in the given string to uppercase.

    ```
    capitalize :: String -> String
    ```
    */
    capitalize = str: upcase (dotlib.strings.first str) + dotlib.strings.rest str;

    /**
    Converts all characters in the given string to lowercase. Alias of `nixpkgs.lib.toLower`.

    # Type

    ```
    downcase :: String -> String
    ```
    */
    downcase = lib.toLower;

    /**
    Returns the first character in the given string.

    # Type

    ```
    first :: String -> String
    ```
    */
    first = builtins.substring 0 1;

    /**
    Returns the last character in the given string.

    # Type

    ```
    last :: String -> String
    ```
    */
    last = dotlib.trivial.pip' [
      lib.strings.stringToCharacters
      lib.lists.last
    ];

    /**
    Prepend the given `string` with a `prefix`.

    # Type

    ```
    prefix :: String -> String -> String
    ```
    */
    prepend = prefix: str: lib.strings.concatStrings [prefix str];

    /**
    Append the given `string` with a `suffix`.

    # Type

    ```
    append :: String -> String -> String
    ```
    */
    append = lib.flip prepend;

    /**
    Return the given string without the first character; abort evaluation if the argument is an empty string.

    # Type

    ```
    rest :: String -> String
    ```
    */
    rest = dotlib.trivial.pipe' [
      lib.strings.stringToCharacters
      lib.lists.tail
      lib.strings.concatStrings
    ];

    /**
    Converts all characters in the given string to uppercase. Alias of `nixpkgs.lib.toUpper`.

    # Type

    ```
    upcase :: String -> String
    ```
    */
    upcase = lib.toUpper;

    base = {
      /**
      Encodes a string into a base 64 encoded string.

      # Type

      ```
      encode64 :: AttrSet -> String -> String
      ```

      # Examples

      ## `dotlib.strings.base.encode64` usage example

      ```nix
      encode64 "foobar"
      => "Zm9vYmFy"
      encode64 "foob"
      => "Zm9vYg=="
      ```

      */
      encode64 = text: let
        convertTripletInt = let
          lookup = lib.strings.stringToCharacters "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

          _base = 64;
          pows = map (dotlib.math.pow _base) [3 2 1 0];

          intSextets = i: map (dividend: lib.mod (i / dividend) _base) pows;
        in
          dotlib.trivial.pipe' [intSextets (lib.strings.concatMapStringsSep (builtins.elemAt lookup))];

        sliceToInt = builtins.foldl' (acc: val: acc * 256 + val) 0;
        nFullSlices = (builtins.stringLength text) / 3;

        tripletAt = let
          sliceN = size: list: n: lib.lists.subList (n * size) size list;
          bytes = map lib.strings.charToInt (lib.strings.stringToCharacters text);
        in
          sliceN 3 bytes;

        _list = let
          convertTriplet = dotlib.trivial.pipe' [sliceToInt convertTripletInt];
        in
          builtins.genList (dotlib.trivial.pipe' [tripletAt convertTriplet]) nFullSlices;

        _last = let
          convertLastSlice = slice: let
            _length = builtins.length slice;
            convertible = (_length >= 1) && (_length <= 2);

            padding = lib.trivial.pipe _length [(builtins.genList (_: "=")) lib.string.concatStrings];

            multiplier = dotlib.math.pow 256 _length;
            base = (sliceToInt slice) * multiplier;

            convert = _base:
              lib.pipe _base [
                convertTripletInt
                (builtins.substring 0 (_length + 1))
                (append padding)
                lib.strings.concatStrings
              ];
          in
            if convertible
            then (convert base)
            else "";
        in
          convertLastSlice (tripletAt nFullSlices);
      in
        lib.strings.concatStrings (dotlib.lists.append _list _last);
    };
  };
in
  strings
