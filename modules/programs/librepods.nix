{ lib, ... }:
{
  flake-file.inputs.librepods.url = "github:kavishdevar/librepods/linux/rust";

  flake.modules = {
    nixos.default =
      { inputs', ... }:
      let
        pkg = inputs'.librepods.packages.default;
      in
      {
        environment.systemPackages = [ pkg ];

        systemd.user.services.librepods = {
          description = "AirPods liberated from Apple's ecosystem";

          after = [
            "bluetooth.target"
            "pipewire.service"
          ];
          wants = [ "bluetooth.target" ];
          wantedBy = [ "default.target" ];

          serviceConfig = {
            ExecStart = "${lib.getExe pkg} --start-minimized";
            Restart = "on-failure";
            RestartSec = 5;
          };
        };
      };
  };
}
