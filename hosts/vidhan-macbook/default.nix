{ pkgs, ... }:
let
  username = "vidhanio";
in
{
  nixpkgs.hostPlatform = "aarch64-darwin";

  users = {
    users.${username} = {
      uid = 501;

      description = "Vidhan Bhatt";

      home = "/Users/${username}";
      createHome = true;
      shell = pkgs.fish;
    };

    knownUsers = [ username ];
  };

  programs = {
    fish.enable = true;
  };

  system.stateVersion = 6;
}
