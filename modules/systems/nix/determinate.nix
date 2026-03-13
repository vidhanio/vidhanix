{ inputs, ... }:
{
  flake-file = {
    inputs = {
      determinate.url = "github:DeterminateSystems/determinate";
      determinate-nix.url = "github:DeterminateSystems/nix-src";
    };

    nixConfig = {
      extra-substituters = [
        "https://install.determinate.systems"
      ];
      extra-trusted-public-keys = [
        "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
      ];
    };
  };

  flake.modules.nixos.default = {
    imports = [ inputs.determinate.nixosModules.default ];
  };
}
