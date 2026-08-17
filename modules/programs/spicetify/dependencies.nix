{
  flake.aspects =
    { aspects, ... }:
    {
      spicetify.includes = [ aspects.xdg-autostart ];
    };
}
