{
  lib,
  pkgs,
  osConfig,
  config,
  ...
}:
{
  targets.darwin.linkApps.enable = false;

  home.activation.linkApps = lib.mkIf osConfig.nixpkgs.hostPlatform.isDarwin (
    lib.hm.dag.entryAfter [ "installPackages" ] (
      let
        applications = pkgs.buildEnv {
          name = "user-applications";
          paths = config.home.packages;
          pathsToLink = "/Applications";
        };
      in
      ''
        targetFolder='Applications/Home Manager Apps'

        echo "setting up ~/$targetFolder..." >&2

        ourLink () {
          local link
          link=$(readlink "$1")
          [ -L "$1" ] && [ "''${link#*-}" = 'user-applications/Applications' ]
        }

        if [ -e "$targetFolder" ] && ourLink "$targetFolder"; then
          run rm "$targetFolder"
        fi

        run mkdir -p "$targetFolder"

        rsyncFlags=(
          --archive
          --checksum
          --chmod=-w
          --chown=$USER:staff
          --copy-unsafe-links
          --delete
          --exclude=$'Icon\r'
          --no-group
          --no-owner
        )

        run ${lib.getExe pkgs.rsync} "''${rsyncFlags[@]}" ${applications}/Applications/ "$targetFolder"
      ''
    )
  );
}
