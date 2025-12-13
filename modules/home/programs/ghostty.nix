{
  pkgs,
  ...
}:
{
  programs.ghostty = {
    settings =
      let
        padding = 10;
      in
      {
        custom-shader = [ "${pkgs.ghostty-shader-playground}/share/shaders/cursor_smear.glsl" ];
        window-padding-x = padding;
        window-padding-y = padding;
      };
  };
}
