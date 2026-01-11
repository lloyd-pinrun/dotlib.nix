{
  dotlib,
  lib,
  pkgs,
}: let
  test = name: assertion:
    if assertion
    then {
      success = true;
      inherit name;
    }
    else throw "Test '${name}' failed";

  # TODO:
  #   tests have nested attrs of each `dotlib` attr(?), e.g.:
  #   * `tests.dotlib.exists`
  #   * `tests.dotlib.options.exists`
  #   * `tests.dotlib.options.attrs.exists`
  #   * `tests.dotlib.options.attrs.str.exists`
  tests = {
    # -- dotlib
    dotlib-exists = test "dotlib exists" (dotlib != null);

    # -- dotlib.options
    # keep-sorted start
    dotlib-has-options = test "dotlib has options" (dotlib ? options);
    options-has-attrs = test "options has attrs" (dotlib.options ? attrs);
    options-has-domain = test "options has domain" (dotlib.options ? domain);
    options-has-email = test "options-has-email" (dotlib.options ? domain);
    options-has-enable = test "options has enable" (dotlib.options ? enable);
    options-has-enabled = test "options has enable" (dotlib.options ? enabled);
    options-has-enum = test "options has enable" (dotlib.options ? enum);
    options-has-flake = test "options has flake" (dotlib.options ? flake);
    options-has-module = test "options has module" (dotlib.options ? module);
    options-has-option = test "options has option" (dotlib.options ? option);
    options-has-overlay = test "options has overlay" (dotlib.options ? overlay);
    options-has-submodain = test "options has subdomain" (dotlib.options ? subdomain);
    options-has-submodule = test "options has submodule" (dotlib.options ? submodule);
    options-has-submodule' = test "options has submodule'" (dotlib.options ? submodule');
    options-has-submoduleWith = test "options has submoduleWith" (dotlib.options ? submoduleWith);
    options-has-toml = test "options has submodule" (dotlib.options ? toml);
    options-has-yaml = test "options has yaml" (dotlib.options ? yaml);
    # keep-sorted end

    # -- dotlib.fileset
    dotlib-has-fileset = test "dotlib has fileset" (dotlib ? fileset);
    # keep-sorted start
    fileset-has-cwd = test "fileset has cwd" (dotlib.fileset ? cwd);
    fileset-has-dirs = test "fileset has dirs" (dotlib.fileset ? dirs);
    fileset-has-files = test "fileset has files" (dotlib.fileset ? files);
    # keep-sorted end

    # -- dotlib.filesystem
    dotlib-has-filesystem = test "dotlib has filesystem" (dotlib ? filesystem);
    # keep-sorted start
    filesystem-has-basename = test "filesystem has basename" (dotlib.filesystem ? basename);
    filesystem-has-ext = test "filesystem has ext" (dotlib.filesystem ? ext);
    filesystem-has-hasExt = test "filesystem has hasExt" (dotlib.filesystem ? hasExt);
    # keep-sorted end

    # -- dotlib.attrsets
    dotlib-has-attrsets = test "dotlib has attrsets" (dotlib ? attrsets);
    # keep-sorted start
    attrsets-fetch = test "fetch returns correct value for attr" ((dotlib.attrsets.fetch "key" {key = "value";}) == "value");
    attrsets-get = test "get returns correct value for attr" ((dotlib.attrsets.get "key" null {key = "value";}) == "value");
    attrsets-get-default = test "get returns default value if attr is not in set" ((dotlib.attrsets.get "missing-key" null {key = "value";}) == null);
    attrsets-isEmpty-empty = test "isEmpty returns true when arg is an empty set" (dotlib.attrsets.isEmpty {});
    attrsets-isEmpty-nonempty = test "isEmpty returns false when arg is a non-empty set" (! (dotlib.attrsets.isEmpty {a = 1;}));
    attrsets-isMember-false = test "isMember returns false when attr is not in set" (! (dotlib.attrsets.isMember {a = 1;} "b"));
    attrsets-isMember-true = test "isMember returns true when attr is in set" (dotlib.attrsets.isMember {a = 1;} "a");
    # keep-sorted end

    # -- dotlib.math
    dotlib-has-math = test "dotlib has math" (dotlib ? math);
    math-pow = test "pow returns correct value" ((dotlib.math.pow 2 2) == 4);

    # -- dotlib.trivial
    dotlib-has-trivial = test "dotlib has trivial" (dotlib ? trivial);
    # keep-sorted start
    trivial-apply = test "apply functions correctly" ((dotlib.apply 1 (x: x + 1)) == 2);
    trivial-isNull-null = test "isNull returns true when arg is null" (dotlib.isNull null);
    trivial-isNull-value = test "isNull returns false when arg is not null" (! (dotlib.isNull "value"));
    trivial-turnary-false = test "turnary falsey case functions correctly" ((dotlib.turnary false "yes" "no") == "no");
    trivial-turnary-true = test "turnary truthy case functions correctly" ((dotlib.turnary true "yes" "no") == "yes");
    # keep-sorted end

    # -- dotlib.strings
    dotlib-has-strings = test "dotlib has strings" (dotlib ? strings);
    # keep-sorted start
    strings-append = test "append functions correctly" ((dotlib.strings.append "bar" "foo") == "foobar");
    strings-capitalize = test "capitalize converts the first char in a string to uppercase" ((dotlib.strings.capitalize "foobar") == "Foobar");
    strings-downcase = test "downcase converts all chars in a string to lowercase" ((dotlib.strings.downcase "FOOBAR") == "foobar");
    strings-prepend = test "prepend functions correctly" ((dotlib.strings.prepend "foo" "bar") == "foobar");
    strings-upcase = test "upcase converts all chars in a string to uppercase" ((dotlib.strings.upcase "foobar") == "FOOBAR");
    # keep-sorted end

    # -- dotlib.lists
    dotlib-has-lists = test "dotlib has lists" (dotlib ? lists);
    # keep-sorted start
    lists-append = test "append to list" ((dotlib.lists.append [1 2] 3) == [1 2 3]);
    lists-prepend = test "prepend to list" ((dotlib.lists.prepend [2 3] 1) == [1 2 3]);
    # keep-sorted end
  };

  results = lib.mapAttrs (_name: test: test) tests;
  allPassed = lib.all (result: result.success) (lib.attrValues results);

  summary = let
    passed = lib.filter (r: r.success) (lib.attrValues results);
    total = lib.length (lib.attrValues results);
  in {
    inherit total;
    passed = lib.length passed;
    allPassed = total == lib.length passed;
  };
in {
  inherit tests results summary;

  runTests = dummyFile:
    if allPassed
    then
      pkgs.runCommand "dotlib-eval-tests" {passthru = {inherit results summary;};} ''
        echo "All ${toString summary.total} tests passed!"
        echo "Tests: ${lib.concatStringsSep ", " (lib.attrNames tests)}"
        ln -s ${dummyFile} $out
      ''
    else throw "Some tests failed. Results: ${lib.generators.toPretty {} results}";
}
