{
  flake.aspects.nh.nixos =
    { config, ... }:
    {
      programs.nh = {
        enable = true;
        flake = "${config.users.users.vidhanio.home}/Projects/vidhanix";
        clean = {
          enable = true;
          extraArgs = "--keep 5 --keep-since 3d";
        };
      };
    };
}
