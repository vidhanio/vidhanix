{
  lib,
  inputs,
  ...
}:
{
  imports =
    with inputs;
    [ agenix.homeManagerModules.default ]
    ++ [
      ../modules/impermanence.nix
      ../modules/link-darwin-applications.nix
    ]
    ++ lib.readDirToList ./modules;

  home = {
    file = {
      ".hushlogin".text = "";
    };
  };

  impermanence = {
    directories = [
      "Documents"
      "Downloads"
      "Projects"

      ".ssh"
    ];
  };

  home.stateVersion = "25.05";
}
