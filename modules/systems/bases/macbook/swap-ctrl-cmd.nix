{
  flake.modules.nixos.macbook = {
    boot.extraModprobeConfig = ''
      options hid_apple swap_ctrl_cmd=1
    '';
  };
}
