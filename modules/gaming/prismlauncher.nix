{
  flake.modules.homeManager.default =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [ prismlauncher ];

      persist.directories = [ ".local/share/PrismLauncher" ];
    };
}
