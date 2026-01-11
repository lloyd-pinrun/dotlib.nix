{
  inputs,
  lib,
  ...
}: let
  dotlib = import "${inputs.self}/lib" lib;
in {
  imports = [inputs.flake-parts.flakeModules.partitions];
  flake = {inherit dotlib;};

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
