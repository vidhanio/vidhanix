{ pkgs, ... }:
{
  flake.modules.homeManager.default = {
    home.packages = with pkgs; [ prismlauncher ];

    persist.directories = [ ".local/share/PrismLauncher" ];
  };
}
