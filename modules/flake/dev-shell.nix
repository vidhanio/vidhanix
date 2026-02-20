{
  perSystem =
    {
      config,
      inputs',
      pkgs,
      self',
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

            runtimeInputs = with pkgs; [
              git
              nh
              self'.packages.generate-files
            ];

            text = ''
              git add .

              generate-files

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
