{ inputs, ... }: {
  flake-file.inputs.mattpocock-skills = {
    url = "github:mattpocock/skills";
    flake = false;
  };
  flake.aspects.agents = {
    homeManager = {
      programs.agents = {
        models = {
          large = {
            provider = "openai-codex";
            model = "gpt-5.6-sol";
            thinking = "medium";
          };
          small = {
            provider = "openai-codex";
            model = "gpt-5.6-luna";
            thinking = "max";
          };
        };

        context = ''
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
        skills = {
          grill-me = "${inputs.mattpocock-skills}/skills/productivity/grill-me";
          grilling = "${inputs.mattpocock-skills}/skills/productivity/grilling";
        };
      };
    };
  };
}
