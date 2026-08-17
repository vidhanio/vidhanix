{
  flake.aspects.minecraft.homeManager = _: {
    programs.prismlauncher.enable = true;

    persist.directories = [ ".local/share/PrismLauncher" ];
  };
}
