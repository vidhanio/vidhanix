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
    name = "Set Up Nix";
    description = "Install Nix and prepare the runner for a Nix job";
    inputs.ssh-private-key = {
      description = "SSH key for private flake inputs";
      required = true;
    };
    inputs.cachix-auth-token = {
      description = "Token for pushing build outputs to Cachix";
      required = false;
      default = "";
    };
    runs = {
      using = "composite";
      steps = [
        {
          name = "Set Up SSH Agent";
          uses = "webfactory/ssh-agent@v0.9.0";
          "with" = {
            ssh-private-key = ghExpr "inputs.ssh-private-key";
          };
        }
        {
          name = "Set Up QEMU";
          uses = "docker/setup-qemu-action@v3";
        }
        {
          name = "Free Disk Space";
          uses = "wimpysworld/nothing-but-nix@v9";
          "with".hatchet-protocol = "carve";
        }
        {
          name = "Install Nix";
          uses = "cachix/install-nix-action@v31";
          "with".nix_path = "nixpkgs=channel:nixos-unstable";
          "with".extra_nix_config = ''
            build-dir = /nix/build
            extra-platforms = x86_64-linux aarch64-linux
          '';
        }
        {
          name = "Set Up Cachix";
          uses = "cachix/cachix-action@v17";
          "with" = {
            name = "vidhanio";
            authToken = ghExpr "inputs.cachix-auth-token";
            skipPush = ghExpr "inputs.cachix-auth-token == ''";
            pushFilter = "(-source$|berkeley-mono|pragmata-pro-variable)";
          };
        }
      ];
    };
  };

  # hosts come from the built NixOS configurations, so the eval matrix tracks
  # `hosts.<hostname>`; eval runs on any platform, only builds need a matching
  # runner. drvPath keeps the run line short so remarshal won't fold `${{ }}`.
  hosts = lib.mapAttrsToList (name: _cfg: {
    inherit name;
    attr = "nixosConfigurations.${name}.config.system.build.toplevel.drvPath";
  }) config.flake.nixosConfigurations;

  checkout = {
    name = "Checkout";
    uses = "actions/checkout@v7";
  };

  # the composite action keeps the runner setup identical across workflows.
  setupNix = {
    name = "Set Up Nix";
    uses = "./.github/actions/setup-nix";
    "with".ssh-private-key = ghExpr "secrets.FONTS_SSH_KEY";
    "with".cachix-auth-token =
      ghExpr "((github.ref == 'refs/heads/main' && (github.event_name == 'push' || github.event_name == 'schedule' || github.event_name == 'workflow_dispatch')) || (github.event_name == 'push' && contains(fromJSON('[\"vidhanio\",\"vidhanix[bot]\",\"dependabot[bot]\"]'), github.actor)) || (github.event_name == 'pull_request' && contains(fromJSON('[\"vidhanio\",\"vidhanix[bot]\",\"dependabot[bot]\"]'), github.event.pull_request.user.login))) && secrets.CACHIX_AUTH_TOKEN || ''";
  };

  checkoutHead = checkout // {
    "with".ref = ghExpr "github.event.pull_request.head.sha";
  };

  # dependabot PRs carry structured metadata about their update; workflows
  # dispatch on its ecosystem output instead of parsing branch names.
  fetchMetadata = {
    name = "Fetch Dependabot Metadata";
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
    name = "Create GitHub App Token";
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
