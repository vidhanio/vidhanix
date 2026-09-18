{
  flake.aspects.lazygit = {
    homeManager = {
      programs.lazygit = {
        enable = true;
        settings.gui.border = "single";
      };

      persist.directories = [ ".local/state/lazygit" ];
    };
  };
}
