{ lib, ... }:

{
  den.default.nixos =
    { config, pkgs, ... }:
    let
      gamescopeFullscreen = pkgs.symlinkJoin {
        pname = "gamescope-fullscreen";
        inherit (pkgs.gamescope) version;

        meta = pkgs.gamescope.meta // {
          mainProgram = "gamescope-fullscreen";
        };

        paths = with pkgs; [ gamescope ];

        nativeBuildInputs = with pkgs; [ makeWrapper ];

        postBuild =
          let
            inherit (config.hardware.monitors.main) mode name;
            gamescopeArgs =
              lib.optionals (mode != null) [
                "-W"
                (toString mode.width)
                "-H"
                (toString mode.height)
                "-r"
                (toString mode.refreshRateInt)
              ]
              ++ [
                "--prefer-output"
                name
                "--adaptive-sync"
                "--fullscreen"
                "--scaler"
                "stretch"
              ];
          in
          ''
            makeWrapper $out/bin/gamescope $out/bin/gamescope-fullscreen \
              --add-flags ${lib.escapeShellArg (lib.escapeShellArgs gamescopeArgs)}
          '';
      };
    in
    {
      programs.gamescope = {
        enable = true;
        enableWsi = true;
      };

      environment.systemPackages = [ gamescopeFullscreen ];

      programs.steam = {
        extraPackages = [
          config.programs.gamescope.package
          gamescopeFullscreen
        ];
      };
    };
}
