{
  flake.modules.nixos.default = {
    environment.etc = {
      "1password/custom_allowed_browsers" = {
        text = ''
          firefox-devedition
          helium
        '';
        mode = "0755";
      };
    };
  };
}
