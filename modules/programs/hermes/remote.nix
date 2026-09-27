{
  flake.aspects.hermes.provides.remote = {
    homeManager = _: {
      xdg.configFile."Hermes/connection.json".text = builtins.toJSON {
        mode = "ssh";

        remote = {
          mode = "ssh";
          host = "vortex";
        };
      };
    };
  };
}
