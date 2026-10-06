{
  flake-file.inputs.helium.url = "github:schembriaiden/helium-browser-nix-flake";

  profiles.pc.homeModule =
    {
      config,
      inputs',
      lib,
      ...
    }:
    let
      cfg = config.programs.helium;
    in
    {
      programs.helium = {
        enable = true;
        package = inputs'.helium.packages.default;
      };

      xdg.autostart.entries = lib.mkIf (cfg.finalPackage != null) [
        "${cfg.finalPackage}/share/applications/helium.desktop"
      ];

      desktop = {
        binds."SUPER + b".cmd = "focus-or-launch helium helium";
        binds."SUPER + SHIFT + b".app = "helium";
        workspaces.work.apps = [ "helium" ];
      };

      persist.directories = [ ".config/net.imput.helium" ];
    };
}
