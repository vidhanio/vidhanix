{ flake-parts-lib, lib, ... }:
{
  options.perSystem = flake-parts-lib.mkPerSystemOption (
    { config, pkgs, ... }:
    {
      options.files.github = {
        workflows = lib.mkOption {
          type = lib.types.attrsOf lib.types.anything;
          default = { };
          description = "GitHub Actions workflows to generate, one file per attr.";
        };
        actions = lib.mkOption {
          type = lib.types.attrsOf lib.types.anything;
          default = { };
          description = "GitHub composite actions to generate, one directory per attr.";
        };
      };

      config = {
        # generated workflow and action files carry `${{ }}` expressions whose
        # quoting oxfmt normalizes differently than the generator; keep them verbatim.
        treefmt.programs.oxfmt.excludes = [
          ".github/workflows/*"
          ".github/actions/*"
        ];

        files.github.actions.setup-nix = config.files.lib.github.setupNixAction;

        files.commentedFile =
          lib.mapAttrs' (
            name: workflow:
            lib.nameValuePair ".github/workflows/${name}.yaml" {
              fileType = "yaml";
              source = pkgs.writers.writeYAML "${name}.yaml" workflow;
            }
          ) config.files.github.workflows
          // lib.mapAttrs' (
            name: action:
            lib.nameValuePair ".github/actions/${name}/action.yaml" {
              fileType = "yaml";
              source = pkgs.writers.writeYAML "github-action-${name}.yaml" action;
            }
          ) config.files.github.actions;
      };
    }
  );
}
