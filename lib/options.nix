{
  dotlib,
  lib,
}: let
  inherit (dotlib) attrsets trivial;
  inherit (lib) types;

  wrapped = wrapper: nested: rest: let
    option = type: description: rest:
      lib.pipe {inherit type description;} [
        lib.singleton
        (lib.concat (lib.optional (builtins.isAttrs rest) rest))
        lib.mergeAttrsList
        lib.mkOption
      ];

    overlayDefault = _: _: {};

    # NOTE: Fixes nested option wrapping
    wrapOptions = value:
      if builtins.isFunction value
      then arg: wrapOptions (value arg)
      else if builtins.isList value
      then map wrapOptions value
      else if builtins.isAttrs value
      then
        if (value._type or null) == "option" && (attrsets.isMember value "type")
        then value // {type = wrapper value.type;}
        else builtins.mapAttrs (_: wrapOptions) value
      else value;
  in
    lib.pipe [
      # keep-sorted start
      "anything"
      "bool"
      "int"
      "lines"
      "package"
      "path"
      "pathInStore"
      "raw"
      "str"
      # keep-sorted end
    ] [
      (_types: lib.genAttrs _types lib.id)
      (lib.mergeAttrs {module = "deferredModule";})
      (builtins.mapAttrs (_: trivial.get types))
      (lib.mergeAttrs {
        overlay = types.mkOptionType {
          name = "overlays";
          description = "nixpkgs overlay";
          inherit (types.functionTo (types.functionTo (types.attrsOf types.anything))) check;
          merge = _: defs: builtins.foldl' (acc: fun: item: acc (fun item)) overlayDefault (map (item: item.value) defs);
        };

        # NOTE: `str` options with specific regex
        subdomain = types.strMatching "^[a-zA-Z0-9][a-zA-Z0-9\-]{0,61}[a-zA-Z0-9]$";
        domain = types.strMatching "^([a-zA-Z0-9][a-zA-Z0-9\-]{0,61}[a-zA-Z0-9]\.)+[a-z]{2,10}$";
        email = types.strMatching "^[a-zA-Z0-9][a-zA-Z0-9_.%+\-]{0,61}[a-zA-Z0-9]@([a-zA-Z0-9][a-zA-Z0-9\-]{0,61}[a-zA-Z0-9]\.)+[a-zA-Z]{2,10}$";
      })
      (builtins.mapAttrs (_: wrapper))
      (builtins.mapAttrs (_: option))
      # TODO: write these overrides more ergonomically!
      # TRACK: https://github.com/schradert/canivete/blob/38c1937c3ce88599338746bd21ae94234f265c54/lib.nix#L187
      (builtins.mapAttrs (_: _option: description: _rest: _option description (rest // _rest)))
      (prev: let
        submoduleWith = args: module:
          types.submoduleWith {
            modules = [module];
            shorthandOnlyDefinesConfig = true;
            specialArgs = args // {inherit dotlib;};
          };

        mkOption' = type: defaults: description: _rest:
          option (wrapper type) description (
            lib.pipe defaults [
              lib.singleton
              (lib.concat (lib.optional (builtins.isAttrs rest) rest))
              (lib.concat (lib.optional (builtins.isAttrs _rest) _rest))
              lib.mergeAttrsList
            ]
          );
      in
        lib.mergeAttrs prev {
          # keep-sorted start
          enable = mkOption' types.bool {default = false;};
          enabled = mkOption' types.bool {default = true;};
          enum = values: mkOption' (types.enum values) {};
          flake = inputs: name: mkOption' (types.nullOr types.raw) {default = inputs.${name} or null;} name;
          module = description: _rest: prev.module description ({default = {};} // rest // _rest);
          option = type: mkOption' type {};
          overlay = description: _rest: prev.overlay description ({default = overlayDefault;} // rest // _rest);
          submodule = description: module: mkOption' (submoduleWith {} module) {default = {};} description {};
          submodule' = module: lib.mkOption {type = wrapper (types.submodule module);};
          submoduleWith = description: args: module: mkOption' (submoduleWith args module) {default = {};} description {};
          # keep-sorted end

          # keep-sorted start block=yes newline_separated=no
          toml = pkgs: mkOption' (pkgs.formats.toml {}).type {default = {};};
          yaml = pkgs: mkOption' (pkgs.formats.yaml {}).type {default = {};};
          # keep-sorted end
        })
      (lib.mergeAttrs (builtins.mapAttrs (_: trivial.pipe' [(trivial.apply attrs) wrapOptions]) nested))
    ];

  # DOC:
  #   wrapped nestable option types, e.g.:
  #     * `dotlib.options.attrs.str`             -> `types.attrsOf types.str`
  #     * `dotlib.options.nullable.attrs.str`    -> `types.nullOr (types.attrsOf types.str)`
  #     * `dotlib.options.function.str`          -> `types.functionTo types.str`
  #     * `dotlib.options.nullable.function.str` -> `types.nullOr (types.functionTo types.str)`
  #     * `dotlib.options.list.str`              -> `types.listOf types.str`
  #     * `dotlib.options.nullable.list.str`     -> `types.nullOr (types.listOf types.str)`

  # keep-sorted start
  attrs = wrapped types.nullOr {inherit attrs function list nullable;};
  function = wrapped types.functionTo {inherit attrs function list nullable;};
  list = wrapped types.listOf {inherit attrs function list nullable;};
  nullable = wrapped types.nullOr {inherit attrs function list;};
  # keep-sorted end

  # -- dotlib.options --
  options =
    (wrapped lib.id {} {})
    // {
      attrs = attrs {default = {};};
      function = function {};
      list = list {default = [];};
      nullable = nullable {default = null;};
    };
in
  options
