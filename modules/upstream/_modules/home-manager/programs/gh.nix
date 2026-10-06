{ config, lib, ... }:
let
  cfg = config.programs.gh;
in
{
  options.programs.gh.username = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
    description = "The GitHub username to select as the active account.";
  };

  config = lib.mkIf (cfg.enable && cfg.username != null) {
    programs.gh.hosts."github.com" = {
      git_protocol = cfg.settings.git_protocol or "https";
      users.${cfg.username} = { };
      user = cfg.username;
    };
  };
}
