{
  config,
  inputs,
  lib,
  withSystem,
  ...
}:
{
  imports = [
    inputs.flake-file.flakeModules.dendritic
    inputs.flake-file.flakeModules.nix-auto-follow
  ];

  options.flake-file.prune-lock.ignore = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    description = "Root inputs to pass to nix-auto-follow's `--ignore` flag.";
  };

  config = {
    # TODO: switch back to `github:denful/flake-file` once
    # https://github.com/denful/flake-file/pull/130 is merged. this fork
    # branch carries a fix for write-flake unconditionally rewriting
    # flake.nix (and cascading into flake.lock) even when nothing changed.
    flake-file.inputs.flake-file.url = "github:vidhanio/flake-file/fix/write-flake-mtime-churn";

    flake-file.do-not-edit = config.files.generatedMessage.text;

    # TODO: switch back to `github:fzakaria/nix-auto-follow` once
    # https://github.com/fzakaria/nix-auto-follow/pull/34 is merged upstream.
    # released nix-auto-follow clobbers a node's `inputs` field (including
    # existing `follows` arrays) when unifying duplicate content, which
    # breaks inputs that already declare their own `nixpkgs.follows` (e.g.
    # home-manager, treefmt-nix): nix-auto-follow repoints them at some
    # other content-equal alias, nix's own resolution repoints them back to
    # the direct follows target, and the two fight forever. PR #34 fixes
    # this (preserves `inputs` during content unification), but its author's
    # branch (github:xav-ie/nix-auto-follow/fix-inputs-references) was cut
    # before upstream's `--ignore` flag (#36) landed, so it's missing that.
    # github:vidhanio/nix-auto-follow/merge-fix-inputs-references merges
    # PR #34 onto current upstream main to get both. verified this converges
    # to a byte-stable flake.lock across repeated prune/resolve cycles,
    # unlike released nix-auto-follow.
    flake-file.inputs.nix-auto-follow.url = "github:vidhanio/nix-auto-follow/merge-fix-inputs-references";

    # override the upstream program to bake in `--ignore` flags for
    # `flake-file.prune-lock.ignore`.
    flake-file.prune-lock.program =
      pkgs:
      pkgs.writeShellApplication {
        name = "nix-auto-follow-wrapped";
        derivationArgs = {
          preferLocalBuild = true;
          allowSubstitutes = false;
        };
        runtimeInputs = [
          (withSystem pkgs.stdenv.hostPlatform.system (
            { inputs', ... }: inputs'.nix-auto-follow.packages.default
          ))
        ];
        text = ''
          auto-follow \
            ${
              lib.concatMapStringsSep " \\\n    " (
                name: "--ignore ${lib.escapeShellArg name}"
              ) config.flake-file.prune-lock.ignore
            } \
            "$1" > "$2"
        '';
      };
  };
}
