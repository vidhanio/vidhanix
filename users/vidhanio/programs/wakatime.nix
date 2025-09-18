{ pkgs, ... }:
{
  home.packages = with pkgs; [ wakatime ];

  age.secrets.wakatime = {
    file = ../../../secrets/wakatime.age;
    path = ".wakatime.cfg";
  };
}
