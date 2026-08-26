{
  flake.aspects.agents = {
    homeManager = {
      programs.agents.context = ''
        This NixOS machine is configured declaratively via the `vidhanix` flake
        at `~/Projects/vidhanix`. Prefer declarative changes in that repo over
        one-off system commands or manual configuration changes.
      '';
    };
  };
}
