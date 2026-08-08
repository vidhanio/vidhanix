{
  flake.modules.homeManager.default = _: {
    programs.prismlauncher.enable = true;

    persist.directories = [ ".local/share/PrismLauncher" ];
  };
}
