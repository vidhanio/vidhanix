{ lib, ... }:
let
  renderModeArg =
    monitor:
    lib.optionalString (monitor.mode != null)
      " --mode ${lib.escapeShellArg "${toString monitor.mode.width}x${toString monitor.mode.height}@${lib.strings.floatToString monitor.mode.refreshRate}Hz"}";
  renderMainCommand =
    pkgs: monitor:
    let
      position = "${toString monitor.position.x},${toString monitor.position.y}";
    in
    "${pkgs.wlr-randr}/bin/wlr-randr --output ${lib.escapeShellArg monitor.name}${renderModeArg monitor} --pos ${lib.escapeShellArg position} --scale ${lib.escapeShellArg (lib.strings.floatToString monitor.scale)}";
  renderOffCommand =
    pkgs: monitor: "${pkgs.wlr-randr}/bin/wlr-randr --output ${lib.escapeShellArg monitor.name} --off";
  renderCommands =
    pkgs: monitors:
    lib.concatStringsSep "\n" (
      [ (renderMainCommand pkgs monitors.main) ] ++ map (renderOffCommand pkgs) monitors.others
    );
  mkRegreetWrapper =
    { pkgs }:
    commands:
    pkgs.symlinkJoin {
      inherit (pkgs.regreet) pname version meta;

      paths = [ pkgs.regreet ];
      postBuild = ''
        mv $out/bin/regreet $out/bin/.regreet-wrapped

        echo "#! ${pkgs.stdenvNoCC.shell} -e" > $out/bin/regreet
        echo ${lib.escapeShellArg commands} >> $out/bin/regreet
        echo "exec -a \"\$0\" $out/bin/.regreet-wrapped \"\$@\"" >> $out/bin/regreet
        chmod +x $out/bin/regreet
      '';
    };
in
{
  flake.modules.nixos.default =
    { config, pkgs, ... }:
    {
      programs.regreet = {
        enable = true;
        package = mkRegreetWrapper { inherit pkgs; } (renderCommands pkgs config.hardware.monitors);
      };
    };
}
