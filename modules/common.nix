{
  config,
  pkgs,
  ...
}:
{
  users = {
    mutableUsers = false;
    users."vidhanio" = {
      description = "Vidhan Bhatt";
      hashedPasswordFile = config.age.secrets.password.path;

      isNormalUser = true;
      extraGroups = [ "wheel" ];
      shell = pkgs.fish;
    };
  };

  age.secrets.password.file = ../secrets/password.age;

  environment = {
    systemPackages = with pkgs; [
      neovim
      wl-clipboard
    ];

    variables = {
      EDITOR = "nvim";
    };

    shellAliases = {
      vi = "nvim";
    };

    sessionVariables.NIXOS_OZONE_WL = "1";
  };

  programs = {
    _1password.enable = true;
    _1password-gui.enable = true;

    fish.enable = true;
  };

  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_CA.UTF-8";

  services = {
    printing.enable = true;
  };
  security.rtkit.enable = true;

  virtualisation.waydroid.enable = true;

  nix.settings = {
    trusted-users = [ "vidhanio" ];

    extra-substituters = [
      "https://nix-community.cachix.org/"
      "https://nixos-apple-silicon.cachix.org"
    ];

    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nixos-apple-silicon.cachix.org-1:8psDu5SA5dAD7qA0zMy5UT292TxeEPzIz8VVEr2Js20="
    ];
  };
}
