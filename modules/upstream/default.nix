{ inputs, ... }:
let
  stylixTargets = import ./_stylix.nix { inherit inputs; };
in
{
  flake.nixosModules.upstream = {
    _class = "nixos";
    imports = [
      inputs.stylix.nixosModules.default
      (inputs.import-tree ./_modules/nixos)
      (stylixTargets "nixos")
    ];
  };

  flake.homeModules.upstream =
    { lib, ... }@args:
    {
      _class = "homeManager";
      imports = [
        (inputs.import-tree ./_modules/home-manager)
        (stylixTargets "hm")
      ]
      # Stylix's NixOS integration already imports this when enabled.
      ++ lib.optional (
        !(
          (args.osConfig.stylix.enable or false)
          && (args.osConfig.stylix.homeManagerIntegration.autoImport or false)
        )
      ) inputs.stylix.homeModules.default;
    };
}
