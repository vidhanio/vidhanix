{
  flake.modules = {
    nixos.default = {
      programs._1password-gui.enable = true;
    };
    homeManager.default = {
      persist.directories = [ ".config/1Password" ];
    };
  };
}
