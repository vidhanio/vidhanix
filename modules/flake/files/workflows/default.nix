{
  config,
  flake-parts-lib,
  lib,
  ...
}:
let
  # `${{ ... }}` would parse as a nix interpolation, so build github
  # expression syntax from parts.
  ghExpr = name: "$" + "{{ ${name} }}";

  # hosts come from the built configurations, so the eval matrix stays in
  # sync with `configurations.<hostname>`. evaluation runs on any platform;
  # only builds need a matching runner. the full drvPath attr keeps the run
  # line short enough that remarshal does not fold the `${{ }}` expression.
  hosts = lib.mapAttrsToList (name: _cfg: {
    inherit name;
    attr = "nixosConfigurations.${name}.config.system.build.toplevel.drvPath";
  }) config.flake.nixosConfigurations;

  # shared setup for every nix job: checkout, the ssh key for the private
  # `vidhan-fonts` input, disk space for the store, the nix installer, and
  # a store cache keyed on the lockfile.
  nixSteps = [
    {
      name = "checkout";
      uses = "actions/checkout@v5";
    }
    {
      name = "setup ssh-agent";
      uses = "webfactory/ssh-agent@v0.9.0";
      "with" = {
        "ssh-private-key" = ghExpr "secrets.FONTS_SSH_KEY";
      };
    }
    # runner images ship ~20gb of bloat; reclaim it for /nix before installing
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
in
{
  options.perSystem = flake-parts-lib.mkPerSystemOption (
    { config, pkgs, ... }:
    let
      # the justfile recipes run inside the devshell, which pins just (and
      # the other tools) to the locked nixpkgs.
      just = "nix develop -c just";

      workflows = {
        ci = {
          name = "ci";

          on = {
            push = { };
            pull_request = { };
          };

          permissions = {
            # the store cache save needs actions: write
            contents = "read";
            actions = "write";
          };

          concurrency = {
            group = ghExpr "github.ref";
            "cancel-in-progress" = true;
          };

          jobs = {
            "check-formatting" = {
              name = "check formatting";
              "runs-on" = "ubuntu-latest";
              steps = nixSteps ++ [
                {
                  name = "check formatting";
                  run = "${just} fmt --ci";
                }
              ];
            };

            "check-generated-files" = {
              name = "check generated files";
              "runs-on" = "ubuntu-latest";
              steps = nixSteps ++ [
                {
                  name = "generate files";
                  run = "${just} generate";
                }
                {
                  name = "check diff";
                  run = "git diff --exit-code";
                }
              ];
            };

            "eval-systems" = {
              name = "eval system: ${ghExpr "matrix.name"}";
              "runs-on" = "ubuntu-latest";
              strategy = {
                matrix.include = hosts;
                "fail-fast" = false;
              };
              steps = nixSteps ++ [
                {
                  name = "eval system";
                  # forcing the toplevel drvPath evaluates the whole system
                  # config without building anything.
                  run = "nix eval .#${ghExpr "matrix.attr"} --raw";
                }
              ];
            };

            "build-packages" = {
              name = "build package: ${ghExpr "matrix.pkg"}";
              "runs-on" = "ubuntu-latest";
              strategy = {
                matrix.pkg = builtins.attrNames config.packages;
                "fail-fast" = false;
              };
              steps = nixSteps ++ [
                {
                  name = "build package";
                  run = "nix build .#packages.x86_64-linux.${ghExpr "matrix.pkg"} --print-build-logs";
                }
              ];
            };
          };
        };

        "watch-github-refs" = {
          name = "watch github refs";

          on = {
            schedule = [
              { cron = "0 9 * * 1"; }
            ];
            workflow_dispatch = { };
          };

          permissions = {
            issues = "write";
            contents = "read";
          };

          jobs.watch = {
            name = "watch github refs issues";
            "runs-on" = "ubuntu-latest";
            steps = [
              {
                name = "checkout";
                uses = "actions/checkout@v5";
              }
              {
                name = "scan and notify";
                run = "bash .github/scripts/watch-github-refs.sh";
              }
            ];
          };
        };
      };
    in
    {
      options.workflows = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = { };
        description = "GitHub Actions workflows to generate, one file per attr.";
      };

      config = {
        inherit workflows;

        # render with nixpkgs' yaml writer (remarshal) instead of a
        # hand-rolled emitter; commentedFile prepends the generated comment
        # and formats the result with treefmt.
        files.commentedFile = lib.mapAttrs' (
          name: workflow:
          lib.nameValuePair ".github/workflows/${name}.yml" {
            fileType = "yaml";
            source = pkgs.writers.writeYAML "${name}.yml" workflow;
          }
        ) workflows;
      };
    }
  );
}
