{
  flake.modules.nixos = {
    default = {
      disko.devices.nodev."/" = {
        fsType = "tmpfs";
        mountOptions = [ "mode=755" ];
      };
    };
    desktop = {
      disko.devices.nodev."/".mountOptions = [ "size=8G" ];
    };
    macbook = {
      disko.devices.nodev."/".mountOptions = [ "size=2G" ];
    };
  };
}
