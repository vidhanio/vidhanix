# https://github.com/nix-community/stylix/pull/2485
{ lib, ... }: {
  flake.aspects.zed-editor = {
    homeManager =
      { config, ... }:
      let
        inherit (config.lib.stylix) colors;
        inherit (config.stylix) opacity;
      in
      {
        programs.zed-editor = {
          userSettings = {
            theme = "Base16 ${colors.scheme-name}";
            "experimental.theme_overrides" =
              let
                mkOpacityHexColor =
                  color:
                  let
                    hex = builtins.substring 2 (-1) (config.lib.stylix.mkOpacityHexColor color opacity.desktop);
                  in
                  lib.toLower "${builtins.substring 2 (-1) hex}${builtins.substring 0 2 hex}";
              in
              if (opacity.desktop != 1.0) then
                with colors;
                {
                  "background.appearance" = "transparent";
                  "background" = "#${mkOpacityHexColor base00}";
                  "surface.background" = "#${mkOpacityHexColor base00}";
                  "title_bar.background" = "#${mkOpacityHexColor base00}";
                  "title_bar.inactive.background" = "#00000000";
                  "editor.background" = "#00000000";
                  "editor.gutter.background" = "#00000000";
                  "panel.background" = "#00000000";
                  "toolbar.background" = "#00000000";
                  "tab_bar.background" = "#00000000";
                  "tab.active_background" = "#00000000";
                  "tab.inactive_background" = "#00000000";
                  "terminal.background" = "#00000000";
                }
              else
                { };
          };
        };
      };
  };
}
