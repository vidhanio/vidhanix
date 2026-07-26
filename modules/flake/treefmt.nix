{ inputs, den, ... }:
{
  imports = [
    inputs.treefmt-nix.flakeModule
  ];

  flake-file.inputs.treefmt-nix.url = "github:numtide/treefmt-nix";

  den.classes.treefmt = { };

  den.policies.treefmt-to-flake-parts = _: [
    (den.lib.policy.route {
      fromClass = "treefmt";
      intoClass = "flake-parts";
      path = [ "treefmt" ];
      adaptArgs = { config, ... }: config.allModuleArgs;
    })
  ];

  den.schema.flake-parts.includes = [
    den.policies.treefmt-to-flake-parts
    {
      treefmt = {
        programs = {
          nixfmt.enable = true;
          statix.enable = true;
          deadnix.enable = true;

          shfmt.enable = true;
          shellcheck.enable = true;

          stylua.enable = true;

          actionlint.enable = true;

          oxfmt.enable = true;

          xmllint.enable = true;

          keep-sorted.enable = true;
        };

        settings.on-unmatched = "fatal";
      };
    }
  ];

  perSystem.pre-commit.settings.hooks.treefmt = {
    enable = true;
    pass_filenames = false;
  };
}
