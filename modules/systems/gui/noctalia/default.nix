{
  flake.aspects.noctalia = {
    nixos = {
      programs.noctalia = {
        enable = true;
        recommendedServices.enable = true;
      };
    };

    homeManager = {
      programs.noctalia = {
        enable = true;
        systemd.enable = true;
      };

      persist.directories = [ ".local/state/noctalia" ];
      systemd.user.tmpfiles.rules = [
        "r %h/.local/state/noctalia/settings.toml" # get rid of imperative settings
      ];
    };
  };
}
