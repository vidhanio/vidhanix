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

  setupNixAction = {
    name = "Set up Nix";
    description = "Install Nix and prepare the runner for a Nix job";
    inputs.ssh-private-key = {
      description = "SSH key for private flake inputs";
      required = true;
    };
    runs = {
      using = "composite";
      steps = [
        {
          name = "Set up SSH agent";
          uses = "webfactory/ssh-agent@v0.9.0";
          "with" = {
            ssh-private-key = ghExpr "inputs.ssh-private-key";
          };
        }
        {
          name = "Free disk space";
          uses = "wimpysworld/nothing-but-nix@v9";
          "with".hatchet-protocol = "carve";
        }
        {
          name = "Install Nix";
          uses = "cachix/install-nix-action@v31";
          "with" = {
            nix_path = "path: nixpkgs=channel:nixos-unstable";
            extra_nix_config = "build-dir = /nix/build";
          };
        }
        {
          name = "Restore Nix store";
          uses = "nix-community/cache-nix-action@v7";
          "with" = {
            primary-key = "nix-${ghExpr "runner.os"}-${ghExpr "hashFiles('**/flake.lock')"}";
            restore-prefixes-first-match = "nix-${ghExpr "runner.os"}-";
          };
        }
      ];
    };
  };

  # hosts come from the built configurations, so the eval matrix stays in
  # sync with `configurations.<hostname>`. evaluation runs on any platform;
  # only builds need a matching runner. the full drvPath attr keeps the run
  # line short enough that remarshal does not fold the `${{ }}` expression.
  hosts = lib.mapAttrsToList (name: _cfg: {
    inherit name;
    attr = "nixosConfigurations.${name}.config.system.build.toplevel.drvPath";
  }) config.flake.nixosConfigurations;

  checkout = {
    name = "Checkout";
    uses = "actions/checkout@v5";
  };

  # the composite action keeps the runner setup identical across workflows.
  setupNix = {
    name = "Set up Nix";
    uses = "./.github/actions/setup-nix";
    "with".ssh-private-key = ghExpr "secrets.FONTS_SSH_KEY";
  };

  checkoutHead = checkout // {
    "with".ref = ghExpr "github.event.pull_request.head.sha";
  };

  # dependabot PRs carry structured metadata about their update; workflows
  # dispatch on its ecosystem output instead of parsing branch names.
  fetchMetadata = {
    name = "Fetch Dependabot metadata";
    id = "metadata";
    uses = "dependabot/fetch-metadata@v3";
  };

  # commits the worktree back onto the PR branch; a clean tree makes it a no-op.
  commitToPrBranch = commitMessage: {
    name = "Commit";
    uses = "planetscale/ghcommit-action@v0.2.22";
    "with" = {
      commit_message = commitMessage;
      repo = ghExpr "github.repository";
      branch = ghExpr "github.event.pull_request.head.ref";
    };
    env.GITHUB_TOKEN = ghExpr "steps.app-token.outputs.token";
  };

  createAppToken = {
    name = "Create GitHub App token";
    id = "app-token";
    uses = "actions/create-github-app-token@v3";
    "with" = {
      client-id = ghExpr "vars.APP_CLIENT_ID";
      private-key = ghExpr "secrets.APP_PRIVATE_KEY";
    };
  };
in
{
  options.perSystem = flake-parts-lib.mkPerSystemOption (
    { config, ... }:
    let
      # the justfile recipes run inside the devshell, which pins just (and
      # the other tools) to the locked nixpkgs.
      just = "nix develop -c just";

      updatablePackages = lib.attrNames (
        lib.filterAttrs (
          packageName: package: packageName != "update-packages" && package ? passthru.updateScript
        ) config.packages
      );
    in
    {
      config.files.lib.github = {
        inherit
          checkout
          checkoutHead
          commitToPrBranch
          createAppToken
          fetchMetadata
          ghExpr
          hosts
          just
          setupNix
          setupNixAction
          updatablePackages
          ;
      };
    }
  );
}
