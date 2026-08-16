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

  # package updates always start from main; create-pull-request then rebases
  # the update branch.
  nixStepsOnMain = [
    (
      (builtins.head nixSteps)
      // {
        "with" = {
          fetch-depth = 0;
          persist-credentials = false;
          ref = "main";
        };
      }
    )
  ]
  ++ builtins.tail nixSteps;

  nixStepsOnBase = [
    (
      (builtins.head nixSteps)
      // {
        "with" = {
          fetch-depth = 0;
          persist-credentials = false;
          ref = ghExpr "github.event.pull_request.base.sha";
        };
      }
    )
  ]
  ++ builtins.tail nixSteps;
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
      options.workflowCommon = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        readOnly = true;
        internal = true;
      };

      config.workflowCommon = {
        inherit
          ghExpr
          hosts
          just
          nixSteps
          nixStepsOnMain
          nixStepsOnBase
          updatablePackages
          ;
      };
    }
  );
}
