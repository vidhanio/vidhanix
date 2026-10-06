{
  profiles.base = {
    module = {
      security.sudo.enable = false;

      security.run0 = {
        enable = true;
        persistentAuth.enable = true;
      };
    };
  };
}
