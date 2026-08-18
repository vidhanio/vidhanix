{
  flake.aspects =
    { aspects, ... }:
    {
      crush.includes = [ aspects.mcp ];
    };
}
