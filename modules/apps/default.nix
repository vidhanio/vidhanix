{ withSystem, lib, ... }:
{
  flake.modules.homeManager.default =
    {
      config,
      osConfig,
      pkgs,
      ...
    }:
    {
      apps =
        let
          self' = withSystem pkgs.stdenv.hostPlatform.system ({ self', ... }: self');
          inherit (config) programs;
          osPrograms = osConfig.programs;
          maybeSpicetify = lib.optional programs.spicetify.enable programs.spicetify.spicedSpotify;
        in
        {
          autostart = [
            pkgs.solaar
            programs.nixcord.finalPackage.vesktop
            osPrograms._1password-gui.package
            osPrograms.steam.package
          ]
          ++ maybeSpicetify;

          dock = [
            {
              package = pkgs.nautilus;
              name = "org.gnome.Nautilus.desktop";
            }
            programs.ghostty.package
            self'.packages.helium-bin
            programs.vscode.package
            programs.nixcord.finalPackage.vesktop
            osPrograms.steam.package
          ]
          ++ maybeSpicetify;
        };
    };
}
