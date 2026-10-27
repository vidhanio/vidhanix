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
      inherit (osConfig.hardware.monitors.main) mode;
    in
    {
      imports = [ inputs.meowland.homeModules.default ];

      programs.meowland.enable = true;
      services.meowland = {
        enable = true;
        settings.output.refresh_rate = mode.refreshRateInt;
      };

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

            ${lib.getExe config.programs.meowland.package} run \
              ${lib.getExe config.programs.helium.finalPackage} \
              "--user-data-dir=$profile" "--app=$1"
          '';
        })
      ];
    };
}
