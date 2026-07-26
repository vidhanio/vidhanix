{ inputs, den, ... }:
{
  # Declared explicitly (not left to flakeModules.dendritic's own
  # mkDefault) so nix-auto-follow's prune-lock step doesn't consider it
  # unreferenced and drop it from flake.lock, which would make this
  # module unbootstrappable (imports below need inputs.den to already
  # be resolved).
  flake-file.inputs.den.url = "github:denful/den";

  imports = [ inputs.den.flakeModules.dendritic ];

  # Foundational pipeline wiring so classes (treefmt, devshell, files, ...)
  # can route their content into flake-parts' perSystem scope.
  den.schema.flake-system.includes = [ den.policies.system-to-flake-parts ];
}
