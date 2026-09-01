{ lib, ... }:
{
  flake.aspects.fastpotify = {
    homeManager =
      {
        config,
        inputs',
        pkgs,
        ...
      }:
      let
        colors = config.lib.stylix.colors;

        rgb =
          name:
          "Color32::from_rgb(${colors."${name}-rgb-r"}, ${colors."${name}-rgb-g"}, ${colors."${name}-rgb-b"})";

        stylixPatch = pkgs.replaceVars ./stylix.patch {
          base00 = rgb "base00";
          base01 = rgb "base01";
          base02 = rgb "base02";
          base03 = rgb "base03";
          base04 = rgb "base04";
          base05 = rgb "base05";
          base08 = rgb "base08";
          base0A = rgb "base0A";
          base0D = rgb "base0D";
        };

        defaultTheme =
          if config.stylix.polarity == "light" then
            "light"
          else if config.stylix.polarity == "either" then
            "system"
          else
            "dark";

        cmakeWithLibdir = pkgs.writeShellScript "cmake-fastpotify" ''
          if [[ "$1" == "--build" ]]; then
            exec ${pkgs.cmake}/bin/cmake "$@"
          else
            exec ${pkgs.cmake}/bin/cmake "$@" -DCMAKE_INSTALL_LIBDIR=lib
          fi
        '';

        package = inputs'.fastpotify.packages.fastpotify.overrideAttrs (old: {
          cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
            inherit (old) pname src version;
            hash = "sha256-dgV3BWdD2Eli5pgaUJxkID41EuTNllWPDH0R23tyML8=";
          };

          buildInputs = (old.buildInputs or [ ]) ++ [
            pkgs.libGL
            pkgs.libx11
          ];

          env = (old.env or { }) // {
            CMAKE = "${cmakeWithLibdir}";
          };

          patches = (old.patches or [ ]) ++ [ stylixPatch ];
        });
      in
      {
        # fastpotify compiles its palette into the binary rather than reading a theme file.
        programs.fastpotify = {
          package = lib.mkDefault package;
          settings.theme = lib.mkDefault defaultTheme;
        };
      };
  };
}
