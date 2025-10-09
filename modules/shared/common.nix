{ pkgs, ... }:
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

  programs.ssh.knownHosts."github.com".publicKey =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
}
