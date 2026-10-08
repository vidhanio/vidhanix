{
  profiles.pc = {
    homeModule = {
      programs.prismlauncher.enable = true;

      xdg.mimeApps.associations.removed."application/zip" = "org.prismlauncher.PrismLauncher.desktop";

      persist.directories = [ ".local/share/PrismLauncher" ];
    };
  };
}
