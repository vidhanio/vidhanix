{
  inputs,
  lib,
  osConfig,
  pkgs,
  ...
}:
{
  programs.ghostty = {
    package = lib.mkIf (osConfig.nixpkgs.hostPlatform.isDarwin) pkgs.ghostty-bin;
    settings =
      let
        padding = 10;
      in
      {
        custom-shader = [ "${inputs.ghostty-shader-playground}/shaders/cursor_smear.glsl" ];
        window-padding-x = padding;
        window-padding-y = padding;
      };
  };
}
