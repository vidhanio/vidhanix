{
  flake.aspects."1password" = {
    nixos = {
      programs._1password-gui.enable = true;
    };
    homeManager = {
      persist.directories = [ ".config/1Password" ];
    };
  };
}
