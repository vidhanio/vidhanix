{ pkgs, ... }:
{
  flake.modules.nixos.default = {
    systemPackages = with pkgs; [
      wl-clipboard
    ];
  };
}
