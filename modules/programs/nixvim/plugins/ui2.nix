{
  flake.aspects.nixvim.nixvim = {
    extraConfigLua = ''
      require('vim._core.ui2').enable({})
    '';
  };
}
