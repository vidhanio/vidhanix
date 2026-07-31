{ withSystem, ... }:
let
  # expose flake-parts' `perSystem` args as ordinary module arguments, so
  # modules can take `{ self', inputs', ... }` directly instead of reaching
  # for `withSystem` / `moduleWithSystem`.
  #
  # the attribute names are written out literally rather than splatting
  # `withSystem ... (args: args)`: `_module.args` is a `lazyAttrsOf`, so
  # merging it forces each definition's *names*. deriving those names from a
  # call that itself needs `pkgs` (which comes from `_module.args`) would be
  # infinitely recursive. naming them here keeps the values lazy.
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
