{
  flake.modules.homeManager.default = {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    persist.directories = [
      ".local/share/direnv/allow"
    ];
  };
}
