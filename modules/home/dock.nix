{
  lib,
  config,
  osConfig,
  pkgs,
  ...
}:
let
  inherit (lib) types;
  inherit (osConfig.nixpkgs.hostPlatform) isDarwin;
  cfg = config.dock;
  getApplications =
    pkg:
    let
      dir = "${pkg}/${if isDarwin then "Applications" else "share/applications"}";
    in
    lib.attrNames (builtins.readDir dir);
in
{
  options.dock =
    let
      packageWithName = types.submodule (
        { config, ... }:
        {
          options = {
            package = lib.mkOption {
              description = "The package providing the application.";
              type = types.package;
            };

            name =
              let
                applications = getApplications config.package;
              in
              lib.mkOption {
                description = "The name of the application.";
                type = types.str // {
                  check = name: lib.elem name applications;
                };
                default =
                  if (builtins.length applications) == 1 then
                    builtins.head applications
                  else
                    throw "dock item '${lib.getName config.package}' has multiple applications (${lib.concatStringsSep ", " applications}), name must be specified";
              };
          };
        }
      );

      package = types.coercedTo types.package (package: {
        inherit package;
      }) packageWithName;

      dockItem = types.either types.str package;
    in
    lib.mkOption {
      type = types.listOf dockItem;
      default = [ ];
      description = "List of applications to show in the dock.";
    };

  config =
    let
      isHomePackage = pkg: lib.elem pkg config.home.packages;
      isSystemPackage = pkg: lib.elem pkg osConfig.environment.systemPackages;
      isInstalledPackage = pkg: isHomePackage pkg || isSystemPackage pkg;

      packages = map ({ package, name }: package) (lib.filter lib.isAttrs cfg);

      toAppFiles =
        { package, name }:
        if isDarwin then
          (
            if isHomePackage package then
              "${config.home.homeDirectory}/Applications/Home Manager Apps/${name}"
            else if isSystemPackage package then
              "/Applications/Nix Apps/${name}"
            else
              throw "unreachable (checked in assertions)"
          )
        else
          name;

      appFiles = map (item: if lib.isAttrs item then toAppFiles item else item) cfg;
    in
    lib.mkIf (cfg != [ ]) (
      lib.mkMerge [
        {
          assertions = map (pkg: {
            assertion = isInstalledPackage pkg;
            message = "dock item '${lib.getName pkg}' is not in home.packages or environment.systemPackages";
          }) packages;
        }
        (lib.mkIf isDarwin {
          targets.darwin.defaults."com.apple.dock".persistent-apps = map (path: {
            tile-data.file-data = {
              _CFURLString = path;
              _CFURLStringType = 0;
            };
          }) appFiles;

          home.activation = {
            checkDockApps = lib.hm.dag.entryBetween [ "linkApps" ] [ "setDarwinDefaults" ] ''
              for app in ${lib.escapeShellArgs appFiles}; do
                if [[ ! -e "$app" ]]; then
                  printf >&2 '\e[1;31merror: dock item "%s" does not exist, aborting activation\e[0m\n' "$app"
                  exit 1
                fi
              done
            '';

            updateDock = lib.hm.dag.entryAfter [ "setDarwinDefaults" ] ''
              /usr/bin/killall Dock || true
            '';
          };
        })
        (lib.mkIf (isInstalledPackage pkgs.gnome-shell) {
          dconf.settings."org/gnome/shell".favorite-apps = appFiles;
        })
      ]
    );
}
