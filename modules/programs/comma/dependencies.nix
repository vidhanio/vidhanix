{
  flake.aspects =
    { aspects, ... }:
    {
      comma.includes = [ aspects.skills ];
    };
}
