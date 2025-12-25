{
  flake.modules = {
    nixos.default = {
      persist.directories = [ "/var/lib/waydroid" ];
    };
    homeManager.default = {
      persist.directories = [ ".local/share/waydroid" ];
    };
  };
}
