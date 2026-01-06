{
  perSystem =
    {
      config,
      inputs',
      pkgs,
      system,
      ...
    }:
    {
      files.file.".envrc".text = ''
        # shellcheck shell=bash
        use flake
      '';

      devShells.default =
        let
          update = pkgs.writeShellApplication {
            name = "update";

            runtimeInputs = with pkgs; [
              nix
              nix-update
              jq
              git
            ];

            text = ''
              git add .

              nix flake update

              packages=$(
                nix eval --json .#packages."${system}" --apply 'builtins.mapAttrs (_: pkg: pkg ? passthru.updateScript)' |
                  jq -r 'with_entries(select(.value)) | keys | .[]'
              )

              for package in $packages; do
                nix-update --flake --use-update-script "$package"
              done
            '';
          };

          rebuild = pkgs.writeShellApplication {
            name = "rebuild";

            runtimeInputs = with pkgs; [
              git
              nh
              direnv
            ];

            text = ''
              git add .

              nh os "''${@:-switch}"

              direnv reload
            '';
          };
        in
        pkgs.mkShell {
          inherit (config.pre-commit) shellHook;

          packages = config.pre-commit.settings.enabledPackages ++ [
            pkgs.git
            pkgs.direnv

            pkgs.nixfmt-rfc-style
            pkgs.nil

            inputs'.agenix.packages.default

            update
            rebuild

            config.files.writer.drv
          ];
        };
    };
}
