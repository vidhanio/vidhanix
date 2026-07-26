{
  den.aspects.macbook.nixos = {
    boot.extraModprobeConfig = ''
      options hid_apple swap_ctrl_cmd=1
    '';
  };
}
