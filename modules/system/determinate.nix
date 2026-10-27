{ inputs, ... }:
{
  profiles.base.module =
    { config, ... }:
    {
      imports = [ inputs.determinate.nixosModules.default ];
      environment.etc."determinate/config.json".text = builtins.toJSON {
        authentication.additionalNetrcSources = [ config.sops.secrets.netrc.path ];
      };
    };
}
