{ inputs, ... }:
{
  flake-file.inputs.nix-index-database.url = "github:nix-community/nix-index-database";

  flake.aspects.comma = {
    homeManager =
      { pkgs, ... }:
      {
        imports = [
          inputs.nix-index-database.homeModules.default
        ];

        programs.nix-index-database.comma.enable = true;

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

        binds."SUPER + comma".cmd = "noctalia msg panel-toggle launcher '/, '";

        persist.files = [ ".local/state/comma/choices" ];
      };
  };
}
