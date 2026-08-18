{
  flake.aspects =
    { aspects, ... }:
    {
      nixvim.includes = [ aspects.wakatime ];
    };
}
