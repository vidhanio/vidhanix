{
  services.flatpak = {
    enable = true;
    packages = [
      "org.vinegarhq.Sober"
    ];
  };

  persist.directories = [ ".local/share/flatpak" ];
}
