{ config, lib, ... }:
let
  systems = [
    "aarch64-linux"
    "x86_64-linux"
  ];

  entry =
    attrs: drv: attrs // { drv = baseNameOf (builtins.unsafeDiscardStringContext drv.drvPath); };

  entries =
    type: outputs:
    lib.concatMap (
      system: lib.mapAttrsToList (name: entry { inherit system name type; }) (outputs.${system} or { })
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
    ++ lib.mapAttrsToList (
      name: host:
      entry {
        inherit name;
        system = host.config.nixpkgs.hostPlatform.system;
        type = "system";
      } host.config.system.build.toplevel
    ) config.flake.nixosConfigurations
    ++ entries "devshell" config.flake.devShells
    ++ entries "check" config.flake.checks;
}
