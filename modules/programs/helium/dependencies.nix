{
  flake.aspects =
    { aspects, ... }:
    {
      helium.includes = [ aspects.xdg-autostart ];
    };
}
