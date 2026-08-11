{
  flake.modules.nixos.default = {
    services.logind.settings.Login = {
      HandlePowerKey = "suspend";
      HandleLidSwitchExternalPower = "lock";
    };
  };
}
