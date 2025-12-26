{ pkgs, ... }:
{
  flake.modules.homeManager.default = {
    home.packages = with pkgs; [ prismlauncher ];
  };
}
