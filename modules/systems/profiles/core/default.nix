{
  flake.aspects =
    { aspects, ... }:
    {
      core.includes = with aspects; [
        nix
        home-manager
        sops
        disk
        impermanence
        swap
        boot
        locale
        network
        tailscale
        ssh-client
        ssh-server
        run0
        fish
        nh
        systemd
      ];
    };
}
