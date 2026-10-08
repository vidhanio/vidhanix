{ inputs, lib, ... }:
{
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
            entry = "${lib.getExe pkgs.ty} check --python ${
              lib.getExe (pkgs.python3.withPackages (ps: [ ps.rich ]))
            }";
            types = [ "python" ];
          };
        };
      };
      files.gitignore = ".pre-commit-config.yaml";
    };
}
