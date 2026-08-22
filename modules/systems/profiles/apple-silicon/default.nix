{ inputs, ... }:
{
  flake-file.inputs.nixos-apple-silicon.url = "github:nix-community/nixos-apple-silicon";

  flake.aspects =
    { aspects, ... }:
    {
      apple-silicon = {
        includes = with aspects; [
          gui

          # keep-sorted start
          disk.provides.apple-silicon
          steam.provides.apple-silicon
          # keep-sorted end
        ];
        nixos = {
          imports = [ inputs.nixos-apple-silicon.nixosModules.default ];
          hardware.asahi.enable = true;
        };
      };
    };
}
