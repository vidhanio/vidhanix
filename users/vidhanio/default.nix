{
  lib,
  pkgs,
  ...
}:
{
  imports = lib.readSubmodules ./.;

  home = {
    file = {
      ".hushlogin".text = "";
      ".face".source = pkgs.fetchurl {
        url = "https://github.com/vidhanio.png";
        sha256 = "sha256-ihQAIrfg5L1k1AUWo6Ga7ZuGI00Rha4KaTOowUeCp/E=";
      };
    };
  };

  age.secrets.wakatime = {
    file = ../../secrets/wakatime.age;
    path = ".wakatime.cfg";
  };

  impermanence = {
    directories = [
      "Downloads"
      "Projects"

      ".cache/nix"
    ];
  };

  home.stateVersion = "25.05";
}
