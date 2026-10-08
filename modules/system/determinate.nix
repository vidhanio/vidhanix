{ inputs, ... }:
{
  flake-file = {
    inputs.determinate = {
      url = "github:DeterminateSystems/determinate";
      inputs = {
        nixpkgs.autoFollow = false;
        nix.inputs.nixpkgs.autoFollow = false;
      };
    };
    nixConfig = {
      extra-substituters = [ "https://install.determinate.systems" ];
      extra-trusted-public-keys = [
        "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
      ];
    };
  };

  profiles.base.module.imports = [ inputs.determinate.nixosModules.default ];
}
