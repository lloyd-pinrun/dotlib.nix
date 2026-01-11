{
  inputs,
  lib,
  ...
}: let
  dotlib = import "${inputs.self}/lib" lib;
in {
  imports = [inputs.flake-parts.flakeModules.partitions];

  flake = {
    lib = {inherit (dotlib) fileset;};

    flakeModule = {
      config = {
        _module.args = {inherit dotlib;};
        perSystem.config._module.args = {inherit dotlib;};
      };
    };
  };

  partitions.dev = {
    module = ./dev;
    extraInputsFlake = ./dev;
  };

  # partitionedAttrs.checks = "dev";
  # partitionedAttrs.devShells = "dev";
  # partitionedAttrs.formatter = "dev";

  partitionedAttrs = lib.genAttrs ["checks" "devShells" "formatter"] (_: "dev");

  systems = import inputs.systems;
}
