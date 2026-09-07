{
  flake.aspects.nushell = {
    homeManager = {
      persist.directories = [ ".local/share/nushell" ];
    };
  };
}
