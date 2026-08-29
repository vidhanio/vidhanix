{ lib, ... }:
{
  flake.aspects.fastpotify = {
    homeManager =
      { config, inputs', ... }:
      let
        colors = config.lib.stylix.colors;

        rgb =
          name:
          "Color32::from_rgb(${colors."${name}-rgb-r"}, ${colors."${name}-rgb-g"}, ${colors."${name}-rgb-b"})";

        replacement = file: old: new: {
          inherit file old new;
        };

        themeReplacements = [
          (replacement "src/theme.rs" "window: Color32::from_rgb(0x0f, 0x11, 0x14),"
            "window: ${rgb "base00"},"
          )
          (replacement "src/theme.rs" "panel: Color32::from_rgb(0x15, 0x18, 0x1c)," "panel: ${rgb "base01"},")
          (replacement "src/theme.rs" "surface: Color32::from_rgb(0x1d, 0x21, 0x27),"
            "surface: ${rgb "base02"},"
          )
          (replacement "src/theme.rs" "surface_hover: Color32::from_rgb(0x26, 0x2b, 0x33),"
            "surface_hover: ${rgb "base03"},"
          )
          (replacement "src/theme.rs" "surface_active: Color32::from_rgb(0x2f, 0x35, 0x3f),"
            "surface_active: ${rgb "base04"},"
          )
          (replacement "src/theme.rs" "outline: Color32::from_rgb(0x2a, 0x30, 0x38),"
            "outline: ${rgb "base03"},"
          )
          (replacement "src/theme.rs" "text: Color32::from_rgb(0xf2, 0xf4, 0xf6)," "text: ${rgb "base05"},")
          (replacement "src/theme.rs" "secondary: Color32::from_rgb(0xa9, 0xb1, 0xbc),"
            "secondary: ${rgb "base04"},"
          )
          (replacement "src/theme.rs" "dim: Color32::from_rgb(0x6e, 0x77, 0x84)," "dim: ${rgb "base03"},")
          (replacement "src/theme.rs" "accent: Color32::from_rgb(0x1e, 0xd7, 0x60),"
            "accent: ${rgb "base0D"},"
          )
          (replacement "src/theme.rs" "accent_hover: Color32::from_rgb(0x3c, 0xe8, 0x7a),"
            "accent_hover: ${rgb "base0D"},"
          )
          (replacement "src/theme.rs" "on_accent: Color32::from_rgb(0x0a, 0x14, 0x0e),"
            "on_accent: ${rgb "base00"},"
          )
          (replacement "src/theme.rs" "danger: Color32::from_rgb(0xf5, 0x71, 0x7f),"
            "danger: ${rgb "base08"},"
          )
          (replacement "src/theme.rs" "warning: Color32::from_rgb(0xf2, 0xb8, 0x5c),"
            "warning: ${rgb "base0A"},"
          )
          (replacement "src/theme.rs" "overlay: Color32::from_rgb(0x22, 0x27, 0x2e),"
            "overlay: ${rgb "base01"},"
          )
          (replacement "src/theme.rs" "window: Color32::from_rgb(0xf8, 0xf9, 0xfb),"
            "window: ${rgb "base00"},"
          )
          (replacement "src/theme.rs" "panel: Color32::from_rgb(0xff, 0xff, 0xff)," "panel: ${rgb "base01"},")
          (replacement "src/theme.rs" "surface: Color32::from_rgb(0xee, 0xf0, 0xf3),"
            "surface: ${rgb "base02"},"
          )
          (replacement "src/theme.rs" "surface_hover: Color32::from_rgb(0xe3, 0xe6, 0xeb),"
            "surface_hover: ${rgb "base03"},"
          )
          (replacement "src/theme.rs" "surface_active: Color32::from_rgb(0xd7, 0xdb, 0xe1),"
            "surface_active: ${rgb "base04"},"
          )
          (replacement "src/theme.rs" "outline: Color32::from_rgb(0xdd, 0xe1, 0xe6),"
            "outline: ${rgb "base03"},"
          )
          (replacement "src/theme.rs" "text: Color32::from_rgb(0x14, 0x17, 0x1a)," "text: ${rgb "base05"},")
          (replacement "src/theme.rs" "secondary: Color32::from_rgb(0x53, 0x5b, 0x66),"
            "secondary: ${rgb "base04"},"
          )
          (replacement "src/theme.rs" "dim: Color32::from_rgb(0x8b, 0x93, 0x9e)," "dim: ${rgb "base03"},")
          (replacement "src/theme.rs" "accent: Color32::from_rgb(0x15, 0xa6, 0x4a),"
            "accent: ${rgb "base0D"},"
          )
          (replacement "src/theme.rs" "accent_hover: Color32::from_rgb(0x12, 0x8f, 0x40),"
            "accent_hover: ${rgb "base0D"},"
          )
          (replacement "src/theme.rs" "on_accent: Color32::WHITE," "on_accent: ${rgb "base00"},")
          (replacement "src/theme.rs" "danger: Color32::from_rgb(0xd6, 0x3b, 0x4c),"
            "danger: ${rgb "base08"},"
          )
          (replacement "src/theme.rs" "warning: Color32::from_rgb(0xb8, 0x7a, 0x14),"
            "warning: ${rgb "base0A"},"
          )
          (replacement "src/theme.rs" "overlay: Color32::from_rgb(0xff, 0xff, 0xff),"
            "overlay: ${rgb "base01"},"
          )
        ];

        substitutions = lib.concatMapStringsSep "\n" (
          {
            file,
            old,
            new,
          }:
          "substituteInPlace ${file} --replace-fail ${lib.escapeShellArg old} ${lib.escapeShellArg new}"
        ) themeReplacements;

        defaultTheme =
          if config.stylix.polarity == "light" then
            "light"
          else if config.stylix.polarity == "either" then
            "system"
          else
            "dark";

        package = inputs'.fastpotify.packages.fastpotify.overrideAttrs (old: {
          postPatch = (old.postPatch or "") + ''
            ${substitutions}
          '';
        });
      in
      {
        # fastpotify compiles its palette into the binary rather than reading a theme file.
        programs.fastpotify = {
          package = lib.mkDefault package;
          settings.theme = lib.mkDefault defaultTheme;
        };
      };
  };
}
