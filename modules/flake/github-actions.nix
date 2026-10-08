{ config, lib, ... }:
let
  systems = [
    "aarch64-linux"
    "x86_64-linux"
  ];

  entries =
    type: outputs:
    lib.concatMap (
      system: lib.mapAttrsToList (name: _: { inherit system name type; }) (outputs.${system} or { })
    ) systems;

  packages = lib.genAttrs systems (
    system:
    lib.filterAttrs (_: package: lib.elem system (package.meta.platforms or [ ])) (
      config.flake.packages.${system} or { }
    )
  );
in
{
  flake.githubActionsMatrix.include =
    entries "package" packages
    ++ lib.mapAttrsToList (name: host: {
      inherit name;
      system = host.config.nixpkgs.hostPlatform.system;
      type = "system";
    }) config.flake.nixosConfigurations
    ++ entries "devshell" config.flake.devShells
    ++ entries "check" config.flake.checks;
}
