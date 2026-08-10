{ withSystem, ... }:
let
  # Expose flake-parts' perSystem args as ordinary module args.
  # `_module.args` is a lazyAttrsOf: merging forces definition names, so
  # deriving them from a withSystem call that needs pkgs recurses infinitely.
  perSystemArgs =
    { pkgs, ... }:
    {
      _module.args = {
        self' = withSystem pkgs.stdenv.hostPlatform.system ({ self', ... }: self');
        inputs' = withSystem pkgs.stdenv.hostPlatform.system ({ inputs', ... }: inputs');
      };
    };
in
{
  flake.modules = {
    nixos.default = perSystemArgs;
    homeManager.default = perSystemArgs;
  };
}
