{
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
        macos-option-as-alt = "left";
        custom-shader = [ "${pkgs.ghostty-shader-playground}/share/shaders/cursor_smear.glsl" ];
        window-padding-x = padding;
        window-padding-y = padding;
      };
  };
}
