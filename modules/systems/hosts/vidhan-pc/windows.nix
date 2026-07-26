{
  den.aspects.vidhan-pc.nixos = {
    boot.loader.systemd-boot.windows."11".efiDeviceHandle = "HD0d";

    environment.shellAliases.reboot-windows = "systemctl reboot --boot-loader-entry windows_11.conf";
  };
}
