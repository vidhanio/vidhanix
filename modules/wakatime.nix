{
  pkgs,
  lib,
  ...
}:
{
  flake.modules.homeManager.default = args: {
    age.secrets.wakatime.file = ../secrets/wakatime.age;

    home.activation.setWakatimeKey = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      export XDG_RUNTIME_DIR=''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
      run ${lib.getExe pkgs.wakatime-cli} --config-write api_key_vault_cmd="cat ${args.config.age.secrets.wakatime.path}"
    '';
  };
}
