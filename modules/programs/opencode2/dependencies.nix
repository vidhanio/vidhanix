{
  flake.aspects =
    { aspects, ... }:
    {
      opencode2.includes = [ aspects.mcp ];
    };
}
