{ inputs, withSystem, ... }:
{
  flake-file.inputs.nix-index-database.url = "github:nix-community/nix-index-database";

  flake.modules.homeManager.default =
    { pkgs, lib, ... }:
    let
      binNames =
        pkgs.runCommand "comma-fish-bin-names"
          {
            nativeBuildInputs = [
              (withSystem pkgs.stdenv.hostPlatform.system (
                { inputs', ... }: inputs'.nix-index-database.packages.nix-index-with-db
              ))
            ];
          }
          ''
            nix-locate --at-root "/bin/" | sed -E 's#.*/##' | sort -u > $out
          '';
    in
    {
      imports = [
        inputs.nix-index-database.homeModules.default
      ];

      programs.nix-index-database.comma.enable = true;

      programs.fish.completions = {
        comma = ''
          comma --print-completions fish 2>/dev/null | source

          complete -c comma -n "__fish_comma_needs_command" -a "(cat ${binNames})"
        '';

        "," = "complete -c , -w comma";
      };

      programs.noctalia.settings.shell.launcher.dmenu.entry.comma =
        let
          picker = pkgs.writeShellScript "comma-noctalia-picker" ''
            choice=$(sed 's/\.out$//' | sort | noctalia dmenu -p "Pick a package")
            if [[ -n "$choice" ]]; then
              printf '%s.out\n' "$choice"
            fi
          '';
        in
        {
          label = "Comma";
          prefix = ",";
          glyph = "terminal";
          global = false;
          freeform = true;
          exec = "comma --picker ${picker} -- {query}";
        };

      wayland.windowManager.hyprland.settings.bind = [
        {
          _args = [
            "SUPER + comma"
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("noctalia msg panel-toggle launcher '/, '")'')
          ];
        }
      ];

      persist.files = [ ".local/state/comma/choices" ];
    };
}
