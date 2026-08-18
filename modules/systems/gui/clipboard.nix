{
  flake.aspects.clipboard = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          wl-clipboard
        ];

        services.cliphist.enable = true;
      };
  };
}
