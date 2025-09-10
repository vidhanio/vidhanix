{ lib, ... }:
{
  imports = lib.readCurrentDir ./.;

  programs = {
    home-manager.enable = true;

    neovim.enable = true;
    uv.enable = true;
  };
}
