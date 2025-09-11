{ pkgs, ... }: let username = "vidhanio"; in {
  nixpkgs.hostPlatform = "aarch64-darwin";

  users.users.${username} = {
    description = "Vidhan Bhatt";

    home = "/Users/${username}";
    createHome = true;
    shell = with pkgs; fish;
  };

  programs = {
    fish.enable = true;
  };

  system.stateVersion = 6;
}