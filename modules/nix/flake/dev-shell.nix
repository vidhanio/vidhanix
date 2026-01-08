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

            pkgs.nil

            inputs'.agenix.packages.default

            rebuild
          ];
        };
    };
}
