{ inputs, ... }:
{
  imports = [
    inputs.flake-aspects.flakeModule
    inputs.flake-parts.flakeModules.modules
  ];

  flake-file.inputs.flake-aspects.url = "github:denful/flake-aspects";
}
