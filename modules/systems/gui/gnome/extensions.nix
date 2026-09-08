{
  flake.aspects.gnome.homeManager =
    { pkgs, ... }:
    {
      programs.gnome-shell = {
        enable = true;
        extensions =
          with pkgs.gnomeExtensions;
          map (package: { inherit package; }) [
            appindicator
            pip-on-top
            solaar-extension
          ];
      };
    };
}
