{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.programs._1password;
in
{
  options.programs._1password.enable = lib.mkEnableOption "1Password";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ _1password-gui ];

    xdg.autostart.entries = with pkgs; map lib.getDesktop [ _1password-gui ];

    impermanence.directories = [ ".config/1Password" ];
  };
}
