{
  lib,
  config,
  ...
}:
let
  cfg = config.programs.vesktop;
in
lib.mkIf cfg.enable {
  xdg.autostart.entries = map lib.getDesktop [ cfg.package ];

  impermanence.directories = [ ".config/vesktop" ];
}
