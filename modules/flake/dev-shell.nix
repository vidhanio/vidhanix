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

      devShells.default = pkgs.mkShell {
        preferLocalBuild = true;
        allowSubstitutes = false;

        inherit (config.pre-commit) shellHook;

        packages = config.pre-commit.settings.enabledPackages ++ [
          pkgs.git
          pkgs.direnv

          pkgs.nil

          pkgs.sops

          pkgs.nh

          pkgs.just
        ];
      };
    };
}
