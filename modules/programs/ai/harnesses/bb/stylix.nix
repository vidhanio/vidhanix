{
  flake.modules.homeManager.default =
    { config, lib, ... }:
    let
      theme = "stylix";

      colors = config.lib.stylix.colors.withHashtag;

      prop = name: value: "  --${name}: ${value};";

      mkCssBlock = selector: props: lib.concatStringsSep "\n" ([ "${selector} {" ] ++ props ++ [ "}" ]);

      # base16 → ANSI mapping: the 8 normal colors plus 8 bright variants
      # drawn from the same palette (base09 sits in the bright red slot).
      ansiNames = [
        "ansi-0"
        "ansi-1"
        "ansi-2"
        "ansi-3"
        "ansi-4"
        "ansi-5"
        "ansi-6"
        "ansi-7"
        "ansi-8"
        "ansi-9"
        "ansi-10"
        "ansi-11"
        "ansi-12"
        "ansi-13"
        "ansi-14"
        "ansi-15"
      ];
      ansiColors = [
        colors.base02 # black
        colors.base08 # red
        colors.base0B # green
        colors.base0A # yellow
        colors.base0D # blue
        colors.base0E # magenta
        colors.base0C # cyan
        colors.base05 # white
        colors.base03 # bright black
        colors.base09 # bright red
        colors.base0B # bright green
        colors.base0A # bright yellow
        colors.base0D # bright blue
        colors.base0E # bright magenta
        colors.base0C # bright cyan
        colors.base07 # bright white
      ];
      # Readable text drawn on each ANSI background: white on the dark group,
      # black on the bright group, like the bundled themes.
      ansiBgFgColors = [
        "#ffffff"
        "#ffffff"
        "#ffffff"
        "#ffffff"
        "#ffffff"
        "#ffffff"
        "#ffffff"
        "#000000"
        "#ffffff"
        "#000000"
        "#000000"
        "#000000"
        "#000000"
        "#000000"
        "#000000"
        "#000000"
      ];

      ansiBgFgNames = map (i: "ansi-bg-fg-${toString i}") (lib.range 0 15);

      ansiCss = lib.imap0 (i: color: prop (lib.elemAt ansiNames i) color) ansiColors;
      ansiBgFgCss = lib.imap0 (i: color: prop (lib.elemAt ansiBgFgNames i) color) ansiBgFgColors;

      # The ANSI block lives in the light selector and applies in both modes
      # (terminal colors are mode-independent), mirroring the bundled themes.
      lightThemeCss = mkCssBlock ":root, .light" (
        [
          (prop "canvas" colors.base06)
          (prop "ink" colors.base00)
          (prop "primary" colors.base0D)
          (prop "primary-foreground" colors.base06)
          (prop "muted-foreground" "color-mix(in oklch, var(--ink) 70%, var(--canvas))")
          (prop "subtle-foreground" "color-mix(in oklch, var(--ink) 58%, var(--canvas))")
          (prop "readback-foreground" "color-mix(in oklch, var(--ink) 64%, var(--canvas))")
          (prop "timeline-accent" "var(--primary)")
          (prop "file-accent" "var(--timeline-accent)")
          (prop "destructive" colors.base08)
          (prop "destructive-text" "color-mix(in oklch, var(--destructive) 65%, var(--ink))")
          (prop "warning" colors.base09)
          (prop "warning-text" "color-mix(in oklch, var(--warning) 65%, var(--ink))")
          (prop "attention" colors.base0A)
          (prop "success" colors.base0B)
          (prop "diff-added" colors.base0B)
          (prop "diff-removed" colors.base08)
          (prop "pr-merged" colors.base0E)
        ]
        ++ ansiCss
        ++ ansiBgFgCss
      );

      # Stylix here is pinned to dark polarity, so the light block above is an
      # inversion of the same base16 palette; base0x are the dark anchors.
      darkThemeCss = mkCssBlock ".dark" [
        (prop "canvas" colors.base00)
        (prop "ink" colors.base05)
        (prop "primary" colors.base0D)
        (prop "primary-foreground" colors.base00)
        (prop "timeline-accent" "var(--primary)")
        (prop "file-accent" "var(--timeline-accent)")
        (prop "destructive" colors.base08)
        (prop "destructive-text" "color-mix(in oklch, var(--destructive) 65%, ${colors.base07})")
        (prop "warning" colors.base09)
        (prop "warning-text" "color-mix(in oklch, var(--warning) 65%, ${colors.base07})")
        (prop "attention" colors.base0A)
        (prop "success" colors.base0B)
        (prop "diff-added" colors.base0B)
        (prop "diff-removed" colors.base08)
        (prop "pr-merged" colors.base0E)
      ];

      themeCss = lib.concatStringsSep "\n" [
        lightThemeCss
        darkThemeCss
      ];
    in
    {
      programs.bb.themes.${theme} = themeCss;
    };
}
