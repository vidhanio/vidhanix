{
  programs.direnv = {
    enable = true;
    silent = true;
    nix-direnv.enable = true;
  };

  impermanence.directories = [ ".local/share/direnv/allow" ];
}
