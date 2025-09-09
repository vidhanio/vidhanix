{ osConfig, ... }:
{
  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
    };
    hosts = {
      "github.com" = {
        git_protocol = "ssh";
        users.${osConfig.me.username} = { };
        user = osConfig.me.username;
      };
    };
  };
}
