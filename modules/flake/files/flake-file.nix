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
    flake-file.inputs = {
      flake-file.url = "github:denful/flake-file";
      auto-follow.url = "github:fzakaria/nix-auto-follow";
    };

    flake-file.do-not-edit = config.files.generatedMessage.text;

    # wrap upstream to bake in `--ignore` flags for prune-lock.ignore.
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
