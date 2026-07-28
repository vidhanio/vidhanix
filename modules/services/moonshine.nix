{ inputs, ... }:
{
  flake-file.inputs.moonshine.url = "github:hgaiser/moonshine";

  configurations.vidhan-pc = {
    module =
      { config, pkgs, ... }:
      {
        imports = [ inputs.moonshine.nixosModules.default ];

        services.moonshine = {
          enable = true;
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
