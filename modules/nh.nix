{ config, ... }:
{
  programs.nh = {
    enable = true;
    flake = "${config.users.users.vidhanio.home}/Projects/vidhanix";
  };
}
