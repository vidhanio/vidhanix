{ withSystem, ... }:
{
  flake-file.inputs.vidhan-fonts = {
    url = "git+ssh://git@github.com/vidhanio/fonts";
    flake = false;
  };

  flake.modules.nixos.default =
    { pkgs, config, ... }:
    let
      cfg = config.stylix;
    in
    {
      stylix = {
        fonts = {
          monospace = {
            package = withSystem pkgs.stdenv.hostPlatform.system (
              { self', ... }: self'.packages.berkeley-mono-variable
            );
            name = "Berkeley Mono Variable";
          };
          serif = cfg.fonts.monospace;
          sansSerif = {
            package = withSystem pkgs.stdenv.hostPlatform.system (
              { self', ... }: self'.packages.google-sans-flex
            );
            name = "Google Sans Flex";
          };
        };
      };
    };
}
