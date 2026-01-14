{ config, inputs, ... }:
{
  flake-file.inputs.flake-file.url = "github:vic/flake-file";

  imports = [
    inputs.flake-file.flakeModules.dendritic
    # TODO: fix changing mtime of flake.lock if untouched
    # inputs.flake-file.flakeModules.nix-auto-follow
  ];

  flake-file.do-not-edit = config.files.generatedMessage.text;
}
