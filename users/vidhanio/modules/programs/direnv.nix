{
  impermanence.directories = [ ".local/share/direnv/allow" ];

  programs.direnv = {
    enable = true;
    silent = true;
    nix-direnv.enable = true;
  };
}
