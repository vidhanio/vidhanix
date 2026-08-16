{ flake-parts-lib, lib, ... }:
let
  # `${{ ... }}` would parse as a nix interpolation, so build github
  # expression syntax from parts.
  ghExpr = name: "$" + "{{ ${name} }}";

  setupNixAction = {
    name = "setup nix";
    description = "install nix and prepare the runner for a nix job";
    inputs.ssh-private-key = {
      description = "ssh key for private flake inputs";
      required = true;
    };
    runs = {
      using = "composite";
      steps = [
        {
          name = "setup ssh-agent";
          uses = "webfactory/ssh-agent@v0.9.0";
          "with" = {
            ssh-private-key = ghExpr "inputs.ssh-private-key";
          };
        }
        {
          name = "free disk space";
          uses = "wimpysworld/nothing-but-nix@v9";
        }
        {
          name = "install nix";
          uses = "cachix/install-nix-action@v31";
          "with".nix_path = "path: nixpkgs=channel:nixos-unstable";
        }
        {
          name = "restore nix store";
          uses = "nix-community/cache-nix-action@v7";
          "with" = {
            primary-key = "nix-${ghExpr "runner.os"}-${ghExpr "hashFiles('**/flake.lock')"}";
            restore-prefixes-first-match = "nix-${ghExpr "runner.os"}-";
          };
        }
      ];
    };
  };
in
{
  options.perSystem = flake-parts-lib.mkPerSystemOption (
    { config, pkgs, ... }:
    {
      options.files = {
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

        files.actions.setup-nix = setupNixAction;

        files.commentedFile =
          lib.mapAttrs' (
            name: workflow:
            lib.nameValuePair ".github/workflows/${name}.yaml" {
              fileType = "yaml";
              source = pkgs.writers.writeYAML "${name}.yaml" workflow;
            }
          ) config.files.workflows
          // lib.mapAttrs' (
            name: action:
            lib.nameValuePair ".github/actions/${name}/action.yaml" {
              fileType = "yaml";
              source = pkgs.writers.writeYAML "github-action-${name}.yaml" action;
            }
          ) config.files.actions;
      };
    }
  );
}
