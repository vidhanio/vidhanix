{ pkgs, ... }:
{
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  environment.systemPackages = with pkgs; [ distrobox ];

  home-manager.sharedModules = [
    { persist.directories = [ ".local/share/containers" ]; }
  ];

  # programs.steam.enable = true;
}
