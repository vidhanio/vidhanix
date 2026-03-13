{ lib, ... }:
{
  flake.modules = {
    nixos.default =
      { pkgs, ... }:
      {
        programs.regreet.enable = true;

        services.greetd.settings.initial_session = {
          command = "uwsm start -e -D Hyprland ${pkgs.hyprland}/share/wayland-sessions/hyprland.desktop";
          user = "vidhanio";
        };
      };
  };

  configurations =
    let
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
      vidhan-pc.module =
        { pkgs, ... }:
        {
          programs.regreet.package = mkRegreetWrapper { inherit pkgs; } ''
            ${pkgs.wlr-randr}/bin/wlr-randr --output DP-1 --mode 2560x1440@300.002014Hz --adaptive-sync enabled
            ${pkgs.wlr-randr}/bin/wlr-randr --output HDMI-A-1 --off
          '';
        };
      vidhan-macbook.module =
        { pkgs, ... }:
        {
          programs.regreet.package = mkRegreetWrapper { inherit pkgs; } ''
            ${pkgs.wlr-randr}/bin/wlr-randr --output eDP-1 --scale 1.6
          '';
        };
    };
}
