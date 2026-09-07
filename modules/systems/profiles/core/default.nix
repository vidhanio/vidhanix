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
        home-manager
        locale
        network
        nh
        nix
        nushell
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
