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
        inherit (config.pre-commit) shellHook;

        packages = [
          config.pre-commit.settings.package
          config.treefmt.build.wrapper
          pkgs.just
          pkgs.nh
          pkgs.sops
        ];
      };
    };
}
