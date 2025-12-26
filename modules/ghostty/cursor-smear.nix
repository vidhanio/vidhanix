{ ghostty-shader-playground, ... }:
{
  flake.modules.homeManager.default = {
    ghostty.settings.custom-shader = [
      "${ghostty-shader-playground}/public/shaders/cursor_smear.glsl"
    ];
  };
}
