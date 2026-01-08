{ inputs, ... }:
{
  flake-file.inputs.git-hooks-nix.url = "github:cachix/git-hooks.nix";

  imports = [
    inputs.git-hooks-nix.flakeModule
  ];
  perSystem =
    { pkgs, ... }:
    {
      pre-commit.settings.package = pkgs.prek;
      files.gitignore = ".pre-commit-config.yaml";
    };
}
