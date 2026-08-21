{ inputs, ... }:
{
  flake-file.inputs.nixos-apple-silicon.url = "github:nix-community/nixos-apple-silicon";

  flake.aspects =
    { aspects, ... }:
    {
      apple-silicon = {
        includes = [
          aspects.gui
          aspects.disk.provides.apple-silicon
          aspects.steam.provides.apple-silicon
        ];
        nixos = {
          imports = [ inputs.nixos-apple-silicon.nixosModules.default ];
          hardware.asahi.enable = true;
        };
      };
    };
}
