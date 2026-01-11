{inputs, ...}: {
  imports = [inputs.treefmt.flakeModule];

  perSystem = {config, ...}: let
    formatter = config.treefmt.build.wrapper;
  in {
    inherit formatter;

    devenv.shells.default = {
      git-hooks.hooks.treefmt = {
        enable = true;
        package = formatter;
      };
    };

    treefmt = {
      flakeCheck = true;
      flakeFormatter = true;
      projectRootFile = ".git/config";

      programs = {
        # keep-sorted start
        alejandra.enable = true;
        deadnix.enable = true;
        keep-sorted.enable = true;
        nixf-diagnose.enable = true;
        statix.enable = true;
        # keep-sorted end
      };

      settings = {
        global.excludes = [
          # keep-sorted start
          ".editorconfig"
          ".envrc"
          ".gitignore"
          "flake.lock"
          # keep-sorted end
        ];

        formatter.nixf-diagnose.options = [
          "--ignore=sema-primop-overridden"
        ];
      };
    };
  };
}
