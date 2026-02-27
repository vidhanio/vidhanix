{ withSystem, ... }:
{
  flake.modules.nixos.default =
    { pkgs, config, ... }:
    let
      cfg = config.stylix;

      patchNerdFont =
        font:
        pkgs.stdenv.mkDerivation {
          pname = "${font.pname}-nerd-font";
          inherit (font) version;

          src = font;

          nativeBuildInputs = [
            pkgs.nerd-font-patcher
            pkgs.parallel
          ];

          buildPhase = ''
            runHook preBuild

            find -name \*.ttf -o -name \*.otf | parallel --will-cite nerd-font-patcher -c

            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall

            cp -a . $out

            runHook postInstall
          '';
        };

    in
    {
      stylix = {
        fonts = {
          monospace = {
            package = withSystem pkgs.stdenv.hostPlatform.system (
              { self', ... }: patchNerdFont self'.packages.berkeley-mono
            );
            name = "BerkeleyMono Nerd Font";
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
