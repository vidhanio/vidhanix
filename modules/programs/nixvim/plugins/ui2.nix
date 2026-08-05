{
  flake.modules.nixvim.default = {
    extraConfigLua = ''
      require('vim._core.ui2').enable({})
    '';
  };
}
