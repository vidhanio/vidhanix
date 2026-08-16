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

  # reusable workflow called by every nix job.
  nixJob = {
    uses = "./.github/workflows/nix.yaml";
    secrets = {
      FONTS_SSH_KEY = ghExpr "secrets.FONTS_SSH_KEY";
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
          ghExpr
          hosts
          just
          nixJob
          updatablePackages
          ;
      };
    }
  );
}
