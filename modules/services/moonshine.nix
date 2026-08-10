{ inputs, ... }:
{
  flake-file.inputs.moonshine.url = "github:hgaiser/moonshine";

  configurations.vidhan-pc = {
    module =
      { config, pkgs, ... }:
      {
        imports = [ inputs.moonshine.nixosModules.default ];

        # Nested Hyprland needs a seatd socket; without it there's no render node and it crashes on start.
        services.seatd.enable = true;
        users.users.${config.users.primaryUser}.extraGroups = [ "seat" ];

        # Plain system service: no session env, so the cursor loader would fall back to a 1x1 "default" cursor.
        systemd.services.moonshine.environment = {
          XCURSOR_THEME = config.stylix.cursor.name;
          XCURSOR_SIZE = toString config.stylix.cursor.size;
        };

        services.moonshine = {
          enable = true;
          # No override: module default tracks upstream main; nixpkgs' v0.13.5 is too old for nested Hyprland (wl_compositor v6).
          user = config.users.primaryUser;
          # Users have no fixed uid; hardcoded to the primary user's (verified with `id -u`).
          uid = 1000;
          openFirewall = true;

          settings = {
            application = [
              {
                title = "Steam";
                command = [
                  "${config.programs.steam.package}/bin/steam"
                  "steam://open/bigpicture"
                ];
                # https://github.com/hgaiser/moonshine/blob/main/TIPS.md#close-a-desktop-steam-before-streaming-steam
                pre_command = [
                  [
                    "${pkgs.bash}/bin/bash"
                    "-c"
                    "if pgrep -x steam >/dev/null; then ${config.programs.steam.package}/bin/steam -shutdown &>/dev/null; for i in $(seq 1 30); do ! pgrep -x steam >/dev/null && break; sleep 1; done; fi"
                  ]
                ];
              }
              {
                title = "Hyprland";
                # https://github.com/hgaiser/moonshine/blob/main/TIPS.md#run-a-desktop-environment-for-a-full-remote-desktop
                command = [
                  "${
                    config.home-manager.users.${config.users.primaryUser}.wayland.windowManager.hyprland.package
                  }/bin/start-hyprland"
                ];
                # Hyprland's log loses its final line on abort; journal it instead.
                stdout = "journal";
                stderr = "journal";
              }
            ];
          };
        };
      };
    homeModule = {
      persist.directories = [
        ".config/moonshine"
        ".local/share/moonshine"
      ];
    };
  };
}
