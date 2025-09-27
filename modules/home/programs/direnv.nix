{ config, lib, ... }:
let
  cfg = config.programs.direnv;
in
{
  programs.direnv = {
    silent = true;
    nix-direnv.enable = true;
  };

  impermanence.directories = lib.mkIf cfg.enable [ ".local/share/direnv/allow" ];
}
