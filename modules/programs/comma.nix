{ inputs, ... }:
{
  flake-file.inputs.nix-index-database.url = "github:nix-community/nix-index-database";

  flake.modules.homeManager.default =
    { pkgs, lib, ... }:
    {
      imports = [
        inputs.nix-index-database.homeModules.default
      ];

      programs.nix-index-database.comma.enable = true;

      programs.noctalia.settings.shell.launcher.dmenu.entry.comma =
        let
          picker = pkgs.writeShellScript "comma-noctalia-picker" ''
            choice=$(sed 's/\.out$//' | noctalia dmenu -p "Pick a package")
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
