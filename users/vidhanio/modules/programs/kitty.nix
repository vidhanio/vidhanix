{ pkgs, ... }:
{
  programs.kitty = {
    enable = true;
    enableGitIntegration = true;
    font = {
      name = "Berkeley Mono Variable";
      package = with pkgs; berkeley-mono-variable;
    };
    keybindings = {
      "ctrl+c" = "copy_or_interrupt";
      "ctrl+v" = "paste_from_clipboard";
    };
    settings = {
      editor = "nvim";
      window_padding_width = 8;

      foreground = "#bfbdb6";
      background = "#0b0e14";
      selection_foreground = "none";
      selection_background = "#409fff";
      url_color = "#e6b450";
      active_border_color = "#e6b450";
      wayland_titlebar_color = "#0b0e14";
      macos_titlebar_color = "#0b0e14";
      active_tab_foreground = "#bfbdb6";
      active_tab_background = "#0b0e14";
      inactive_tab_foreground = "#565b66";
      inactive_tab_background = "#0b0e14";
      tab_bar_background = "#0b0e14";
      mark1_background = "#3794ff";
      mark2_background = "#e6b450";
      mark3_background = "#d95757";
      color0 = "#1e232b";
      color8 = "#686868";
      color1 = "#ea6c73";
      color9 = "#f07178";
      color2 = "#7fd962";
      color10 = "#aad94c";
      color3 = "#f9af4f";
      color11 = "#ffb454";
      color4 = "#53bdfa";
      color12 = "#59c2ff";
      color5 = "#cda1fa";
      color13 = "#d2a6ff";
      color6 = "#90e1c6";
      color14 = "#95e6cb";
      color7 = "#c7c7c7";
      color15 = "#ffffff";
    };
  };
}
