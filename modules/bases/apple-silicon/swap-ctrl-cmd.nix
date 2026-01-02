{
  flake.modules.nixos.apple-silicon = {
    boot.extraModprobeConfig = ''
      options hid_apple swap_ctrl_cmd=1
    '';
  };
}
