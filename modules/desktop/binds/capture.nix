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
      capture = pkgs.writers.writePython3Bin "desktop-capture" {
        flakeIgnore = [
          "E501"
          "W503"
        ];
        makeWrapperArgs = [
          "--prefix"
          "PATH"
          ":"
          (lib.makeBinPath [
            pkgs.grim
            pkgs.hyprpicker
            pkgs.slurp
            pkgs.systemd
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
      } ./capture.py;
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
