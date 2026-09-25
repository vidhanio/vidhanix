{
  flake.aspects.agents = {
    homeManager = {
      programs.agents = {
        models = {
          default = {
            provider = "opencode-go";
            model = "deepseek-v4.1-flash";
            thinking = "max";
          };
          small = {
            provider = "opencode-go";
            model = "deepseek-v4.1-flash";
            thinking = "max";
          };
          large = {
            provider = "openai-codex";
            model = "gpt-6-sol";
            thinking = "medium";
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
