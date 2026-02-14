{
  flake.modules.homeManager.default =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        wl-clipboard
      ];

      services.cliphist.enable = true;
    };
}
