{
  config,
  lib,
  ...
}:
let
  cfg = config.programs._1password-gui;
in
lib.mkIf cfg.enable {
  environment.etc = {
    "1password/custom_allowed_browsers" = {
      text = ''
        firefox-devedition
      '';
      mode = "0755";
    };
  };

  home-manager.sharedModules = [
    {
      persist.directories = [ ".config/1Password" ];
    }
  ];
}
