{ inputs, ... }:
{
  imports = [
    inputs.treefmt-nix.flakeModule
  ];

  flake-file.inputs.treefmt-nix.url = "github:numtide/treefmt-nix";

  perSystem =
    { config, ... }:
    {
      treefmt = {
        programs = {
          nixfmt.enable = true;
          statix.enable = true;
          deadnix.enable = true;

          shfmt.enable = true;
          shellcheck.enable = true;

          taplo.enable = true;
        };

        settings.on-unmatched = "fatal";
      };

      pre-commit.settings.hooks.treefmt = {
        enable = true;
        packageOverrides.treefmt = config.treefmt.package;
      };

      files.file."treefmt.toml".source = config.treefmt.build.configFile;
    };
}
