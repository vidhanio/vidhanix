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
      files.commentedFile.".envrc".text = ''
        # shellcheck shell=bash
        use flake
      '';

      devShells.default = pkgs.mkShell {
        allowSubstitutes = false;
        preferLocalBuild = true;

        inherit (config.hk-nix) shellHook;

        packages =
          with (pkgs.extend (
            _: _: {
              nix = inputs'.determinate.inputs.nix.packages.${system}.default;
            }
          )); [
            git
            just
            nh
            sops

            config.hk-nix.hk
            config.treefmt.build.wrapper
          ];
      };
    };
}
