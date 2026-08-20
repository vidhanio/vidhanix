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
        automatic-timezoned
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
