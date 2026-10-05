{

  flake.aspects.helium.homeManager =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.programs.helium;
    in
    {
      programs.helium.enable = true;

      xdg.autostart.entries = lib.mkIf (cfg.finalPackage != null) [
        "${cfg.finalPackage}/share/applications/helium.desktop"
      ];

      desktop.binds."SUPER + b" = {
        niri.cmd = "helium";
        hyprland.dsp."workspace.toggle_special"._args = [ "helium" ];
      };
      desktop.binds."SUPER + SHIFT + b".app = "helium";
      desktop.workspaces.helium = {
        special = true;
        onCreatedEmpty = "helium";
      };
      desktop.workspaces.work.apps = [ "helium" ];

      persist.directories = [ ".config/net.imput.helium" ];
    };
}
