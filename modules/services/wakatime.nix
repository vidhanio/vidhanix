{
  den.default.homeManager =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      sops.secrets.wakatime = { };

      home.activation.setWakatimeKey = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run ${lib.getExe pkgs.wakatime-cli} --config-write api_key_vault_cmd="cat ${config.sops.secrets.wakatime.path}"
      '';
    };
}
