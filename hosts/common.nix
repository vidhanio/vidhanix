{
  config,
  pkgs,
  inputs,
  ...
}:
let
  inherit (inputs) rust-overlay vidhanix-fonts;
in
{
  home-manager = {
    users.${config.me.username} = import ../users/${config.me.username};
    useUserPackages = true;
    useGlobalPkgs = true;
  };

  fonts.packages = with pkgs; [
    berkeley-mono-variable
    pragmata-pro-variable
    jetbrains-mono
  ];

  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      rust-overlay.overlays.default
      vidhanix-fonts.overlays.default
    ]
    ++ map (name: import ../overlays/${name}) (builtins.attrNames (builtins.readDir ../overlays));
  };
}
