{ lib, ... }:
{
  flake.modules.homeManager.default =
    {
      config,
      osConfig,
      pkgs,
      ...
    }:
    let
      cfg = config.apps;
    in
    {
      options.apps =
        let
          app = lib.types.submodule (
            { config, ... }:
            {
              options = {
                package = lib.mkOption {
                  description = "The package providing the application.";
                  type = lib.types.package;
                };

                name = lib.mkOption {
                  description = "The name of the application's .desktop file (without the .desktop extension).";
                  type = lib.types.str;
                  default = config.package.meta.mainProgram;
                };
              };
            }
          );

          coercedApp = lib.types.coercedTo lib.types.package (package: {
            inherit package;
          }) app;
        in
        {
          autostart = lib.mkOption {
            type = lib.types.listOf coercedApp;
            default = [ ];
            description = "List of applications to autostart.";
          };

          dock = lib.mkOption {
            type = lib.types.listOf coercedApp;
            default = [ ];
            description = "List of applications to show in the dock.";
          };
        };

      config =
        let
          isHomePackage = pkg: lib.elem pkg config.home.packages;
          isSystemPackage = pkg: lib.elem pkg osConfig.environment.systemPackages;
          isInstalledPackage = pkg: isHomePackage pkg || isSystemPackage pkg;

          mkAssertions =
            option:
            map (
              { package, ... }:
              {
                assertion = isInstalledPackage package;
                message = "apps.${option} item \"${lib.getName package}\" is not in home.packages or environment.systemPackages";
              }
            ) cfg.${option};
        in
        {
          assertions = (mkAssertions "autostart") ++ (mkAssertions "dock");

          xdg.autostart = {
            enable = lib.mkIf (cfg.autostart != [ ]) true;
            entries = map ({ package, name }: "${package}/share/applications/${name}.desktop") cfg.autostart;
          };
          dconf.settings."org/gnome/shell" =
            lib.mkIf (isInstalledPackage pkgs.gnome-shell && cfg.dock != [ ])
              {
                favorite-apps = map ({ name, ... }: "${name}.desktop") cfg.dock;
              };
        };
    };
}
