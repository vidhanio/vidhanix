{
  mkTarget,
  config,
  lib,
  pkgs,
  ...
}:
mkTarget {
  autoEnable = config.programs.helium.enable;
  autoEnableExpr = "config.programs.helium.enable";

  config =
    { colors }:
    let
      rgbList =
        name:
        map (channel: lib.toInt colors."${name}-rgb-${channel}") [
          "r"
          "g"
          "b"
        ];

      manifest = pkgs.writers.writeJSON "manifest.json" {
        manifest_version = 3;
        name = "Stylix";
        version = "1.0.0";

        theme = {
          colors = lib.mapAttrs (_: rgbList) {
            # `frame` currently does nothing: https://github.com/imputnet/helium/issues/1459
            frame = "base03";
            frame_incognito = "base03";

            frame_inactive = "base00";
            frame_incognito_inactive = "base00";

            toolbar = "base02";
            tab_text = "base0D";
            bookmark_text = "base06";
            toolbar_text = "base06";

            background_tab = "base00";
            background_tab_inactive = "base00";
            background_tab_incognito = "base00";
            background_tab_incognito_inactive = "base00";

            tab_background_text = "base06";
            tab_background_text_inactive = "base04";
            tab_background_text_incognito = "base06";
            tab_background_text_incognito_inactive = "base04";

            omnibox_text = "base0D";
            omnibox_background = "base01";

            ntp_header = "base01";
            ntp_text = "base06";
            ntp_link = "base07";
            ntp_section = "base01";
            ntp_background = "base02";

            button_background = "base02";
          };
        };
      };
      theme = pkgs.runCommandLocal "helium-theme" { } ''
        mkdir $out
        ln -s ${manifest} $out/manifest.json
      '';
    in
    {
      programs.helium.commandLineArgs = [
        "--load-extension=${theme}"
      ];
    };
}
