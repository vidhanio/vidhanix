{
  flake.modules = {
    nixos.default =
      { pkgs, ... }:
      {
        environment.systemPackages = [
          pkgs.brightnessctl
        ];
      };
    homeManager.default = {
      wayland.windowManager.hyprland.settings.bindel = [
        ", XF86MonBrightnessDown, exec, brightnessctl s 10%-"
        ", XF86MonBrightnessUp, exec, brightnessctl s +10%"
      ];
    };
  };
}
