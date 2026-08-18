{
  flake.aspects.opencode2 = {
    homeManager =
      { config, lib, ... }:
      let
        theme = "stylix-v2";
        colors = config.lib.stylix.colors.withHashtag;

        inherit (builtins)
          floor
          foldl'
          stringLength
          substring
          ;
        digits = lib.stringToCharacters "0123456789abcdef";
        digitVal = c: lib.lists.findFirstIndex (d: d == c) 0 digits;

        hexToRgb =
          hex:
          let
            h = lib.removePrefix "#" hex;
            pair = s: foldl' (acc: c: acc * 16 + digitVal c) 0 (lib.stringToCharacters s);
          in
          {
            r = pair (substring 0 2 h);
            g = pair (substring 2 2 h);
            b = pair (substring 4 2 h);
          };

        byte =
          v:
          let
            hex = lib.toLower (lib.toHexString (floor (v + 0.5)));
          in
          if stringLength hex == 1 then "0${hex}" else hex;

        rgbToHex =
          {
            r,
            g,
            b,
          }:
          "#${byte r}${byte g}${byte b}";

        mix =
          a: b: t:
          rgbToHex {
            r = a.r + (b.r - a.r) * t;
            g = a.g + (b.g - a.g) * t;
            b = a.b + (b.b - a.b) * t;
          };

        white = hexToRgb "#ffffff";
        black = hexToRgb "#000000";
        lighten = c: t: mix (hexToRgb c) white t;
        darken = c: t: mix (hexToRgb c) black t;

        luminance =
          {
            r,
            g,
            b,
          }:
          0.299 * r + 0.587 * g + 0.114 * b;

        isLightBackground = luminance (hexToRgb colors.base00) > 127.5;
        mode =
          if config.stylix.polarity == "light" then
            "light"
          else if config.stylix.polarity == "dark" then
            "dark"
          else if isLightBackground then
            "light"
          else
            "dark";

        mkScale = c: {
          "100" = lighten c 0.10;
          "200" = c;
          "300" = darken c 0.12;
          "400" = darken c 0.25;
          "500" = darken c 0.38;
          "600" = darken c 0.50;
          "700" = darken c 0.62;
          "800" = darken c 0.74;
          "900" = darken c 0.86;
        };

        gray = {
          "100" = colors.base07;
          "200" = colors.base06;
          "300" = mix (hexToRgb colors.base05) (hexToRgb colors.base06) 0.5;
          "400" = colors.base05;
          "500" = mix (hexToRgb colors.base03) (hexToRgb colors.base04) 0.5;
          "600" = colors.base03;
          "700" = colors.base02;
          "800" = colors.base01;
          "900" = colors.base00;
        };

        red = mkScale colors.base08;
        orange = mkScale colors.base09;
        yellow = mkScale colors.base0A;
        green = mkScale colors.base0B;
        cyan = mkScale colors.base0C;
        blue = mkScale colors.base0D;
        purple = mkScale colors.base0E;

        hue = {
          inherit
            gray
            red
            orange
            yellow
            green
            cyan
            blue
            purple
            ;
          accent = "$hue.purple";
          interactive = "$hue.orange";
          neutral = "$hue.gray";
        };

        dark = {
          inherit hue;
          categorical = [
            "blue"
            "purple"
            "green"
            "orange"
            "red"
          ];
          text = {
            default = "$hue.neutral.200";
            subdued = "$hue.neutral.500";
            action = {
              primary = {
                default = "$text.default";
                "$disabled" = "$hue.neutral.500";
                "$focused" = "$hue.neutral.900";
                "$selected" = "$hue.interactive.200";
              };
              destructive = {
                default = "$hue.neutral.900";
                "$disabled" = "$hue.neutral.500";
              };
            };
            formfield = {
              default = "$hue.neutral.200";
              "$hovered" = "$hue.interactive.200";
              "$focused" = "$hue.interactive.200";
              "$pressed" = "$hue.interactive.200";
              "$selected" = "$hue.interactive.200";
              "$disabled" = "$hue.neutral.500";
            };
            feedback = {
              error = {
                default = "$hue.red.200";
              };
              warning = {
                default = "$hue.yellow.200";
              };
              success = {
                default = "$hue.green.200";
              };
              info = {
                default = "$hue.cyan.200";
              };
            };
          };
          background = {
            default = "$hue.neutral.900";
            surface = {
              offset = "$hue.neutral.800";
              overlay = "$hue.neutral.700";
            };
            action = {
              primary = {
                default = "transparent";
                "$hovered" = "$background.surface.offset";
                "$focused" = "$hue.interactive.200";
                "$selected" = "transparent";
              };
              destructive = {
                default = "$hue.red.200";
              };
            };
            formfield = {
              default = "$background.default";
            };
            feedback = {
              error = {
                default = "$background.default";
              };
              warning = {
                default = "$background.default";
              };
              success = {
                default = "$background.default";
              };
              info = {
                default = "$background.default";
              };
            };
          };
          border = {
            default = "$hue.neutral.600";
          };
          scrollbar = {
            default = "$hue.neutral.600";
          };
          diff = {
            text = {
              added = "$hue.cyan.200";
              removed = "$hue.red.300";
              context = "$hue.neutral.500";
              hunkHeader = "$hue.purple.400";
            };
            background = {
              added = "$hue.cyan.800";
              removed = "$hue.red.800";
              context = "$hue.neutral.800";
            };
            highlight = {
              added = "$hue.green.100";
              removed = "$hue.red.200";
            };
            lineNumber = {
              text = "$hue.neutral.500";
              background = {
                added = "$hue.cyan.900";
                removed = "$hue.red.900";
              };
            };
          };
          syntax = {
            comment = "$hue.neutral.500";
            keyword = "$hue.purple.200";
            function = "$hue.orange.200";
            variable = "$hue.red.200";
            string = "$hue.green.200";
            number = "$hue.yellow.200";
            type = "$hue.yellow.200";
            operator = "$hue.cyan.200";
            punctuation = "$hue.neutral.200";
          };
          markdown = {
            text = "$hue.neutral.200";
            heading = "$hue.purple.200";
            link = "$hue.orange.200";
            linkText = "$hue.cyan.200";
            code = "$hue.green.200";
            blockQuote = "$hue.yellow.200";
            emphasis = "$hue.yellow.200";
            strong = "$hue.yellow.200";
            horizontalRule = "$hue.neutral.500";
            listItem = "$hue.orange.200";
            listEnumeration = "$hue.cyan.200";
            image = "$hue.orange.200";
            imageText = "$hue.cyan.200";
            codeBlock = "$hue.neutral.200";
          };
        };

        light = {
          mergeMode = true;
          hue = {
            accent = "$hue.orange";
            interactive = "$hue.blue";
          };
          categorical = [
            "purple"
            "orange"
            "green"
            "blue"
            "red"
          ];
          text = {
            default = "$hue.neutral.900";
            subdued = "$hue.neutral.600";
            action = {
              primary = {
                default = "$text.default";
                "$disabled" = "$hue.neutral.500";
                "$focused" = "$hue.neutral.100";
                "$selected" = "$hue.interactive.800";
              };
              destructive = {
                default = "$hue.neutral.100";
                "$disabled" = "$hue.neutral.500";
              };
            };
            formfield = {
              default = "$hue.neutral.900";
              "$hovered" = "$hue.interactive.800";
              "$focused" = "$hue.interactive.800";
              "$pressed" = "$hue.interactive.800";
              "$selected" = "$hue.interactive.800";
              "$disabled" = "$hue.neutral.500";
            };
            feedback = {
              error = {
                default = "$hue.red.700";
              };
              warning = {
                default = "$hue.yellow.800";
              };
              success = {
                default = "$hue.green.700";
              };
              info = {
                default = "$hue.cyan.700";
              };
            };
          };
          background = {
            default = "$hue.neutral.100";
            surface = {
              offset = "$hue.neutral.200";
              overlay = "$hue.neutral.300";
            };
            action = {
              primary = {
                default = "transparent";
                "$hovered" = "$background.surface.offset";
                "$focused" = "$hue.interactive.800";
                "$selected" = "transparent";
              };
              destructive = {
                default = "$hue.red.700";
              };
            };
          };
          border = {
            default = "$hue.neutral.400";
          };
          diff = {
            text = {
              added = "$hue.cyan.700";
              removed = "$hue.red.700";
              context = "$hue.neutral.600";
              hunkHeader = "$hue.purple.600";
            };
            background = {
              added = "$hue.cyan.200";
              removed = "$hue.red.200";
              context = "$hue.neutral.100";
            };
            highlight = {
              added = "$hue.green.600";
              removed = "$hue.red.600";
            };
            lineNumber = {
              text = "$hue.neutral.600";
              background = {
                added = "$hue.cyan.300";
                removed = "$hue.red.300";
              };
            };
          };
          syntax = {
            comment = "$hue.neutral.600";
            keyword = "$hue.orange.800";
            function = "$hue.blue.700";
            variable = "$hue.red.700";
            string = "$hue.green.700";
            number = "$hue.yellow.800";
            type = "$hue.yellow.800";
            operator = "$hue.cyan.700";
            punctuation = "$hue.neutral.900";
          };
          markdown = {
            text = "$hue.neutral.900";
            heading = "$hue.orange.800";
            link = "$hue.blue.700";
            linkText = "$hue.cyan.700";
            code = "$hue.green.700";
            blockQuote = "$hue.yellow.800";
            emphasis = "$hue.yellow.800";
            strong = "$hue.yellow.800";
            horizontalRule = "$hue.neutral.600";
            listItem = "$hue.blue.700";
            listEnumeration = "$hue.cyan.700";
            image = "$hue.blue.700";
            imageText = "$hue.cyan.700";
            codeBlock = "$hue.neutral.900";
          };
        };
      in
      {
        programs.opencode2 = {
          cli.theme = {
            name = theme;
            inherit mode;
          };
          themes.${theme} = {
            version = 2;
            inherit light dark;
          };
        };
      };
  };
}
