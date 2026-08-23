{
  flake.aspects =
    { aspects, ... }:
    {
      fx.includes = [ aspects.mcp ];
    };
}
