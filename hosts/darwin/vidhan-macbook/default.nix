{ pkgs, ... }:
let
  username = "vidhanio";
in
{
  nixpkgs.hostPlatform = "aarch64-darwin";

  users = {
    users.${username} = {
      description = "Vidhan Bhatt";

      home = "/Users/${username}";
      createHome = true;
      shell = pkgs.fish;
      uid = 501;
    };

    knownUsers = [ username ];
  };

  system.stateVersion = 6;
}
