{
  flake.aspects =
    { aspects, ... }:
    {
      omp.includes = [ aspects.mcp ];
    };
}
