{ lib, ... }:
{
  profiles.pc.homeModule =
    {
      config,
      osConfig,
      pkgs,
      ...
    }:
    let
      capture = pkgs.writers.writeNuBin "desktop-capture" {
        makeWrapperArgs = [
          "--prefix"
          "PATH"
          ":"
          (lib.makeBinPath [
            pkgs.bash
            pkgs.grim
            pkgs.slurp
            pkgs.systemd
            pkgs.util-linux
            pkgs.wayfreeze
            pkgs.wl-clipboard
            osConfig.programs.gpu-screen-recorder.package
            osConfig.programs.hyprland.package
            osConfig.programs.niri.package
          ])
          "--set"
          "CAPTURE_DIRECTORY"
          "${config.home.homeDirectory}/Videos"
          "--set"
          "GSR_ENCODER"
          (if osConfig.hardware.asahi.enable or false then "cpu" else "gpu")
        ];
      } ./capture.nu;
    in
    {
      desktop.binds = {
        "Print".cmd = "${lib.getExe capture} screenshot";
        "SUPER + p".cmd = "${lib.getExe capture} screenshot";
        "SHIFT + Print".cmd = "${lib.getExe capture} record";
        "SUPER + SHIFT + p".cmd = "${lib.getExe capture} record";
        "SUPER + i".cmd = "${lib.getExe pkgs.hyprpicker} --autocopy";
      };
    };
}
