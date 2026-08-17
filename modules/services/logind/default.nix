{
  flake.aspects.logind.nixos = {
    services.logind.settings.Login = {
      HandlePowerKey = "suspend";
      HandleLidSwitchExternalPower = "lock";
    };
  };
}
