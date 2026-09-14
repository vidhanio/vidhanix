{ config, inputs, ... }:
{
  imports = [
    inputs.flake-file.flakeModules.dendritic
    inputs.flake-file.flakeModules.auto-follow
  ];

  flake-file.inputs.flake-file.url = "github:denful/flake-file";

  flake-file.do-not-edit = config.files.generatedMessage.text;
}
