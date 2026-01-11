{inputs, ...}: {
  imports = [
    inputs.self.flakeModule
    ./devenv.nix
    ./treefmt.nix
  ];

  perSystem = {
    dotlib,
    lib,
    pkgs,
    ...
  }: {
    checks.eval-tests = let
      tests = import ./tests/eval-tests.nix {inherit dotlib lib pkgs;};
    in
      tests.runTests pkgs.emptyFile;
  };
}
