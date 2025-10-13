{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  environment = {
    systemPackages = with pkgs; [
      neovim
    ];

    variables = {
      EDITOR = "nvim";
    };

    shellAliases = {
      vi = "nvim";
    };
  };

  nix.registry =
    let
      flakes = lib.filterAttrs (_: input: input ? _type && input._type == "flake") inputs;
    in
    builtins.mapAttrs (_: flake: { inherit flake; }) flakes;

  programs.ssh.knownHosts."github.com".publicKey =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
}
