{
  flake.aspects.random-term = {
    homeManager =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        random-term = pkgs.writeShellApplication {
          name = "random-term";
          text = ''
            terminals=(
              ${lib.getExe config.programs.alacritty.package}
              ${lib.getExe config.programs.kitty.package}
              ${lib.getExe config.programs.ghostty.package}
              ${lib.getExe config.programs.wezterm.package}
            )
            exec "''${terminals[$((RANDOM % ''${#terminals[@]}))]}"
          '';
        };
      in
      {
        home.packages = [ random-term ];

        wayland.windowManager.hyprland.binds."SUPER + T".exec_cmd = "random-term";
      };
  };
}
