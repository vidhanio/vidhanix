{ inputs, ... }:
{
  profiles.pc.homeModule = {
    imports = [ inputs.meowland.homeModules.default ];

    programs.meowland.enable = true;

    systemd.user.services.meowland.Unit.X-SwitchMethod = "keep-old";
  };
}
