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

        packages = with pkgs; [
          git
          just
          nh
          nix
          sops

          config.hk-nix.hk
          config.treefmt.build.wrapper
        ];
      };
    };
}
