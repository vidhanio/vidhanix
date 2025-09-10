{ config, ... }:
{
  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
    };
    hosts = {
      "github.com" = {
        git_protocol = "ssh";
        users.${config.home.username} = { };
        user = config.home.username;
      };
    };
  };
}
