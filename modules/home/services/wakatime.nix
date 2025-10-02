{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.wakatime;
in
{
  options.services.wakatime = {
    enable = lib.mkEnableOption "Wakatime";
    apiKeyFile = lib.mkOption {
      type = lib.types.path;
      default = ../../../secrets/wakatime.age;
      description = "Path to a file containing your age-encrpyted Wakatime API key.";
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets.wakatime = {
      file = cfg.apiKeyFile;
    };

    home.activation.wakatimeCfg =
      let
        wakatime-cli = lib.getExe pkgs.wakatime;
      in
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run ${wakatime-cli} --config-write api_key_vault_cmd="cat ${config.age.secrets.wakatime.path}"
      '';
  };
}
