{
  flake.modules.nixos.default = {
    persist.directories = [
      "/var/lib/bluetooth"
    ];
  };
}
