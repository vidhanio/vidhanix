{
  perSystem =
    {
      config,
      inputs',
      pkgs,
      ...
    }:
    {
      files.file.".envrc".text = ''
        # shellcheck shell=bash
        use flake
      '';

      devShells.default =
        let
          rebuild = pkgs.writeShellApplication {
            name = "rebuild";

            runtimeInputs = with pkgs.extend (_: _: { nix = inputs'.determinate-nix.packages.default; }); [
              git
              nix
              nh
            ];

            text = ''
              git add .

              nix run .#generate-files

              nh os "''${@:-switch}"
            '';
          };
        in
        pkgs.mkShell {
          inherit (config.pre-commit) shellHook;

          packages = config.pre-commit.settings.enabledPackages ++ [
            pkgs.git
            pkgs.direnv

            pkgs.nil

            inputs'.agenix.packages.default

            rebuild
          ];
        };
    };
}
