{ inputs, ... }:
{
  flake-file.inputs.ghostty-shader-playground = {
    url = "github:KroneCorylus/ghostty-shader-playground";
    flake = false;
  };

  configurations.vidhan-pc.homeModule = {
    programs.ghostty.settings.custom-shader = [
      "${inputs.ghostty-shader-playground}/public/shaders/cursor_smear.glsl"
    ];
  };
}
