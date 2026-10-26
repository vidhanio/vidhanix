{ inputs, ... }:
{
  profiles.pc.homeModule =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [ inputs.meowland.homeModules.default ];

      programs.meowland.enable = true;

      home.packages = [
        (pkgs.writeShellApplication {
          name = "meowser";
          runtimeInputs = [ pkgs.coreutils ];
          text = ''
            if [[ $# -ne 1 || -z $1 ]]; then
              echo "Usage: meowser <url>" >&2
              exit 1
            fi

            profile=$(mktemp -d -t meowser.XXXXXXXXXX)
            trap 'rm -rf -- "$profile"' EXIT
            trap 'exit 130' INT
            trap 'exit 143' TERM

            ${lib.getExe config.programs.meowland.package} run \
              ${lib.getExe config.programs.helium.finalPackage} \
              "--user-data-dir=$profile" "--app=$1"
          '';
        })
      ];
    };
}
