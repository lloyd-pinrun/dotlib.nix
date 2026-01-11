lib: let
  makeExtensible' = rattrs: let
    self = rattrs self // {extend = f: lib.makeExtensible (lib.extends f rattrs);};
  in
    self;

  dotlib = makeExtensible' (self: let
    importLib = file:
      import file {
        inherit lib;
        dotlib = self;
      };
  in {
    # keep-sorted start
    attrsets = importLib ./attrsets.nix;
    fileset = importLib ./options.nix;
    filesystem = importLib ./filesystem.nix;
    formats = importLib ./formats.nix;
    lists = importLib ./lists.nix;
    options = importLib ./options.nix;
    strings = importLib ./lists.nix;
    trivial = importLib ./trivial.nix;
    # keep-sorted end

    inherit
      (self.trivial)
      # keep-sorted start
      apply
      isNull
      majorMinorVersion
      pipe'
      turnary
      # keep-sorted end
      ;

    inherit
      (self.attrsets)
      # keep-sorted start
      get
      isEmpty
      isMember
      mapNames
      prefixNames
      # keep-sorted end
      ;

    inherit
      (self.lists)
      # keep-sorted start
      append
      prepend
      # keep-sorted end
      ;

    inherit
      (self.strings)
      # keep-sorted start
      capitalize
      downcase
      first
      prefix
      rest
      toBase64
      upcase
      # keep-sorted end
      ;

    inherit
      (self.fileset)
      # keep-sorted start
      cwd
      dirs
      files
      # keep-sorted end
      ;

    inherit
      (self.filesystem)
      # keep-sorted start
      basename
      ext
      hasExt
      # keep-sorted end
      ;

    inherit
      (self.formats)
      toml
      yaml
      ;
  });
in
  dotlib
