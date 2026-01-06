{
  flake.modules.nixos.default =
    { config, ... }:
    {
      programs.nh = {
        enable = true;
        flake = "${config.users.users.vidhanio.home}/Projects/vidhanix";
        clean = {
          enable = true;
          dates = "weekly";
          extraArgs = "--keep ${toString config.boot.loader.systemd-boot.configurationLimit} --keep-since 7d";
        };
      };
    };
}
