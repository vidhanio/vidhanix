{
  profiles.base = {
    module =
      { pkgs, ... }:
      {
        programs.nh = {
          enable = true;
          package = pkgs.symlinkJoin {
            name = "nh-${pkgs.nh.version}";
            paths = [ pkgs.nh ];
            inherit (pkgs.nh) meta;
            postBuild = ''
              rm -f $out/share/nushell/vendor/autoload/nh.nu
              install -Dm644 ${pkgs.writeText "nh.nu" ''
                let __nh_previous_completer = ($env.config.completions.external.completer? | default null)

                let __nh_completer = {|place|
                    let place = if ($place | describe | str starts-with "list") {
                        { command: $place }
                    } else {
                        $place
                    }
                    let spans = $place.command
                    if (($spans | first) == "nh") {
                        COMPLETE=nu ^nh -- ...($spans | skip 1) | from json
                    } else if $__nh_previous_completer != null {
                        do $__nh_previous_completer $place
                    } else {
                        null
                    }
                }

                $env.config.completions.external.completer = $__nh_completer
              ''} $out/share/nushell/vendor/autoload/nh.nu
            '';
          };
          clean = {
            enable = true;
            extraArgs = "--keep 5 --keep-since 3d";
          };
        };
      };
  };
}
