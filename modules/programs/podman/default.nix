{
  flake.aspects.podman = {
    homeManager =
      { pkgs, ... }:
      {
        services.podman.enable = true;

        home.packages = [ pkgs.podman-compose ];

        persist.directories = [ ".local/share/containers" ];
      };
  };
}
