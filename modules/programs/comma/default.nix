{ inputs, ... }:
{
  profiles.pc = {
    homeModule =
      {
        inputs',
        lib,
        pkgs,
        ...
      }:
      let
        binNames =
          pkgs.runCommand "comma-bin-names"
            {
              nativeBuildInputs = [
                inputs'.nix-index-database.packages.nix-index-with-db
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

        programs = {
          nix-index-database.comma.enable = true;

          nushell.extraConfig = lib.mkAfter ''
            let __comma_flags = [
                { value: "-i", description: "Install the derivation containing the executable" }
                { value: "--install", description: "Install the derivation containing the executable" }
                { value: "-s", description: "Open a shell containing the derivation containing the executable" }
                { value: "--shell", description: "Open a shell containing the derivation containing the executable" }
                { value: "-P", description: "Picker to use" }
                { value: "--picker", description: "Picker to use" }
                { value: "-F", description: "Nixpkgs flake to use" }
                { value: "--nixpkgs-flake", description: "Nixpkgs flake to use" }
                { value: "-a", description: "Ask to confirm the program that will be run" }
                { value: "--ask", description: "Ask to confirm the program that will be run" }
                { value: "-p", description: "Print the package containing the executable" }
                { value: "--print-packages", description: "Print the package containing the executable" }
                { value: "-x", description: "Print the absolute path to the executable in the nix store" }
                { value: "--print-path", description: "Print the absolute path to the executable in the nix store" }
                { value: "--cache-level", description: "Configure the cache level" }
                { value: "-e", description: "Empty the cache" }
                { value: "--empty-cache", description: "Empty the cache" }
                { value: "-d", description: "Overwrite the cache entry for the specified command" }
                { value: "--delete-entry", description: "Overwrite the cache entry for the specified command" }
                { value: "-h", description: "Print help" }
                { value: "--help", description: "Print help" }
                { value: "-V", description: "Print version" }
                { value: "--version", description: "Print version" }
            ]

            let __carapace_completer = $env.config.completions.external.completer?
            $env.config.completions.external.completer = {|place|
                let spans = $place.command
                let head = (($spans | first) | path basename)
                if ($head in ['comma' ',']) and (($spans | length) == 2) {
                    let token = ($spans | last)
                    if ($token | str starts-with '-') {
                        $__comma_flags | where {|flag| $flag.value | str starts-with $token }
                    } else {
                        open ${binNames}
                        | lines
                        | where {|name| $name | str starts-with $token }
                        | each {|name| { value: $name } }
                    }
                } else if $__carapace_completer != null {
                    do $__carapace_completer $place
                } else {
                    null
                }
            }
          '';

          noctalia.settings.shell.launcher.dmenu.entry.comma =
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

        };

        desktop.binds."SUPER + comma".cmd = "noctalia msg panel-toggle launcher '/, '";

        persist.files = [ ".local/state/comma/choices" ];
      };
  };
}
