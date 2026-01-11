{inputs, ...}: {
  imports = [inputs.devenv.flakeModule];

  perSystem = _: {
    devenv.shells.default = {
      git-hooks.default_stages = ["pre-push" "manual"];
      git-hooks.excludes = [".editorconfig"];

      git-hooks.hooks = {
        # keep-sorted start block=yes
        check-merge-conflicts.enable = true;
        end-of-file-fixer.enable = true;
        flake-checker.enable = true;
        lychee.enable = true;
        markdownlint = {
          enable = true;
          settings.configuration.MD013.line_length = -1;
        };
        mixed-line-endings.enable = true;
        nil.enable = true;
        no-commit-to-branch = {
          # TODO: enable this at some point
          enable = false;
          settings.branch = ["main"];
        };
        trim-trailing-whitespace.enable = true;
        typos.enable = true;
        # keep-sorted end
      };
    };
  };
}
