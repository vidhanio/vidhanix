{
  lib,
  inputs,
  pkgs,
  ...
}:
{
  imports = with inputs; [ agenix.homeManagerModules.default ] ++ lib.readSubmodules ./.;

  home = {
    file = {
      ".hushlogin".text = "";
      ".face".source = pkgs.fetchurl {
        url = "https://github.com/vidhanio.png";
        sha256 = "sha256-ihQAIrfg5L1k1AUWo6Ga7ZuGI00Rha4KaTOowUeCp/E=";
      };
    };
  };

  impermanence = {
    directories = [
      "Downloads"
      "Projects"

      ".cache/nix"
      ".local/share/Trash"
    ];
  };

  home.stateVersion = "25.05";
}
