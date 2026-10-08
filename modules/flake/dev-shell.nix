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
        allowSubstitutes = false;
        preferLocalBuild = true;

        inherit (config.hk-nix) shellHook;

        packages = [
          config.hk-nix.hk
          config.treefmt.build.wrapper
          pkgs.git
          pkgs.just
          pkgs.nh
          pkgs.sops
        ];
      };
    };
}
