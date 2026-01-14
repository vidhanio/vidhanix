{ inputs, ... }:
{
  flake-file.inputs.noctalia.url = "github:noctalia-dev/noctalia-shell";
  flake.modules = {
    nixos.default = {
      imports = [
        inputs.noctalia.nixosModules.default
      ];

      # services.noctalia-shell.enable = true;
    };
    homeManager.default = {
      imports = [
        inputs.noctalia.homeModules.default
      ];

      # programs.noctalia-shell.enable = true;
    };
  };
}
