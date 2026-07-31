{ lib, ... }:
{
  flake.modules.nixos.default =
    { config, pkgs, ... }:

    let
      renderMainArgs =
        monitor:
        [
          "${pkgs.wlr-randr}/bin/wlr-randr"
          "--output"
          monitor.name
        ]
        ++ lib.optionals (monitor.mode != null) [
          "--mode"
          "${toString monitor.mode.width}x${toString monitor.mode.height}@${lib.strings.floatToString monitor.mode.refreshRate}Hz"
        ]
        ++ [
          "--pos"
          "${toString monitor.position.x},${toString monitor.position.y}"
          "--scale"
          (lib.strings.floatToString monitor.scale)
        ];

      renderOffArgs = monitor: [
        "${pkgs.wlr-randr}/bin/wlr-randr"
        "--output"
        monitor.name
        "--off"
      ];

      renderCommands = monitors: [ (renderMainArgs monitors.main) ] ++ map renderOffArgs monitors.others;

      mkRegreetWrapper =
        commands:
        pkgs.symlinkJoin {
          inherit (pkgs.regreet) pname version meta;

          paths = with pkgs; [ regreet ];

          nativeBuildInputs = with pkgs; [ makeWrapper ];

          postBuild = ''
            wrapProgram $out/bin/regreet \
              ${lib.concatMapStringsSep " \\\n" (
                command: "--run ${lib.escapeShellArg (lib.escapeShellArgs command)}"
              ) commands}
          '';
        };
    in
    {
      services.displayManager.regreet = {
        enable = true;
        package = mkRegreetWrapper (renderCommands config.hardware.monitors);
      };

      services.greetd.settings.initial_session = {
        command = "uwsm start hyprland.desktop";
        user = config.users.primaryUser;
      };
    };
}
