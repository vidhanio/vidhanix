{
  profiles.apple-silicon = {
    module = {
      boot.extraModprobeConfig = ''
        options hid_apple swap_ctrl_cmd=1
      '';
    };
  };
}
