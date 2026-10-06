{ inputs }:
platform:
{ lib, pkgs, ... }:
let
  targets = ./_modules/stylix;
  metaLib = lib.extend (
    _: prev: {
      maintainers = lib.attrsets.unionOfDisjoint prev.maintainers (
        import "${inputs.stylix}/stylix/maintainers.nix"
      );
    }
  );
  loadTarget =
    name: kind:
    let
      file = targets + "/${name}/${platform}.nix";
      module = import file;
      metadata = import (targets + "/${name}/meta.nix");
      meta =
        if builtins.isFunction metadata then
          metadata {
            lib = metaLib;
            inherit pkgs;
          }
        else
          metadata;
      mkTarget = import "${inputs.stylix}/stylix/mk-target.nix" {
        inherit name;
        humanName = meta.name;
      };
    in
    lib.optional (kind == "directory" && builtins.pathExists file) (
      if builtins.isFunction module && (builtins.functionArgs module) ? mkTarget then
        { config, ... }@args:
        let
          # mkTarget must be injected before evaluation, not via _module.args.
          extraArgs = lib.mapAttrs (
            argument: _:
            builtins.addErrorContext "while evaluating module argument `${argument}' in ${toString file}:" (
              args.${argument} or config._module.args.${argument}
            )
          ) (removeAttrs (builtins.functionArgs module) [ "mkTarget" ]);
        in
        {
          key = toString file;
          _file = toString file;
          imports = [
            (module (
              args
              // extraArgs
              // {
                inherit mkTarget;
                # Match Stylix's guards against bypassing mkTarget's disabled options.
                config = lib.recursiveUpdate config {
                  stylix = throw "stylix: unguarded `config.stylix` accessed while using mkTarget";
                  lib.stylix.colors = throw "stylix: unguarded `config.lib.stylix.colors` accessed while using mkTarget";
                };
              }
            ))
          ];
        }
      else
        file
    );
in
{
  imports = lib.concatLists (lib.mapAttrsToList loadTarget (builtins.readDir targets));
}
