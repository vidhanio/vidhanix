{ inputs, ... }:
{
  flake.modules.homeManager.default = {
    programs.ghostty.settings.custom-shader = [
      "${inputs.ghostty-shader-playground}/public/shaders/cursor_smear.glsl"
    ];
  };
}
