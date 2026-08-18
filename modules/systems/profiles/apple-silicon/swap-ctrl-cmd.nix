{
  flake.aspects.apple-silicon = {
    nixos = {
      boot.extraModprobeConfig = ''
        options hid_apple swap_ctrl_cmd=1
      '';
    };
  };
}
