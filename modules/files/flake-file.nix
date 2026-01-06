{ config, inputs, ... }:
{
  flake-file.inputs.flake-file.url = "github:vic/flake-file";

  imports = [
    inputs.flake-file.flakeModules.dendritic
    # inputs.flake-file.flakeModules.nix-auto-follow
  ];

  flake-file.do-not-edit = config.files.generatedMessage.text;
}
