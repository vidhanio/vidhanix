{
  flake.aspects =
    { aspects, ... }:
    {
      nixcord.includes = [ aspects.xdg-autostart ];
    };
}
