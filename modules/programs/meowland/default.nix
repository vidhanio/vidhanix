{ inputs, ... }:
{
  profiles.pc.homeModule = {
    imports = [ inputs.meowland.homeModules.default ];

    programs.meowland.enable = true;
  };
}
