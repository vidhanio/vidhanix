{
  flake-file.inputs.prismlauncher.url = "github:vidhanio/PrismLauncher";

  flake.modules.homeManager.default =
    { inputs', ... }:
    {
      programs.prismlauncher = {
        enable = true;
        package = inputs'.prismlauncher.packages.default;
      };

      persist.directories = [ ".local/share/PrismLauncher" ];
    };
}
