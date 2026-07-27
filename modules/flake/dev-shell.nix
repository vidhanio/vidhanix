{
  perSystem =
    {
      config,
      pkgs,
      ...
    }:
    {
      files.commentedFile.".envrc".text = ''
        # shellcheck shell=bash
        use flake
      '';

      devShells.default =
        let
          n = pkgs.writeShellApplication {
            name = "n";

            derivationArgs = {
              preferLocalBuild = true;
              allowSubstitutes = false;
            };

            runtimeInputs = with pkgs; [
              git
              nix
              nh
            ];

            text = ''
              git add -AN

              nix run .#generate-files

              nh os "''${@:-switch}"
            '';
          };
        in
        pkgs.mkShell {
          preferLocalBuild = true;
          allowSubstitutes = false;

          inherit (config.pre-commit) shellHook;

          packages = config.pre-commit.settings.enabledPackages ++ [
            pkgs.git
            pkgs.direnv

            pkgs.nil

            pkgs.sops

            pkgs.nh

            n
          ];
        };
    };
}
