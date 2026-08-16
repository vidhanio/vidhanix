{ flake-parts-lib, ... }:
{
  options.perSystem = flake-parts-lib.mkPerSystemOption (
    _:
    let
      # `${{ ... }}` would parse as a nix interpolation, so build github
      # expression syntax from parts.
      ghExpr = name: "$" + "{{ ${name} }}";
    in
    {
      config.files.workflows.nix = {
        name = "nix";

        on.workflow_call = {
          inputs = {
            name = {
              type = "string";
              default = "nix job";
            };
            command = {
              type = "string";
              required = true;
            };
            ref = {
              type = "string";
              default = "";
            };
            fetch-depth = {
              type = "number";
              default = 1;
            };
            persist-credentials = {
              type = "boolean";
              default = true;
            };
            package = {
              type = "string";
              default = "";
            };
            create-package-pr = {
              type = "boolean";
              default = false;
            };
            base-ref = {
              type = "string";
              default = "";
            };
            base-sha = {
              type = "string";
              default = "";
            };
            head-ref = {
              type = "string";
              default = "";
            };
            head-repo = {
              type = "string";
              default = "";
            };
            head-sha = {
              type = "string";
              default = "";
            };
            pr-number = {
              type = "string";
              default = "";
            };
          };

          secrets = {
            FONTS_SSH_KEY = {
              required = true;
            };
            PACKAGE_UPDATE_TOKEN = {
              required = false;
            };
          };
        };

        jobs.nix = {
          name = ghExpr "inputs.name";
          runs-on = "ubuntu-latest";
          steps = [
            {
              name = "checkout";
              uses = "actions/checkout@v5";
              "with" = {
                ref = ghExpr "inputs.ref";
                fetch-depth = ghExpr "inputs.fetch-depth";
                persist-credentials = ghExpr "inputs.persist-credentials";
              };
            }
            {
              name = "setup ssh-agent";
              uses = "webfactory/ssh-agent@v0.9.0";
              "with" = {
                ssh-private-key = ghExpr "secrets.FONTS_SSH_KEY";
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
                primary-key = "nix-${ghExpr "runner.os"}-${ghExpr "hashFiles('**/flake.lock')"}";
                restore-prefixes-first-match = "nix-${ghExpr "runner.os"}-";
              };
            }
            {
              name = "run command";
              id = "update";
              env = {
                BASE_REF = ghExpr "inputs.base-ref";
                BASE_SHA = ghExpr "inputs.base-sha";
                HEAD_REF = ghExpr "inputs.head-ref";
                HEAD_REPO = ghExpr "inputs.head-repo";
                HEAD_SHA = ghExpr "inputs.head-sha";
                PACKAGE = ghExpr "inputs.package";
                PACKAGE_UPDATE_TOKEN = ghExpr "secrets.PACKAGE_UPDATE_TOKEN";
                PR_NUMBER = ghExpr "inputs.pr-number";
              };
              run = ghExpr "inputs.command";
            }
            {
              name = "create pull request";
              "if" = ghExpr "inputs.create-package-pr";
              uses = "peter-evans/create-pull-request@v8";
              "with" = {
                base = "main";
                token = ghExpr "secrets.PACKAGE_UPDATE_TOKEN";
                branch = "package-updates/${ghExpr "inputs.package"}";
                commit-message = "chore(packages): bump ${ghExpr "inputs.package"} from ${ghExpr "steps.update.outputs.before"} to ${ghExpr "steps.update.outputs.after"}";
                delete-branch = true;
                title = "chore(packages): bump ${ghExpr "inputs.package"} from ${ghExpr "steps.update.outputs.before"} to ${ghExpr "steps.update.outputs.after"}";
                body = ghExpr "steps.update.outputs.body";
              };
            }
          ];
        };
      };
    }
  );
}
