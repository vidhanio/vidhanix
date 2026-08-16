{ flake-parts-lib, lib, ... }:
let
  # `${{ ... }}` would parse as a nix interpolation, so build github
  # expression syntax from parts.
  ghExpr = name: "$" + "{{ ${name} }}";

  setupNixAction = {
    name = "setup nix";
    description = "install nix and prepare the runner for a nix job";
    inputs."ssh-private-key" = {
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
            "ssh-private-key" = ghExpr "inputs.ssh-private-key";
          };
        }
        {
          name = "free disk space";
          uses = "wimpysworld/nothing-but-nix@v9";
        }
        {
          name = "install nix";
          uses = "cachix/install-nix-action@v31";
        }
        {
          name = "restore nix store";
          uses = "nix-community/cache-nix-action@v7";
          "with" = {
            "primary-key" = "nix-${ghExpr "runner.os"}-${ghExpr "hashFiles('**/flake.lock')"}";
            "restore-prefixes-first-match" = "nix-${ghExpr "runner.os"}-";
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
      options.workflows = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = { };
        description = "GitHub Actions workflows to generate, one file per attr.";
      };

      config = {
        treefmt.programs.actionlint.enable = true;
        # generated workflow and action files carry `${{ }}` expressions whose
        # quoting oxfmt normalizes differently than the generator; keep them verbatim.
        treefmt.programs.oxfmt.excludes = [
          ".github/workflows/*"
          ".github/actions/*"
        ];

        # render with nixpkgs' yaml writer (remarshal) instead of a
        # hand-rolled emitter; commentedFile prepends the generated comment
        # and formats the result with treefmt.
        files.commentedFile =
          lib.mapAttrs' (
            name: workflow:
            lib.nameValuePair ".github/workflows/${name}.yaml" {
              fileType = "yaml";
              source = pkgs.writers.writeYAML "${name}.yaml" workflow;
            }
          ) config.workflows
          // {
            ".github/actions/setup-nix/action.yaml" = {
              fileType = "yaml";
              source = pkgs.writers.writeYAML "setup-nix-action.yaml" setupNixAction;
            };
          };
      };
    }
  );
}
