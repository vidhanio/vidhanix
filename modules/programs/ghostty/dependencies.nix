{
  flake.aspects =
    { aspects, ... }:
    {
      ghostty.includes = [ aspects.xdg-autostart ];
    };
}
