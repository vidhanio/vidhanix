{ inputs, ... }:
{
  flake-file.inputs.nix-index-database.url = "github:nix-community/nix-index-database";

  den.default.homeManager = {
    imports = [
      inputs.nix-index-database.homeModules.default
    ];

    programs.nix-index-database.comma.enable = true;

    persist.files = [ ".local/state/comma/choices" ];
  };
}
