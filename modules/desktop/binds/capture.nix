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
      useGsr = osConfig.programs.gpu-screen-recorder.enable;
      recorder = if useGsr then osConfig.programs.gpu-screen-recorder.package else pkgs.wl-screenrec;
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
            osConfig.programs.hyprland.package
            osConfig.programs.niri.package
          ])
          "--set"
          "CAPTURE_BACKEND"
          (if useGsr then "gsr" else "wl-screenrec")
          "--set"
          "CAPTURE_RECORDER"
          (lib.getExe recorder)
          "--set"
          "CAPTURE_DIRECTORY"
          "${config.home.homeDirectory}/Videos"
          "--set"
          "CAPTURE_SOFTWARE"
          (lib.boolToString (osConfig.hardware.asahi.enable or false))
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
