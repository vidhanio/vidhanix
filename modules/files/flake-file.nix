{ config, inputs, ... }:
{
  flake-file.inputs.flake-file.url = "github:vic/flake-file";

  imports = [
    inputs.flake-file.flakeModules.dendritic
  ];

  flake-file.do-not-edit = config.files.generatedMessage.text;
}
