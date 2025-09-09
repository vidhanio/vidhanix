{
  config,
  pkgs,
  inputs,
  ...
}:
let
  inherit (inputs) plasma-manager;
in
{
  imports = [
    ./hardware-configuration.nix
    ./disk-configuration.nix
  ];

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
  networking = {
    hostName = config.me.host;
    networkmanager.enable = true;
  };

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
    users.${config.me.username} = {
      isNormalUser = true;
      description = config.me.fullname;
      shell = pkgs.fish;
      hashedPassword = "$y$j9T$LCdHSdiGd3E0QIKpfQJXC1$/XXchmDGIM2kQganFqhqwS7BHrOE8JwnxCQ3PW2GHO7";
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
    };
  };

  home-manager.sharedModules = [ plasma-manager.homeModules.plasma-manager ];

  programs = {
    nix-ld.enable = true;
    fish.enable = true;
    neovim.enable = true;
    _1password.enable = true;
    _1password-gui = {
      enable = true;
      polkitPolicyOwners = [ config.me.username ];
    };
  };

  environment.localBinInPath = true;

  system.stateVersion = "25.05";
}
