{
  pkgs,
  ...
}:
{
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
      shell = pkgs.fish;
    };
  };

  environment = {
    systemPackages = with pkgs; [
      neovim
    ];

    variables = {
      EDITOR = "nvim";
    };

    shellAliases = {
      vi = "nvim";
    };
  };

  programs = {
    fish.enable = true;
    ssh.knownHosts."github.com".publicKey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
  };

  networking.networkmanager.enable = true;

  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_CA.UTF-8";

  services = {
    printing.enable = true;
    openssh.enable = true;
  };
  security.rtkit.enable = true;

  nix.settings = {
    trusted-users = [ "vidhanio" ];

    substituters = [
      "https://cache.nixos.org/"
      "https://install.determinate.systems"
      "https://nix-community.cachix.org/"
      "https://nixos-apple-silicon.cachix.org"
    ];

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nixos-apple-silicon.cachix.org-1:8psDu5SA5dAD7qA0zMy5UT292TxeEPzIz8VVEr2Js20="
    ];
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
}
