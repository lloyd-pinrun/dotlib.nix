{lib}: let
  lists = rec {
    /**
    Add the given `item` to the **end** of a `list`.

    # Type

    ```
    append :: [ Anything ] -> Anything -> [ Anything ]
    ```

    # Examples

    ## `dotlib.lists.append` usage example

    ```nix
    lists.append ["a" "b"] "c"
    => ["a" "b" "c"]
    lists.append ["foo"] ["bar" "baz"]
    => ["foo" ["bar" "baz"]]
    ```
    */
    append = list: item: let
      _list = lib.lists.toList list;
      _item = lib.lists.toList item;
    in
      lib.lists.concat _list _item;

    /**
    Add the given `item` to the **start** of a `list`.

    # Type

    ```
    prepend :: [ Anything ] -> Anything -> [ Anything ]
    ```

    # Examples

    ## `dotlib.lists.prepend` usage example

    ```nix
    lists.prepend ["b" "c"] "a"
    => ["a" "b" "c"]
    lists.prepend ["baz"] ["foo" "bar"]
    => [["foo" "bar"] "baz"]
    ```
    */
    prepend = lib.trivial.flip append;
  };
in
  lists
