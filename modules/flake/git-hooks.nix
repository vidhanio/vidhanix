{ inputs, ... }:
{
  flake-file.inputs.git-hooks-nix.url = "github:cachix/git-hooks.nix";

  imports = [
    inputs.git-hooks-nix.flakeModule
  ];
  perSystem =
    { pkgs, ... }:
    {
      pre-commit.settings = {
        package = pkgs.prek;
        hooks = {
          deadnix.enable = true;
          ruff.enable = true;
          shellcheck.enable = true;
          statix.enable = true;
          treefmt.enable = true;
          ty = {
            enable = true;
            name = "ty";
            entry = "${pkgs.ty}/bin/ty check --python ${
              pkgs.python3.withPackages (ps: [ ps.rich ])
            }/bin/python3";
            types = [ "python" ];
          };
        };
      };
      files.gitignore = ".pre-commit-config.yaml";
    };
}
