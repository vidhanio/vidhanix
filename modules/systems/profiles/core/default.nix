{
  flake.aspects =
    { aspects, ... }:
    {
      core.includes = with aspects; [
        # keep-sorted start
        automatic-timezoned
        boot
        disk
        fish
        home-manager
        impermanence
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
