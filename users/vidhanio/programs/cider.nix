{ pkgs, lib, ... }:
let
  package = pkgs.cider-2.overrideAttrs rec {
    version = "3.1.1";
    src = pkgs.fetchurl {
      url = "https://repo.cider.sh/apt/pool/main/cider-v${version}-linux-x64.deb";
      hash = "sha256-2gd/ThI59GFU/lMKFLtwHeRWSqp14jFd8YMrV8Cu/oQ=";
    };
  };
in
{
  home.packages = [ package ];

  xdg.autostart.entries = map lib.getDesktop [ package ];

  impermanence.directories = [ ".config/sh.cider.genten" ];
}
