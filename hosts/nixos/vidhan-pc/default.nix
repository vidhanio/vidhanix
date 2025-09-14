{
  pkgs,
  ...
}:
let
  username = "vidhanio";
in
{
  imports = [
    ./hardware-configuration.nix
    ./disk-configuration.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
  };

  hardware = {
    bluetooth.enable = true;
    logitech.wireless = {
      enable = true;
      enableGraphical = true;
    };
  };

  networking.networkmanager.enable = true;

  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_CA.UTF-8";

  services = {
    xserver = {
      enable = true;
      xkb = {
        layout = "us";
        variant = "";
      };
    };

    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
    desktopManager.plasma6.enable = true;

    printing.enable = true;

    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
    };
  };
  security.rtkit.enable = true;

  users = {
    mutableUsers = false;
    users.${username} = {
      description = "Vidhan Bhatt";
      hashedPassword = "$y$j9T$LCdHSdiGd3E0QIKpfQJXC1$/XXchmDGIM2kQganFqhqwS7BHrOE8JwnxCQ3PW2GHO7";

      isNormalUser = true;
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
    };

    defaultUserShell = pkgs.fish;
  };

  programs = {
    nix-ld.enable = true;
    _1password.enable = true;
    _1password-gui = {
      enable = true;
      polkitPolicyOwners = [ username ];
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

  security.sudo.extraConfig = ''
    Defaults lecture = never
  '';

  system.stateVersion = "25.05";
}
