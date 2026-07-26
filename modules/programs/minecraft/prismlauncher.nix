{ withSystem, ... }: {
  flake-file.inputs.prismlauncher.url = "github:vidhanio/PrismLauncher";

  den.default.homeManager = { pkgs, ... }: {
    programs.prismlauncher = {
      enable = true;
      package = withSystem pkgs.stdenv.hostPlatform.system (
        { inputs', ... }: inputs'.prismlauncher.packages.default
      );
    };

    persist.directories = [ ".local/share/PrismLauncher" ];
  };
}
