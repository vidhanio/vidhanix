{ inputs, ... }:
{
  profiles.pc.homeModule =
    {
      config,
      lib,
      osConfig,
      pkgs,
      ...
    }:
    let
      inherit (osConfig.hardware.monitors.main) mode scale;
    in
    {
      imports = [ inputs.meowland.homeModules.default ];

      programs.meowland.enable = true;
      services.meowland = {
        enable = true;
        settings.output = {
          inherit (mode) width height;
          inherit scale;
          refresh_rate = mode.refreshRateInt;
        };
      };

      programs.nushell.extraConfig = lib.mkAfter ''
        let __meowland_previous_completer = ($env.config.completions.external.completer? | default null)

        let __meowland_completer = {|place|
            let spans = $place.command
            let head = ((($spans | first) | default "") | path basename)
            if $head == "meowland" {
                let words = if ($spans | length) <= 1 { [""] } else { $spans | skip 1 }
                let result = (with-env { COMPLETE: "fish" } { ^${lib.getExe config.programs.meowland.package} -- meowland ...$words } | complete)
                if $result.exit_code == 0 {
                    $result.stdout
                    | lines
                    | where {|line| $line != "" }
                    | each {|line|
                        let fields = ($line | split row "\t")
                        { value: ($fields | first), description: ($fields | get -o 1 | default "") }
                    }
                } else {
                    []
                }
            } else if $__meowland_previous_completer != null {
                do $__meowland_previous_completer $place
            } else {
                null
            }
        }

        $env.config.completions.external.completer = $__meowland_completer
      '';

      home.packages = [
        (pkgs.writeShellApplication {
          name = "meowser";
          runtimeInputs = [ pkgs.coreutils ];
          text = ''
            if [[ $# -ne 1 || -z $1 ]]; then
              echo "Usage: meowser <url>" >&2
              exit 1
            fi

            main="''${XDG_CONFIG_HOME:-$HOME/.config}/net.imput.helium"
            cache="''${XDG_CACHE_HOME:-$HOME/.cache}/meowser"

            mkdir -p -- "$cache"

            profile=$(mktemp -d "$cache/profile.XXXXXXXXXX")
            trap 'rm -rf -- "$profile"' EXIT
            trap 'exit 130' INT
            trap 'exit 143' TERM

            if [[ -d "$main" ]]; then
              cp -a --reflink=auto -- "$main/." "$profile/"
              rm -f -- \
                "$profile/SingletonLock" \
                "$profile/SingletonSocket" \
                "$profile/SingletonCookie"
            fi

            ${lib.getExe config.programs.meowland.package} launch --no-follow \
              ${lib.getExe config.programs.helium.finalPackage} \
              "--user-data-dir=$profile" "--app=$1"
          '';
        })
      ];
    };
}
