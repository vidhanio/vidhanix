{ inputs, ... }:
{
  flake-file.inputs.moonshine.url = "github:hgaiser/moonshine";

  configurations.vidhan-pc = {
    module =
      { config, pkgs, ... }:
      {
        imports = [ inputs.moonshine.nixosModules.default ];

        # Without seatd, a nested Hyprland launched by moonshine has no seatd
        # socket to connect to and no permission to run its own embedded
        # fallback, so it cannot open a GPU render node and crashes on start.
        services.seatd.enable = true;
        users.users.${config.users.primaryUser}.extraGroups = [ "seat" ];

        # moonshine.service is a plain system service, not part of any user
        # login session, so it has no XCURSOR_THEME/XCURSOR_SIZE. Its cursor
        # loader then looks for a theme literally named "default", finds
        # none, and falls back to a 1x1 pixel cursor.
        systemd.services.moonshine.environment = {
          XCURSOR_THEME = config.stylix.cursor.name;
          XCURSOR_SIZE = toString config.stylix.cursor.size;
        };

        services.moonshine = {
          enable = true;
          # No `package` override: the module's own default (`lib.mkDefault
          # self.packages.${system}.moonshine`) already tracks upstream
          # main, unlike nixpkgs' `pkgs.moonshine`, which is pinned to
          # release v0.13.5 — too old for a nested Hyprland (Aquamarine)
          # to bind wl_compositor v6 against without a fatal protocol error.
          user = config.users.primaryUser;
          # uid is not derivable: users are declared without a fixed uid, so
          # NixOS allocates it dynamically. Hardcoded to match the primary
          # user's actual allocated uid (verified with `id -u`).
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
                # Debugging the initServer crash: Hyprland's own log file
                # buffers its final fatal line and loses it on abort, so
                # route stdout/stderr to the journal instead.
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
