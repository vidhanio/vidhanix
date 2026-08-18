{
  flake.aspects.minecraft.homeManager = {
    programs.prismlauncher.enable = true;

    persist.directories = [ ".local/share/PrismLauncher" ];
  };
}
