{
  flake.modules.nixos.default = {
    programs._1password-gui.enable = true;

    persist.directories = [ ".config/1Password" ];
  };
}
