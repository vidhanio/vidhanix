{
  lib,
  ...
}:
{
  imports = lib.readSubmodules ./.;

  nixpkgs.hostPlatform = "x86_64-linux";

  networking.networkmanager.enable = true;

  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_CA.UTF-8";

  services.printing.enable = true;

  security.rtkit.enable = true;

  users = {
    mutableUsers = false;
    users."vidhanio" = {
      description = "Vidhan Bhatt";
      hashedPassword = "$y$j9T$LCdHSdiGd3E0QIKpfQJXC1$/XXchmDGIM2kQganFqhqwS7BHrOE8JwnxCQ3PW2GHO7";

      isNormalUser = true;
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
    };
  };

  impermanence = {
    directories = [
      "/var/log"
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/etc/NetworkManager/system-connections"
    ];
    files = [
      "/etc/machine-id"
    ];
  };

  system.stateVersion = "25.11";
}
