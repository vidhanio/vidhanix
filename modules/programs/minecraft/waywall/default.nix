{
  inputs,
  lib,
  ...
}:
{
  flake-file.inputs.mcsr = {
    url = "https://git.uku3lig.net/uku/mcsr-nixos/archive/main.tar.gz";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.aspects.minecraft.homeManager =
    {
      inputs',
      config,
      pkgs,
      ...
    }:
    let
      cfg = config.programs.waywall;
      lua = pkgs.formats.lua { };
      place =
        size: container: anchor: offset:
        let
          offsetX = offset.x or 0;
          offsetY = offset.y or 0;
          left = (container.x or 0) + offsetX;
          centerX = (container.x or 0) + (container.w - size.w) / 2 + offsetX;
          right = (container.x or 0) + container.w - size.w - offsetX;
          top = (container.y or 0) + offsetY;
          centerY = (container.y or 0) + (container.h - size.h) / 2 + offsetY;
          bottom = (container.y or 0) + container.h - size.h - offsetY;
          positions = {
            center = {
              x = centerX;
              y = centerY;
            };
            top = {
              x = centerX;
              y = top;
            };
            bottom = {
              x = centerX;
              y = bottom;
            };
            left = {
              x = left;
              y = centerY;
            };
            right = {
              x = right;
              y = centerY;
            };
            topLeft = {
              x = left;
              y = top;
            };
            topRight = {
              x = right;
              y = top;
            };
            bottomLeft = {
              x = left;
              y = bottom;
            };
            bottomRight = {
              x = right;
              y = bottom;
            };
            centerLeft = {
              x = left;
              y = centerY;
            };
            centerRight = {
              x = right;
              y = centerY;
            };
          };
        in
        assert lib.assertMsg (lib.hasAttr anchor positions) "Bad Waywall layout anchor: ${anchor}";
        positions.${anchor} // { inherit (size) w h; };

      monitor = {
        w = 2560;
        h = 1440;
      };
      tall = {
        w = 384;
        h = 16384;
      };
      eyeSrcSize = {
        w = 60;
        h = 1320;
      };
      eye = {
        w = 872;
        h = 1080;
      };
      sideVisibleArea = {
        w = (monitor.w - tall.w) / 2;
        inherit (monitor) h;
      };
      leftVisibleArea = sideVisibleArea // {
        x = 0;
        y = 0;
      };
      rightVisibleArea = sideVisibleArea // {
        x = monitor.w - sideVisibleArea.w;
        y = 0;
      };
    in
    {
      imports = [ inputs.mcsr.homeManagerModules.waywall ];

      options.programs.waywall.config.variables = lib.mkOption {
        type = lib.types.attrsOf lua.type;
        description = "Additional variables that will be inserted as `local`s using `lib.generators.toLua`.";
        default = { };
        example = {
          sens = {
            base = 3;
            tall = 0.01;
          };
        };
      };

      config = {
        programs.waywall = {
          enable = true;
          config = {
            enableWaywork = true;
            programs = [ inputs'.mcsr.packages.ninjabrain-bot ];
            files = {
              eye_overlay = ./eye_overlay.png;
            };
            variables = {
              sens = {
                base = 3;
                tall = 0.1;
              };
              inherit tall;
              thin = {
                w = 400;
                inherit (monitor) h;
              };
              wide = {
                inherit (monitor) w;
                h = 400;
              };
              eyeSrc = place eyeSrcSize tall "center" { };
              eyeDst = place eye leftVisibleArea "center" { };
              rightEyeDst = place eye rightVisibleArea "center" { };
            };
            text =
              let
                matchVarName = lib.match "[[:alpha:]_][[:alnum:]_]*(\\.[[:alpha:]_][[:alnum:]_]*)*";
                badVarNames = lib.filter (name: matchVarName name == null) (lib.attrNames cfg.config.variables);
              in
              assert lib.assertMsg (badVarNames == [ ])
                "Bad Lua var names: ${lib.generators.toPretty { } badVarNames}";
              lib.concatStrings (
                lib.mapAttrsToList (
                  key: value: "local ${key} = ${lib.generators.toLua { } value}\n"
                ) cfg.config.variables
              )
              + lib.readFile ./init.lua;
          };
        };
      };
    };
}
