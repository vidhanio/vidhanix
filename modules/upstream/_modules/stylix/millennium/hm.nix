{
  mkTarget,
  config,
  lib,
  ...
}:
mkTarget {
  autoEnable =
    config.programs.millennium.enable && config.programs.millennium.themes ? space-theme-steam;
  autoEnableExpr = "config.programs.millennium.enable && config.programs.millennium.themes ? space-theme-steam";

  config =
    { colors }:
    let
      rgb =
        name:
        lib.concatMapStringsSep ", " (channel: colors."${name}-rgb-${channel}") [
          "r"
          "g"
          "b"
        ];
    in
    {
      programs.millennium.settings.themes.themeColors."space-theme-steam" = lib.mapAttrs (_: rgb) {
        "--st-accent-1" = "base0D";
        "--st-accent-2" = "base0D";
        "--st-color-1" = "base01";
        "--st-color-2" = "base02";
        "--st-color-3" = "base01";
        "--st-color-4" = "base02";
        "--st-color-5" = "base03";
        "--st-color-6" = "base03";
        "--st-background" = "base00";
        "--st-red" = "base08";
        "--st-red-hover" = "base08";
        "--st-green" = "base0B";
        "--st-green-hover" = "base0B";
        "--st-blue" = "base0D";
        "--st-blue-hover" = "base0D";
        "--st-yellow" = "base0A";
        "--st-yellow-hover" = "base0A";
      };
    };
}
