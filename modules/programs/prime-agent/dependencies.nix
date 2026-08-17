{
  flake.aspects =
    { aspects, ... }:
    {
      prime-agent.includes = [ aspects.mcp ];
    };
}
