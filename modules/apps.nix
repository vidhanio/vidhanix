{ pkgs, lib, ... }:
{
  flake.modules.homeManager.default =
    homeManager:
    let
      inherit (lib) types;
      cfg = homeManager.config.apps;
      getApplicationsDir = pkg: "${pkg}/share/applications";
    in
    {
      options.apps =
        let
          app = types.submodule (
            { config, ... }:
            {
              options = {
                package = lib.mkOption {
                  description = "The package providing the application.";
                  type = types.package;
                };

                name =
                  let
                    getApplications = pkg: lib.attrNames (builtins.readDir (getApplicationsDir pkg));

                    applications = getApplications config.package;
                  in
                  lib.mkOption {
                    description = "The name of the application.";
                    type = types.addCheck types.str (name: lib.elem name applications);
                    default =
                      if (builtins.length applications) == 1 then
                        builtins.head applications
                      else
                        throw "apps.dock item \"${lib.getName config.package}\" has multiple applications (${
                          lib.concatStringsSep ", " (map (app: "\"${app}\"") applications)
                        }), name must be specified";
                  };
              };
            }
          );

          coercedApp = types.coercedTo types.package (package: {
            inherit package;
          }) app;
        in
        {
          autostart = lib.mkOption {
            type = types.listOf coercedApp;
            default = [ ];
            description = "List of applications to autostart.";
          };

          dock = lib.mkOption {
            type = types.listOf coercedApp;
            default = [ ];
            description = "List of applications to show in the dock.";
          };
        };

      config =
        let
          getPackages = map ({ package }: package);
          isHomePackage = pkg: lib.elem pkg homeManager.config.home.packages;
          isSystemPackage = pkg: lib.elem pkg homeManager.osConfig.environment.systemPackages;
          isInstalledPackage = pkg: isHomePackage pkg || isSystemPackage pkg;

          autostartEntries = map ({ package, name }: "${getApplicationsDir package}/${name}") cfg.autostart;

          favoriteApps = map ({ name }: name) cfg.dock;
        in
        {
          assertions = map (pkg: {
            assertion = isInstalledPackage pkg;
            message = "apps.autostart item \"${lib.getName pkg}\" is not in home.packages or environment.systemPackages";
          }) (getPackages cfg.autostart);

          xdg.autostart = {
            enable = lib.mkIf (cfg.autostart != [ ]) true;
            entries = autostartEntries;
          };

          dconf.settings."org/gnome/shell".favorite-apps = lib.mkIf (
            isInstalledPackage pkgs.gnome-shell && cfg.dock != [ ]
          ) favoriteApps;
        };
    };
}
