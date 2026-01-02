{
  flake.modules.nixos = {
    default = {
      disko.devices.nodev."/" = {
        fsType = "tmpfs";
        mountOptions = [ "mode=755" ];
      };
    };
    pc = {
      disko.devices.nodev."/".mountOptions = [ "size=8G" ];
    };
    apple-silicon = {
      disko.devices.nodev."/".mountOptions = [ "size=2G" ];
    };
  };
}
