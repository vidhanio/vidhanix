{ inputs, ... }:
{
  profiles.pc = {
    homeModule = {
      agents = {
        skills.bundles = [ "${inputs.beautiful-rust}/skills" ];

        models = {
          presets = {
            default = {
              provider = "anthropic";
              model = "claude-opus-5.5";
              thinking = "medium";
            };
            reviewer = {
              provider = "openai";
              model = "gpt-6.1-terra";
              thinking = "xhigh";
            };
            small = {
              provider = "opencode-go";
              model = "deepseek-v4.1-flash";
              thinking = "max";
            };
          };

          override = {
            opencode-go."deepseek-v4.1-flash".context = 200000;
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
