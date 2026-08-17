{
  flake.aspects =
    { aspects, ... }:
    {
      steam.includes = [ aspects.hardware ];
    };
}
