{
  lib,
  config,
  osConfig,
  pkgs,
  ...
}:
let
  inherit (lib) types;
  inherit (pkgs.stdenv) isDarwin;
  cfg = config.desktop;
in
{
  options.desktop =
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
                getApplications =
                  pkg:
                  let
                    dir = "${pkg}/${if isDarwin then "Applications" else "share/applications"}";
                  in
                  lib.attrNames (builtins.readDir dir);

                applications = getApplications config.package;
              in
              lib.mkOption {
                description = "The name of the application.";
                type = types.addCheck types.str (name: lib.elem name applications);
                default =
                  if (builtins.length applications) == 1 then
                    builtins.head applications
                  else
                    throw "desktop.dock item \"${lib.getName config.package}\" has multiple applications (${
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
      getPackages = map ({ package, name }: package);
      isHomePackage = pkg: lib.elem pkg config.home.packages;
      isSystemPackage = pkg: lib.elem pkg osConfig.environment.systemPackages;
      isInstalledPackage = pkg: isHomePackage pkg || isSystemPackage pkg;

      autostart =
        let
        in
        { };

      dock =
        let
          packages = getPackages cfg.dock;

          files = map (item: item.name) cfg.dock;
        in
        lib.mkMerge [
          {
            assertions = map (pkg: {
              assertion = isInstalledPackage pkg;
              message = "desktop.dock item \"${lib.getName pkg}\" is not in home.packages or environment.systemPackages";
            }) packages;
          }
          (lib.mkIf (isInstalledPackage pkgs.gnome-shell) {
            dconf.settings."org/gnome/shell".favorite-apps = files;
          })
        ];
    in
    lib.mkMerge [
      (lib.mkIf (cfg.autostart != [ ]) autostart)
      (lib.mkIf (cfg.dock != [ ]) dock)
    ];
}
