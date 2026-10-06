{
  profiles.pc = {
    module = {
      programs._1password-gui.enable = true;
    };
    homeModule = {
      persist.directories = [ ".config/1Password" ];
    };
  };
}
