{
  den.default.nixos = {
    programs.fish.shellInit = ''
      fish_vi_key_bindings
    '';
  };
}
