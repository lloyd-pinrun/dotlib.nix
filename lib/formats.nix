_: let
  formats = {
    toml.generate = pkgs: (pkgs.formats.toml {}).generate;
    yaml.generate = pkgs: (pkgs.formats.yaml {}).generate;
  };
in
  formats
