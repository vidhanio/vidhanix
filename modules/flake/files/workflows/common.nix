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

  checkout = {
    name = "checkout";
    uses = "actions/checkout@v5";
  };

  # the composite action keeps the runner setup identical across workflows.
  setupNix = {
    name = "setup nix";
    uses = "./.github/actions/setup-nix";
    "with".ssh-private-key = ghExpr "secrets.FONTS_SSH_KEY";
  };

  deepCheckout = checkout // {
    "with".fetch-depth = 0;
  };

  deepCheckoutBase = checkout // {
    "with" = {
      fetch-depth = 0;
      ref = ghExpr "github.event.pull_request.base.sha";
    };
  };

  createAppToken = {
    name = "create github app token";
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
      options.workflowCommon = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        readOnly = true;
        internal = true;
      };

      config.workflowCommon = {
        inherit
          createAppToken
          ghExpr
          hosts
          just
          setupNix
          checkout
          deepCheckout
          deepCheckoutBase
          updatablePackages
          ;
      };
    }
  );
}
