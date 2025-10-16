{
  lib,
  config,
  pkgs,
  osConfig,
  ...
}:
let
  cfg = config.programs.vesktop;
  jsonFormat = pkgs.formats.json { };
  stateFile.source = jsonFormat.generate "vesktop-state" cfg.state;
  inherit (osConfig.nixpkgs.hostPlatform) isDarwin;
in
{
  options.programs.vesktop = {
    state = lib.mkOption {
      type = jsonFormat.type;
      default = { };
      description = ''
        Vesktop state written to
        {file}`$XDG_CONFIG_HOME/vesktop/state.json`. See
        <https://github.com/Vencord/Vesktop/blob/main/src/shared/settings.d.ts>
        for available options.
      '';
    };
  };

  config = lib.mkMerge [
    {
      programs.vesktop = {
        package = pkgs.vesktop-git;
        settings = {
          discordBranch = "canary";
          minimizeToTray = true;
          arRPC = true;
          hardwareAcceleration = true;
          hardwareVideoAcceleration = true;
          customTitleBar = true;
        };
        state = {
          firstLaunch = false;
          maximized = true;
        };
      };
    }
    (lib.mkIf cfg.enable {
      xdg.autostart.entries = map lib.getDesktop [ cfg.package ];

      impermanence.directories = [ ".config/vesktop/sessionData/Local Storage" ];

      xdg.configFile."vesktop/state.json" = lib.mkIf (!isDarwin) stateFile;
      home.file."Library/Application Support/vesktop/state.json" = lib.mkIf isDarwin stateFile;
    })
  ];
}
