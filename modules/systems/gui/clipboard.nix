{
  den.default.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        wl-clipboard
      ];

      services.cliphist.enable = true;
    };
}
