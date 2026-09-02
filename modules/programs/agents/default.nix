{
  flake.aspects.agents = {
    homeManager = {
      programs.agents = {
        models = {
          large = {
            provider = "openai-codex";
            model = "gpt-5.6-luna";
            thinking = "max";
          };
          small = {
            provider = "openai-codex";
            model = "gpt-5.6-luna";
            thinking = "max";
          };
        };

        context = ''
          # AGENTS.md

          ## NixOS

          This NixOS machine is configured declaratively via the `vidhanix` flake
          at `~/Projects/vidhanix`.

          Prefer declarative changes in that repo over one-off system commands or
          manual configuration changes.

          Use `nix shell nixpkgs#<pkg> -c <command>` to run any tools you can't
          find in your `$PATH`.

          If working on a project with a nix dev shell, ensure it is loaded by
          running `direnv reload`.
        '';
      };
    };
  };
}
