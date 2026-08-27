{
  flake.aspects.agents = {
    homeManager = {
      programs.agents.context = ''
        # AGENTS.md

        ## NixOS Configuration
        This NixOS machine is configured declaratively via the `vidhanix` flake
        at `~/Projects/vidhanix`. Prefer declarative changes in that repo over
        one-off system commands or manual configuration changes.

        ## Open Source Contributions
        Always read `CONTRIBUTING.md` and other relevant documentation before
        writing any code.
        Never open issues or pull requests to others' repos yourself.
        Use `gh issue create --web`/`gh pr create --web` with `--title`/`--body`
        to prepare the content and have the user review and submit it.
      '';
    };
  };
}
