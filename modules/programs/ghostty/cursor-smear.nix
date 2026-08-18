{ inputs, lib, ... }:
{
  flake-file.inputs.ghostty-shader-playground = {
    url = "github:KroneCorylus/ghostty-shader-playground";
    flake = false;
  };

  flake.aspects.ghostty = {
    homeManager =
      { osConfig, ... }:
      {
        programs.ghostty.settings.custom-shader = lib.mkIf (osConfig.networking.hostName == "vidhan-pc") [
          "${inputs.ghostty-shader-playground}/public/shaders/cursor_smear.glsl"
        ];
      };
  };
}
