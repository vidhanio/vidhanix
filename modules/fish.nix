{ pkgs, lib, ... }:
{
  flake.modules = {
    nixos.default = {
      users.defaultUserShell = pkgs.fish;
      programs.fish.enable = true;
    };

    homeManager.default = {
      programs.fish.enable = true;
    };
  };
}
