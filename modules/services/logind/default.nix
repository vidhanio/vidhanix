{
  profiles.pc = {
    module = {
      services.logind.settings.Login = {
        HandlePowerKey = "suspend";
        HandleLidSwitchExternalPower = "lock";
      };
    };
  };
}
