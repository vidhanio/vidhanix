{
  flake.aspects.delta-db = {
    homeManager = {
      programs.delta-db.enable = true;

      persist.directories = [
        ".config/delta"
        ".local/share/delta"
      ];
    };
  };
}
