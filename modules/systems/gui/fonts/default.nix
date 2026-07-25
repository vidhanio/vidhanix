{ withSystem, ... }:
{
  flake-file.inputs.apple-fonts.url = "github:Lyndeno/apple-fonts.nix";

  flake.modules.nixos.default =
    { pkgs, ... }:
    {
      stylix = {
        fonts = {
          monospace = {
            package = withSystem pkgs.stdenv.hostPlatform.system (
              { inputs', ... }: inputs'.apple-fonts.packages.sf-mono-nerd
            );
            name = "SFMono Nerd Font";
          };
          serif = {
            package = withSystem pkgs.stdenv.hostPlatform.system (
              { inputs', ... }: inputs'.apple-fonts.packages.ny-nerd
            );
            name = "NY Nerd Font";
          };
          sansSerif = {
            package = withSystem pkgs.stdenv.hostPlatform.system (
              { inputs', ... }: inputs'.apple-fonts.packages.sf-pro-nerd
            );
            name = "SFProDisplay Nerd Font";
          };
        };
      };
    };
}
