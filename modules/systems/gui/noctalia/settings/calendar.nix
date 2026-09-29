{
  flake.aspects.noctalia.homeManager = { config, ... }: {
    sops.secrets.apple = { };

    programs.noctalia.settings.calendar = {
      enabled = true;
      account.icloud = {
        type = "caldav";
        name = "iCloud";
        provider = "icloud";
        username = "me@vidhan.io";
        credential_source = "file";
        password_file = config.sops.secrets.apple.path;
      };
    };
  };
}
