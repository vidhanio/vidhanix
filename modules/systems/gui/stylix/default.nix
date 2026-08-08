{
  inputs,
  ...
}:
{
  flake-file.inputs.stylix.url = "github:nix-community/stylix";
  flake-file.prune-lock.ignore = [ "stylix" ];

  flake.modules.nixos.default = {
    imports = [ inputs.stylix.nixosModules.default ];

    stylix = {
      enable = true;
      polarity = "dark";
      base16Scheme = ./scheme.yaml;
    };
  };
}
