{
  osConfig,
  config,
  lib,
  inputs,
  ...
}:
let
  osCfg = osConfig.impermanence;
  cfg = config.impermanence;
in
{
  imports = with inputs; [ impermanence.homeManagerModules.default ];

  options =
    let
      inherit (lib) mkOption types;
    in
    {
      impermanence = mkOption {
        type = with types; attrs;
        default = { };
        description = "Settings to pass to home-manager impermanence.";
      };
    };

  config = {
    home.persistence."${osCfg.path}${config.home.homeDirectory}" = cfg // {
      allowOther = true;
    };
  };
}
