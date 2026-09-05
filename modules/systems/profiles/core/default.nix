{
  flake.aspects =
    { aspects, ... }:
    {
      core.includes = with aspects; [
        # keep-sorted start
        automatic-timezoned
        boot
        disk
        disk.provides.impermanence
        fish
        home-manager
        locale
        network
        nh
        nix
        run0
        sops
        ssh-client
        ssh-server
        swap
        systemd
        tailscale
        # keep-sorted end
      ];
    };
}
