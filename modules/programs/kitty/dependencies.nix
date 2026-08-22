{
  flake.aspects =
    { aspects, ... }:
    {
      kitty.includes = [ aspects.xdg-autostart ];
    };
}
